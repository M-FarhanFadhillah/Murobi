import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/common/validators.dart';
import 'package:masjid/login/sign_up.dart';
import 'package:masjid/screens/profile/change_password_dialog.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
  });

  group('Validators', () {
    test('nama', () {
      expect(Validators.nama(''), 'Nama wajib diisi');
      expect(Validators.nama('  '), 'Nama wajib diisi');
      expect(Validators.nama('Al'), 'Nama minimal 3 karakter');
      expect(Validators.nama(' Ali '), isNull);
    });

    test('email', () {
      expect(Validators.email(''), 'Email wajib diisi');
      expect(Validators.email('bukan-email'), 'Format email tidak valid');
      expect(Validators.email('a@b'), 'Format email tidak valid');
      expect(Validators.email(' budi@contoh.com '), isNull);
    });

    test('nomor telepon: format Indonesia dan label pesan', () {
      expect(Validators.phone(''), 'Nomor telepon wajib diisi');
      expect(Validators.phone('', label: 'Nomor handphone'),
          'Nomor handphone wajib diisi');
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('0812345'), isNotNull);
      expect(Validators.phone('081234567890'), isNull);
      expect(Validators.phone('+6281234567890'), isNull);
    });

    test('kata sandi baru: panjang, huruf besar-kecil, angka, simbol', () {
      expect(Validators.password('Ab1!'), 'Kata sandi minimal 8 karakter');
      expect(Validators.password('abcdefg1!'), 'Gunakan huruf besar dan kecil');
      expect(Validators.password('Abcdefgh!'), 'Gunakan minimal 1 angka');
      expect(Validators.password('Abcdefg12'), 'Gunakan minimal 1 simbol');
      expect(Validators.password('Abcdef1!'), isNull);
    });

    test('required', () {
      expect(Validators.required(' ', 'Judul'), 'Judul wajib diisi');
      expect(Validators.required('Isi', 'Judul'), isNull);
    });
  });

  group('AuthSession.changePassword', () {
    test('mengganti kata sandi akun yang sedang masuk', () {
      AuthSession.login('jamaah', 'jamaah123');

      final error = AuthSession.changePassword(
        oldPassword: 'jamaah123',
        newPassword: 'Baru#12345',
      );
      expect(error, isNull);

      AuthSession.logout();
      expect(AuthSession.login('jamaah', 'jamaah123'), isFalse);
      expect(AuthSession.login('jamaah', 'Baru#12345'), isTrue);
    });

    test('menolak jika kata sandi lama salah atau belum masuk', () {
      expect(
        AuthSession.changePassword(oldPassword: 'x', newPassword: 'Baru#12345'),
        'Anda belum masuk.',
      );

      AuthSession.login('admin', 'admin123');
      expect(
        AuthSession.changePassword(
          oldPassword: 'salah',
          newPassword: 'Baru#12345',
        ),
        'Kata sandi lama salah.',
      );
      expect(AuthSession.login('admin', 'admin123'), isTrue);
    });

    test('menolak kata sandi baru yang sama dengan yang lama', () {
      AuthSession.login('admin', 'admin123');
      expect(
        AuthSession.changePassword(
          oldPassword: 'admin123',
          newPassword: 'admin123',
        ),
        'Kata sandi baru harus berbeda dari yang lama.',
      );
    });

    test('perubahan satu akun tidak memengaruhi akun lain', () {
      AuthSession.login('jamaah', 'jamaah123');
      AuthSession.changePassword(
        oldPassword: 'jamaah123',
        newPassword: 'Baru#12345',
      );

      expect(AuthSession.login('admin', 'admin123'), isTrue);
    });

    test('akun hasil pendaftaran juga dapat mengganti kata sandi', () {
      AuthSession.register(
        nama: 'Budi',
        phone: '081311112222',
        email: 'budi@contoh.com',
        password: 'Rahasia#123',
      );
      AuthSession.login('budi@contoh.com', 'Rahasia#123');

      expect(
        AuthSession.changePassword(
          oldPassword: 'Rahasia#123',
          newPassword: 'Baru#12345',
        ),
        isNull,
      );
      AuthSession.logout();
      expect(AuthSession.login('budi@contoh.com', 'Baru#12345'), isTrue);
    });
  });

  group('ChangePasswordDialog', () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<bool>(
                    context: context,
                    builder: (_) => const ChangePasswordDialog(),
                  ),
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
    }

    testWidgets('kolom kosong menampilkan pesan validasi', (tester) async {
      AuthSession.login('jamaah', 'jamaah123');
      await openDialog(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pump();

      expect(find.text('Kata sandi lama wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('kata sandi lama salah menampilkan pesan di bawah kolom',
        (tester) async {
      AuthSession.login('jamaah', 'jamaah123');
      await openDialog(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'salah');
      await tester.enterText(fields.at(1), 'Baru#12345');
      await tester.enterText(fields.at(2), 'Baru#12345');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pump();

      expect(find.text('Kata sandi lama salah.'), findsOneWidget);
      expect(find.text('Ubah Kata Sandi'), findsOneWidget); // dialog tetap
    });

    testWidgets('konfirmasi tidak sama ditolak', (tester) async {
      AuthSession.login('jamaah', 'jamaah123');
      await openDialog(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'jamaah123');
      await tester.enterText(fields.at(1), 'Baru#12345');
      await tester.enterText(fields.at(2), 'Beda#12345');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pump();

      expect(find.text('Konfirmasi kata sandi tidak sama'), findsOneWidget);
    });

    testWidgets('berhasil: dialog tertutup dan kata sandi berubah',
        (tester) async {
      AuthSession.login('jamaah', 'jamaah123');
      await openDialog(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'jamaah123');
      await tester.enterText(fields.at(1), 'Baru#12345');
      await tester.enterText(fields.at(2), 'Baru#12345');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Ubah Kata Sandi'), findsNothing);
      AuthSession.logout();
      expect(AuthSession.login('jamaah', 'Baru#12345'), isTrue);
    });
  });

  group('SignUpWidget', () {
    Future<void> pumpSignUp(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: const SignUpWidget(),
          routes: {'/login': (_) => const Scaffold(body: Text('LOGIN'))},
        ),
      );
    }

    final daftarButton = find.widgetWithText(ElevatedButton, 'Daftar');

    Future<void> fillForm(
      WidgetTester tester, {
      String nama = 'Budi Santoso',
      String phone = '081311112222',
      String email = 'budi@contoh.com',
      String password = 'Rahasia#123',
      String confirm = 'Rahasia#123',
    }) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), nama);
      await tester.enterText(fields.at(1), phone);
      await tester.enterText(fields.at(2), email);
      await tester.enterText(fields.at(3), password);
      await tester.enterText(fields.at(4), confirm);
    }

    testWidgets('formulir kosong menampilkan pesan validasi', (tester) async {
      await pumpSignUp(tester);

      await tester.tap(daftarButton);
      await tester.pump();

      expect(find.text('Nama wajib diisi'), findsOneWidget);
      expect(find.text('Nomor telepon wajib diisi'), findsOneWidget);
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi minimal 8 karakter'), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
    });

    testWidgets('kata sandi lemah dan konfirmasi berbeda ditolak',
        (tester) async {
      await pumpSignUp(tester);
      await fillForm(tester, password: 'lemah', confirm: 'beda');

      await tester.tap(daftarButton);
      await tester.pump();

      expect(find.text('Kata sandi minimal 8 karakter'), findsOneWidget);
      expect(find.text('Konfirmasi kata sandi tidak sama'), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
    });

    testWidgets('pendaftaran berhasil membuka halaman masuk', (tester) async {
      await pumpSignUp(tester);
      await fillForm(tester);

      await tester.tap(daftarButton);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      expect(AuthSession.login('budi@contoh.com', 'Rahasia#123'), isTrue);
    });

    testWidgets('email yang sudah terdaftar ditolak', (tester) async {
      AuthSession.register(
        nama: 'Budi Lama',
        phone: '081399990000',
        email: 'budi@contoh.com',
        password: 'Rahasia#123',
      );
      await pumpSignUp(tester);
      await fillForm(tester);

      await tester.tap(daftarButton);
      await tester.pump();

      expect(find.text('Email sudah terdaftar.'), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
    });
  });
}
