import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/screens/splashscreen.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/google_auth.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_server.dart';

// Pengguna yang sudah masuk tidak perlu masuk ulang: sesi disimpan di perangkat
// dan dipulihkan saat aplikasi dibuka lagi.

class _FakeGoogle implements GoogleAuthClient {
  @override
  Future<GoogleProfile?> signIn() async => const GoogleProfile(
        email: 'Siti@Gmail.com',
        name: 'Siti Aminah',
        idToken: 'x',
      );

  @override
  Future<void> signOut() async {}
}

// Meniru aplikasi ditutup lalu dibuka lagi: semua yang ada di memori hilang,
// hanya penyimpanan perangkat yang tersisa.
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

  group('Mode lokal', () {
    test('jamaah yang sudah masuk dipulihkan setelah aplikasi dibuka lagi', () async {
      expect((await AccountService(remote: false).signIn('jamaah', 'jamaah123')).ok, isTrue);
      _restartApp();

      expect(await AccountService(remote: false).restore(), isTrue);

      expect(AuthSession.current!.id, 'jamaah');
      expect(AuthSession.isAdmin, isFalse);
      expect(ProfileStore.instance.nama, 'Jamaah As-Syifa');
    });

    test('admin dipulihkan tetap sebagai admin', () async {
      await AccountService(remote: false).signIn('admin', 'admin123');
      _restartApp();

      expect(await AccountService(remote: false).restore(), isTrue);

      expect(AuthSession.current!.id, 'admin');
      expect(AuthSession.isAdmin, isTrue);
      expect(AuthSession.canManageContent, isTrue);
    });

    test('masuk lewat email juga dipulihkan', () async {
      await AccountService(remote: false).signIn('jamaah@murobi.id', 'jamaah123');
      _restartApp();

      expect(await AccountService(remote: false).restore(), isTrue);
      expect(AuthSession.current!.id, 'jamaah');
    });

    test('perubahan profil ikut tampil setelah dipulihkan', () async {
      final service = AccountService(remote: false);
      await service.signIn('jamaah', 'jamaah123');
      await service.updateProfile(
        nama: 'Ahmad Fadhillah',
        email: 'ahmad@contoh.com',
        phone: '081234567890',
      );
      _restartApp();

      await AccountService(remote: false).restore();

      expect(ProfileStore.instance.nama, 'Ahmad Fadhillah');
      expect(ProfileStore.instance.email, 'ahmad@contoh.com');
    });

    test('kata sandi tidak ikut disimpan di perangkat', () async {
      await AccountService(remote: false).signIn('admin', 'admin123');

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('local_session_v1')!;
      expect(stored, isNot(contains('admin123')));
      expect(stored, contains('"id":"admin"'));
    });

    test('peran tidak bisa dinaikkan dengan mengubah data tersimpan', () async {
      SharedPreferences.setMockInitialValues({
        'local_session_v1':
            '{"id":"penyusup","nama":"Penyusup","email":"x@y.com","phone":"","role":"admin"}',
      });

      expect(await AccountService(remote: false).restore(), isTrue);

      expect(AuthSession.current!.nama, 'Penyusup');
      expect(AuthSession.isAdmin, isFalse);
    });

    test('akun Google (mode lokal) dipulihkan sebagai jamaah', () async {
      await AccountService(remote: false, google: _FakeGoogle()).signInWithGoogle();
      _restartApp();

      expect(await AccountService(remote: false).restore(), isTrue);

      expect(AuthSession.current!.email, 'siti@gmail.com');
      expect(AuthSession.current!.nama, 'Siti Aminah');
      expect(AuthSession.isAdmin, isFalse);
    });

    test('setelah keluar, aplikasi kembali meminta masuk', () async {
      final service = AccountService(remote: false, google: _FakeGoogle());
      await service.signIn('jamaah', 'jamaah123');
      await service.signOut();
      _restartApp();

      expect(await AccountService(remote: false).restore(), isFalse);
      expect(AuthSession.current, isNull);
      expect((await SharedPreferences.getInstance()).getString('local_session_v1'), isNull);
    });

    test('tanpa sesi tersimpan tidak ada yang dipulihkan', () async {
      expect(await AccountService(remote: false).restore(), isFalse);
      expect(AuthSession.current, isNull);
    });

    test('data sesi rusak diabaikan dan dihapus', () async {
      SharedPreferences.setMockInitialValues({'local_session_v1': '{rusak'});

      expect(await AccountService(remote: false).restore(), isFalse);
      expect((await SharedPreferences.getInstance()).getString('local_session_v1'), isNull);
    });
  });

  group('Mode server', () {
    test('tanpa internet, akun terakhir tetap masuk dan token dipertahankan', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 'tok-1', 'user': userJson(admin: true)});
        }
        return jsonResponse({'user': userJson(admin: true)});
      });
      await AccountService(api: server.api, remote: true).signIn('ahmad@gmail.com', 'x');
      _restartApp();

      final offline = FakeServer(FakeServer.offline);
      final service = AccountService(api: offline.api, remote: true);
      expect(await service.restore(), isTrue);

      expect(AuthSession.current!.nama, 'Ahmad Al Farizi');
      expect(AuthSession.isAdmin, isTrue);
      expect(offline.api.token, 'tok-1');
      expect((await SharedPreferences.getInstance()).getString('api_token_v1'), 'tok-1');
    });

    test('pemulihan online memperbarui data akun yang tersimpan', () async {
      SharedPreferences.setMockInitialValues({'api_token_v1': 'tok'});
      final online = FakeServer((_) => jsonResponse({'user': userJson(name: 'Nama Baru')}));
      expect(await AccountService(api: online.api, remote: true).restore(), isTrue);
      _restartApp();

      final offline = FakeServer(FakeServer.offline);
      expect(await AccountService(api: offline.api, remote: true).restore(), isTrue);
      expect(AuthSession.current!.nama, 'Nama Baru');
    });

    test('token ditolak menghapus token dan data akun tersimpan', () async {
      SharedPreferences.setMockInitialValues({
        'api_token_v1': 'dicabut',
        'api_user_v1': '{"id":3,"name":"A","email":"a@b.com","no_hp":"","is_admin":false,"status":1}',
      });
      final server = FakeServer((_) => jsonResponse({'message': 'x'}, 401));

      expect(await AccountService(api: server.api, remote: true).restore(), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('api_token_v1'), isNull);
      expect(prefs.getString('api_user_v1'), isNull);
      expect(AuthSession.current, isNull);
    });

    test('keluar menghapus data akun tersimpan', () async {
      final server = FakeServer((request) => request.url.path == '/api/login'
          ? jsonResponse({'token': 't', 'user': userJson()})
          : jsonResponse({'message': 'ok'}));
      final service = AccountService(api: server.api, remote: true, google: _FakeGoogle());
      await service.signIn('ahmad@gmail.com', 'x');
      expect((await SharedPreferences.getInstance()).getString('api_user_v1'), isNotNull);

      await service.signOut();

      expect((await SharedPreferences.getInstance()).getString('api_user_v1'), isNull);
    });
  });

  group('SplashScreen (mode lokal)', () {
    Future<void> pumpSplash(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(accountService: AccountService(remote: false)),
          routes: {'/dashboard': (_) => const Scaffold(body: Text('DASHBOARD'))},
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }

    testWidgets('sudah pernah masuk: langsung ke beranda', (tester) async {
      await AccountService(remote: false).signIn('jamaah', 'jamaah123');
      _restartApp();

      await pumpSplash(tester);

      expect(find.text('DASHBOARD'), findsOneWidget);
    });

    testWidgets('belum pernah masuk: tetap ke beranda sebagai tamu', (tester) async {
      await pumpSplash(tester);

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.text('Masuk Akun'), findsNothing);
      expect(AuthSession.current, isNull);
    });
  });
}
