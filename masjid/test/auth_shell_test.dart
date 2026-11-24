import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/login/auth_shell.dart';

// Tab Masuk/Daftar di atas kartu putih: tab yang tidak aktif (putih pudar)
// memanjang ke belakang kartu supaya tidak ada celah latar hijau di balik sudut
// kartu yang membulat.
void main() {
  Future<void> pumpShell(WidgetTester tester, {required bool isLogin}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: AuthShell(
          isLogin: isLogin,
          child: const SizedBox(height: 200),
        ),
        routes: {
          '/login': (_) => const Scaffold(body: Text('HALAMAN MASUK')),
          '/signup': (_) => const Scaffold(body: Text('HALAMAN DAFTAR')),
        },
      ),
    );
  }

  Rect tabRect(WidgetTester tester, String label) => tester.getRect(
        find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first,
      );

  Rect cardRect(WidgetTester tester) =>
      tester.getRect(find.byKey(const ValueKey('auth-card')));

  testWidgets('halaman Masuk: tab Daftar (pudar) menutup celah sudut kanan kartu',
      (tester) async {
    await pumpShell(tester, isLogin: true);

    final card = cardRect(tester);
    final daftar = tabRect(tester, 'Daftar');
    final masuk = tabRect(tester, 'Masuk');

    // Tab pudar memanjang melewati tepi atas kartu sejauh radius sudutnya.
    expect(daftar.bottom, greaterThanOrEqualTo(card.top + 20));
    expect(daftar.right, card.right);
    // Tab aktif berhenti tepat di tepi atas kartu (menyatu dengan kartu).
    expect(masuk.bottom, card.top);
  });

  testWidgets('halaman Daftar: tab Masuk (pudar) menutup celah sudut kiri kartu',
      (tester) async {
    await pumpShell(tester, isLogin: false);

    final card = cardRect(tester);
    final masuk = tabRect(tester, 'Masuk');
    final daftar = tabRect(tester, 'Daftar');

    expect(masuk.bottom, greaterThanOrEqualTo(card.top + 20));
    expect(masuk.left, card.left);
    expect(daftar.bottom, card.top);
  });

  testWidgets('label tab tetap di atas kartu dan tab pudar tetap bisa diketuk',
      (tester) async {
    await pumpShell(tester, isLogin: true);

    final card = cardRect(tester);
    expect(tester.getRect(find.text('Daftar')).bottom, lessThan(card.top));

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('HALAMAN DAFTAR'), findsOneWidget);
  });
}
