import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/login/login.dart';
import 'package:masjid/login/sign_up.dart';
import 'package:masjid/screens/dashboard.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Aplikasi bisa dipakai tanpa akun (mis. jamaah lansia). Masuk dan daftar ada
// di Profil; setelah masuk/keluar pengguna tetap di aplikasi.

void _restartApp() {
  AuthSession.resetForTest();
  ProfileStore.instance.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _restartApp();
  });

  group('Dashboard sebagai tamu', () {
    Future<void> pumpDashboard(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: const Dashboard(),
        routes: {
          '/login': (_) => const LoginWidget(),
          '/signup': (_) => const SignUpWidget(),
          '/dashboard': (_) => const Dashboard(),
        },
      ));
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Transisi halaman memakai animasi; Dashboard punya jam berdetak sehingga
    // pumpAndSettle tidak pernah selesai.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
    }

    Finder navLabel(String text) =>
        find.descendant(of: find.byType(AppBottomNav), matching: find.text(text));

    Future<void> openProfile(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.person).first);
      await settle(tester);
    }

    Future<void> fillLogin(WidgetTester tester, String id, String password) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), id);
      await tester.enterText(fields.at(1), password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await settle(tester);
    }

    testWidgets('semua tab bisa dibuka tanpa akun', (tester) async {
      await pumpDashboard(tester);

      expect(AuthSession.current, isNull);
      for (final label in ['Edukasi', "Al-Qur'an", 'ZISWAF', 'Keuangan', 'Beranda']) {
        await tester.tap(navLabel(label));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('Masuk Akun'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Profil tamu: ajakan masuk/daftar, tanpa menu akun', (tester) async {
      await pumpDashboard(tester);
      await openProfile(tester);

      expect(find.text('Anda belum masuk'), findsOneWidget);
      expect(find.byKey(const ValueKey('profil-masuk')), findsOneWidget);
      expect(find.byKey(const ValueKey('profil-daftar')), findsOneWidget);
      expect(find.text('Laporkan Permasalahan'), findsNothing);
      expect(find.text('Keluar'), findsNothing);
      expect(find.text('EDIT'), findsNothing);
    });

    testWidgets('tombol kembali di halaman Masuk menutupnya tanpa masuk', (tester) async {
      await pumpDashboard(tester);
      await openProfile(tester);

      await tester.tap(find.byKey(const ValueKey('profil-masuk')));
      await settle(tester);
      expect(find.text('Masuk Akun'), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await settle(tester);

      expect(find.text('Masuk Akun'), findsNothing);
      expect(find.text('Anda belum masuk'), findsOneWidget);
      expect(AuthSession.current, isNull);
    });

    testWidgets('masuk dari Profil kembali ke Profil yang menampilkan akun', (tester) async {
      await pumpDashboard(tester);
      await openProfile(tester);
      await tester.tap(find.byKey(const ValueKey('profil-masuk')));
      await settle(tester);

      await fillLogin(tester, 'jamaah', 'jamaah123');

      expect(find.text('Masuk Akun'), findsNothing);
      expect(find.text('Anda belum masuk'), findsNothing);
      expect(find.text('Jamaah As-Syifa'), findsWidgets);
      expect(find.text('Laporkan Permasalahan'), findsOneWidget);
      expect(find.text('Selamat datang, Jamaah As-Syifa.'), findsOneWidget);
      // Tetap di Profil (bukan dilempar ke Beranda).
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 5);
    });

    testWidgets('admin masuk dari Profil: menu admin langsung muncul', (tester) async {
      await pumpDashboard(tester);
      await tester.tap(navLabel('Edukasi'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Tambah materi'), findsNothing);

      await tester.tap(navLabel('Beranda'));
      await tester.pump(const Duration(milliseconds: 200));
      await openProfile(tester);
      await tester.tap(find.byKey(const ValueKey('profil-masuk')));
      await settle(tester);
      await fillLogin(tester, 'admin', 'admin123');

      expect(find.text('Kelola Kegiatan Masjid'), findsOneWidget);
      expect(find.text('Laporan Masalah Jamaah'), findsOneWidget);

      await tester.tap(navLabel('Edukasi'));
      await settle(tester);
      expect(find.text('Tambah materi'), findsOneWidget);
    });

    testWidgets('keluar: tetap di aplikasi, Profil kembali ke tampilan tamu', (tester) async {
      await AccountService(remote: false).signIn('jamaah', 'jamaah123');
      await pumpDashboard(tester);
      await openProfile(tester);
      expect(find.text('Keluar'), findsOneWidget);

      await tester.tap(find.text('Keluar'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await settle(tester);

      expect(AuthSession.current, isNull);
      expect(find.text('Anda belum masuk'), findsOneWidget);
      expect(find.text('Masuk Akun'), findsNothing);
      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('daftar dari Profil, lalu masuk dengan akun baru', (tester) async {
      await pumpDashboard(tester);
      await openProfile(tester);
      await tester.tap(find.byKey(const ValueKey('profil-daftar')));
      await settle(tester);
      expect(find.text('Daftar Akun'), findsWidgets);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Siti Aminah');
      await tester.enterText(fields.at(1), '081311112222');
      await tester.enterText(fields.at(2), 'Rahasia#123');
      await tester.enterText(fields.at(3), 'Rahasia#123');
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Daftar'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
      await settle(tester);

      // Berpindah ke halaman Masuk, lalu masuk dengan akun yang baru dibuat.
      expect(find.text('Masuk Akun'), findsOneWidget);
      await fillLogin(tester, '081311112222', 'Rahasia#123');

      expect(find.text('Siti Aminah'), findsWidgets);
      expect(find.text('Anda belum masuk'), findsNothing);
    });
  });

  group('Akun hasil daftar (mode lokal) tersimpan di perangkat', () {
    const phone = '081311112222';

    Future<void> register({String password = 'Rahasia#123'}) async {
      final result = await AccountService(remote: false).signUp(
        nama: 'Siti Aminah',
        phone: ' $phone ',
        password: password,
      );
      expect(result.ok, isTrue);
    }

    test('akun tetap bisa dipakai masuk setelah aplikasi dibuka ulang', () async {
      await register();
      _restartApp();

      final result = await AccountService(remote: false).signIn(phone, 'Rahasia#123');

      expect(result.ok, isTrue);
      expect(AuthSession.current!.nama, 'Siti Aminah');
      expect(AuthSession.isAdmin, isFalse);
    });

    test('kata sandi salah ditolak', () async {
      await register();
      _restartApp();

      expect((await AccountService(remote: false).signIn(phone, 'salah')).error,
          'ID atau kata sandi salah.');
    });

    test('akun lama yang didaftarkan dengan email tetap bisa masuk', () async {
      // Format tersimpan sebelum email dihapus dari pendaftaran: email sebagai ID.
      final credential = LocalCredential.create('Rahasia#123');
      SharedPreferences.setMockInitialValues({
        'local_accounts_v1': jsonEncode([
          {
            'id': 'siti@contoh.com',
            'nama': 'Siti Lama',
            'email': 'siti@contoh.com',
            'phone': '081355556666',
            'salt': credential.salt,
            'hash': credential.hash,
          },
        ]),
      });
      final service = AccountService(remote: false);

      expect((await service.signIn('siti@contoh.com', 'Rahasia#123')).ok, isTrue);
      expect(AuthSession.current!.email, 'siti@contoh.com');
      AuthSession.logout();
      expect((await service.signIn('081355556666', 'Rahasia#123')).ok, isTrue);
    });

    test('kata sandi tidak tersimpan sebagai teks biasa', () async {
      await register(password: 'SangatRahasia#9');

      final stored = (await SharedPreferences.getInstance()).getString('local_accounts_v1')!;
      expect(stored, contains(phone));
      expect(stored, isNot(contains('SangatRahasia#9')));
      expect(stored, contains('"hash"'));
      expect(stored, contains('"salt"'));
    });

    test('nomor yang sudah terdaftar ditolak, juga setelah dibuka ulang', () async {
      await register();
      _restartApp();

      final result = await AccountService(remote: false).signUp(
        nama: 'Lain',
        phone: phone,
        password: 'Rahasia#123',
      );
      expect(result.error, 'Nomor telepon sudah terdaftar.');
    });

    test('ubah kata sandi ikut tersimpan', () async {
      await register();
      final service = AccountService(remote: false);
      await service.signIn(phone, 'Rahasia#123');
      expect((await service.changePassword(oldPassword: 'Rahasia#123', newPassword: 'Baru#45678')).ok,
          isTrue);
      _restartApp();

      expect((await AccountService(remote: false).signIn(phone, 'Rahasia#123')).ok,
          isFalse);
      expect((await AccountService(remote: false).signIn(phone, 'Baru#45678')).ok,
          isTrue);
    });

    test('keluar tidak menghapus akun; sesi akun hasil daftar dipulihkan', () async {
      await register();
      final service = AccountService(remote: false);
      await service.signIn(phone, 'Rahasia#123');
      _restartApp();

      expect(await AccountService(remote: false).restore(), isTrue);
      expect(AuthSession.current!.nama, 'Siti Aminah');

      await AccountService(remote: false).signOut();
      _restartApp();
      expect(await AccountService(remote: false).restore(), isFalse);
      expect((await AccountService(remote: false).signIn(phone, 'Rahasia#123')).ok,
          isTrue);
    });

    test('data akun tersimpan yang rusak diabaikan', () async {
      SharedPreferences.setMockInitialValues({'local_accounts_v1': '{rusak'});

      expect((await AccountService(remote: false).signIn('jamaah', 'jamaah123')).ok, isTrue);
    });

    test('akun tersimpan tidak bisa menjadi admin', () async {
      SharedPreferences.setMockInitialValues({
        'local_accounts_v1':
            '[{"id":"penyusup@x.com","nama":"P","email":"penyusup@x.com","phone":"","salt":"s","hash":"h","role":"admin"}]',
      });
      await AccountService(remote: false).restore();

      final account = AuthSession.localAccount('penyusup@x.com');
      expect(account, isNotNull);
      expect(account!.role, UserRole.jamaah);
    });
  });

  group('ProfilePages berdiri sendiri', () {
    testWidgets('tampilan berganti otomatis saat masuk dan keluar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ProfilePages())));
      expect(find.text('Anda belum masuk'), findsOneWidget);

      await AccountService(remote: false).signIn('admin', 'admin123');
      await tester.pump();
      expect(find.text('Anda belum masuk'), findsNothing);
      expect(find.text('Admin Masjid'), findsOneWidget);

      AuthSession.logout();
      await tester.pump();
      expect(find.text('Anda belum masuk'), findsOneWidget);
    });

    testWidgets('akun tanpa email: Email tampil "-", boleh dikosongkan atau diisi',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = AccountService(remote: false);
      await service.signUp(nama: 'Siti Aminah', phone: '081311112222', password: 'Rahasia#123');
      await service.signIn('081311112222', 'Rahasia#123');
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ProfilePages())));
      await tester.pump();

      expect(find.text('-'), findsOneWidget);

      // Simpan dengan Email tetap kosong.
      await tester.tap(find.text('EDIT'));
      await tester.pump();
      expect(find.text('Opsional'), findsOneWidget);
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();
      expect(find.text('Profil berhasil diperbarui.'), findsOneWidget);
      expect(ProfileStore.instance.email, isEmpty);

      // Bila diisi, formatnya diperiksa.
      await tester.tap(find.text('EDIT'));
      await tester.pump();
      final emailField = find.widgetWithText(TextFormField, 'Opsional');
      await tester.enterText(emailField, 'bukan-email');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump();
      expect(find.text('Format email tidak valid'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), 'siti@contoh.com');
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();
      expect(ProfileStore.instance.email, 'siti@contoh.com');
      expect(find.text('siti@contoh.com'), findsOneWidget);
    });
  });
}
