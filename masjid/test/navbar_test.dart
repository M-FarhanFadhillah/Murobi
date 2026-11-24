import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/screens/dashboard.dart';
import 'package:masjid/screens/dashboard/empty_tab.dart';
import 'package:masjid/screens/dashboard/home_pages.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
    ProfileStore.instance.clear();
  });

  const labels = ['Beranda', 'Edukasi', "Al-Qur'an", 'ZISWAF', 'Keuangan'];

  Future<void> pumpDashboard(WidgetTester tester) async {
    AuthSession.login('jamaah', 'jamaah123');
    await ProfileStore.instance.loadFor(AuthSession.current!);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: Dashboard()));
    await tester.pump(const Duration(milliseconds: 200));
  }

  Finder navLabel(String text) =>
      find.descendant(of: find.byType(AppBottomNav), matching: find.text(text));

  Color labelColor(WidgetTester tester, String text) =>
      tester.widget<Text>(navLabel(text)).style!.color!;

  int pageIndex(WidgetTester tester) =>
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

  group('Navigasi bawah', () {
    testWidgets('lima tombol: Beranda, Edukasi, Al-Qur\'an, ZISWAF, Keuangan; tanpa Profil',
        (tester) async {
      await pumpDashboard(tester);

      for (final label in labels) {
        expect(navLabel(label), findsOneWidget, reason: label);
      }
      expect(navLabel('Profil'), findsNothing);
      // Ikon ZISWAF dan Keuangan (belum terpilih: versi garis).
      expect(find.byIcon(Icons.volunteer_activism_outlined), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('tombol terpilih hijau dengan ikon terisi, lainnya abu-abu', (tester) async {
      await pumpDashboard(tester);

      expect(labelColor(tester, 'Beranda'), AppPalette.primary);
      expect(labelColor(tester, 'ZISWAF'), AppPalette.textMuted);

      await tester.tap(navLabel('ZISWAF'));
      await tester.pump();

      expect(labelColor(tester, 'ZISWAF'), AppPalette.primary);
      expect(labelColor(tester, 'Beranda'), AppPalette.textMuted);
      expect(find.byIcon(Icons.volunteer_activism_rounded), findsOneWidget);
    });

    testWidgets('ZISWAF dan Keuangan membuka halaman kosong', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(navLabel('ZISWAF'));
      await tester.pump();
      expect(pageIndex(tester), 3);
      expect(find.byKey(const ValueKey('tab-kosong-ziswaf')), findsOneWidget);
      // Kosong: tidak ada teks apa pun di dalamnya.
      expect(
        find.descendant(of: find.byType(EmptyTab), matching: find.byType(Text)),
        findsNothing,
      );

      await tester.tap(navLabel('Keuangan'));
      await tester.pump();
      expect(pageIndex(tester), 4);
      expect(find.byKey(const ValueKey('tab-kosong-keuangan')), findsOneWidget);

      await tester.tap(navLabel('Beranda'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(pageIndex(tester), 0);
    });
  });

  group('Profil lewat foto profil di Beranda', () {
    testWidgets('mengetuk foto profil membuka Profil; tak ada tombol yang tersorot',
        (tester) async {
      await pumpDashboard(tester);
      expect(find.byType(ProfilePages).hitTestable(), findsNothing);

      await tester.tap(find.byIcon(Icons.person).first);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ProfilePages).hitTestable(), findsOneWidget);
      expect(pageIndex(tester), 5);
      for (final label in labels) {
        expect(labelColor(tester, label), AppPalette.textMuted, reason: label);
      }

      // Kembali lewat navigasi.
      await tester.tap(navLabel('Beranda'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ProfilePages).hitTestable(), findsNothing);
      expect(labelColor(tester, 'Beranda'), AppPalette.primary);
    });
  });

  group('Navigasi melayang di atas konten', () {
    testWidgets('halaman memanjang sampai bawah layar, di belakang navigasi',
        (tester) async {
      await pumpDashboard(tester);

      final scaffold = tester.widget<Scaffold>(
        find.ancestor(of: find.byType(AppBottomNav), matching: find.byType(Scaffold)).first,
      );
      expect(scaffold.extendBody, isTrue);
      // Tidak ada pita latar di atas navigasi: konten berakhir di dasar layar.
      expect(tester.getRect(find.byType(IndexedStack)).bottom, 844);
      expect(
        tester.getRect(find.byType(AppBottomNav)).top,
        lessThan(tester.getRect(find.byType(IndexedStack)).bottom),
      );
    });

    testWidgets('akhir gulir Beranda menyisakan ruang setinggi navigasi', (tester) async {
      await pumpDashboard(tester);

      final navHeight = tester.getSize(find.byType(AppBottomNav)).height;
      final scroll = tester.widget<SingleChildScrollView>(
        find.descendant(of: find.byType(HomeWidget), matching: find.byType(SingleChildScrollView)),
      );
      final padding = scroll.padding!.resolve(TextDirection.ltr);
      expect(padding.bottom, greaterThanOrEqualTo(navHeight + 16));
    });

    testWidgets('admin: tombol Tambah materi di Edukasi berada di atas navigasi',
        (tester) async {
      AuthSession.login('admin', 'admin123');
      await ProfileStore.instance.loadFor(AuthSession.current!);
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: Dashboard()));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(navLabel('Edukasi'));
      await tester.pump(const Duration(milliseconds: 300));

      final fab = tester.getRect(find.widgetWithText(FloatingActionButton, 'Tambah materi'));
      final nav = tester.getRect(find.byType(AppBottomNav));
      expect(fab.bottom, lessThanOrEqualTo(nav.top + 4));
      expect(find.widgetWithText(FloatingActionButton, 'Tambah materi').hitTestable(),
          findsOneWidget);
    });
  });
}
