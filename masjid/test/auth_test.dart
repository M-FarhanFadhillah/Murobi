import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/login/login.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.logout();
  });

  group('AuthSession', () {
    test('masuk dengan ID, email, atau nomor HP', () {
      expect(AuthSession.login('jamaah', 'jamaah123'), isTrue);
      expect(AuthSession.current?.nama, 'Jamaah As-Syifa');

      expect(AuthSession.login('jamaah@murobi.id', 'jamaah123'), isTrue);
      expect(AuthSession.login('0812345678', 'jamaah123'), isTrue);
    });

    test('ID tidak peka huruf besar-kecil, kata sandi peka', () {
      expect(AuthSession.login('  JAMAAH  ', 'jamaah123'), isTrue);

      AuthSession.logout();
      expect(AuthSession.login('jamaah', 'JAMAAH123'), isFalse);
      expect(AuthSession.current, isNull);
    });

    test('kata sandi atau ID salah ditolak tanpa mengubah sesi', () {
      expect(AuthSession.login('jamaah', 'salah'), isFalse);
      expect(AuthSession.login('tidak-ada', 'jamaah123'), isFalse);
      expect(AuthSession.current, isNull);
    });

    test('admin dikenali, jamaah bukan admin', () {
      AuthSession.login('admin', 'admin123');
      expect(AuthSession.isAdmin, isTrue);
      expect(AuthSession.current?.roleLabel, 'Admin Masjid');

      AuthSession.login('jamaah', 'jamaah123');
      expect(AuthSession.isAdmin, isFalse);
      expect(AuthSession.current?.roleLabel, 'Jamaah');
    });

    test('keluar menghapus sesi', () {
      AuthSession.login('admin', 'admin123');
      AuthSession.logout();

      expect(AuthSession.current, isNull);
      expect(AuthSession.isAdmin, isFalse);
    });

    test('akun baru dapat masuk dengan email; email dan nomor ganda ditolak',
        () {
      final error = AuthSession.register(
        nama: 'Budi Santoso',
        phone: '081311112222',
        email: 'Budi@Contoh.com',
        password: 'Rahasia#123',
      );
      expect(error, isNull);

      expect(AuthSession.login('budi@contoh.com', 'Rahasia#123'), isTrue);
      expect(AuthSession.current?.nama, 'Budi Santoso');
      expect(AuthSession.isAdmin, isFalse);

      expect(
        AuthSession.register(
          nama: 'Budi Lain',
          phone: '081399990000',
          email: 'budi@contoh.com',
          password: 'Rahasia#123',
        ),
        'Email sudah terdaftar.',
      );
      expect(
        AuthSession.register(
          nama: 'Budi Lain',
          phone: '081311112222',
          email: 'lain@contoh.com',
          password: 'Rahasia#123',
        ),
        'Nomor telepon sudah terdaftar.',
      );
    });
  });

  group('LoginWidget', () {
    Future<void> pumpLogin(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: const LoginWidget(),
          routes: {
            '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
            '/signup': (_) => const Scaffold(body: Text('DAFTAR')),
          },
        ),
      );
    }

    final masukButton = find.widgetWithText(ElevatedButton, 'Masuk');

    testWidgets('kolom kosong menampilkan pesan validasi', (tester) async {
      await pumpLogin(tester);

      await tester.tap(masukButton);
      await tester.pump();

      expect(find.text('ID wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
    });

    testWidgets('kata sandi salah menampilkan pesan dan tetap di login',
        (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'jamaah');
      await tester.enterText(find.byType(TextFormField).at(1), 'salah');
      await tester.tap(masukButton);
      await tester.pumpAndSettle();

      expect(find.text('ID atau kata sandi salah.'), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
      expect(AuthSession.current, isNull);
    });

    testWidgets('login benar membuka dashboard dan memuat profil',
        (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
      await tester.tap(masukButton);
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(AuthSession.isAdmin, isTrue);
      expect(ProfileStore.instance.nama, 'Admin Masjid As-Syifa');
    });

    testWidgets('lupa kata sandi: Kirim aktif setelah diisi lalu muncul konfirmasi',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Lupa kata sandi'));
      await tester.pumpAndSettle();
      expect(find.text('Masukkan Email/nomor yang terdaftar'), findsOneWidget);

      final kirim = find.widgetWithText(ElevatedButton, 'Kirim');
      expect(tester.widget<ElevatedButton>(kirim).onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, 'uptik@gmail.com');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(kirim).onPressed, isNotNull);

      await tester.tap(kirim);
      await tester.pumpAndSettle();
      expect(find.textContaining('Link verifikasi berhasil dikirim'),
          findsOneWidget);
    });

    testWidgets('tab Daftar membuka halaman daftar', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Daftar').first);
      await tester.pumpAndSettle();

      expect(find.text('DAFTAR'), findsOneWidget);
    });
  });
}
