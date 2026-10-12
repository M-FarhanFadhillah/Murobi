import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/login/login.dart';
import 'package:masjid/login/sign_up.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/google_auth.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_server.dart';

// Pengganti google_sign_in: hasilnya diatur per tes.
class FakeGoogle implements GoogleAuthClient {
  FakeGoogle([this.profile]);

  GoogleProfile? profile;
  Object? error;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<GoogleProfile?> signIn() async {
    signInCalls++;
    if (error != null) throw error!;
    return profile;
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

const _siti = GoogleProfile(
  email: 'Siti@Gmail.com',
  name: 'Siti Aminah',
  photoUrl: 'https://lh3.example/siti.jpg',
  idToken: 'id-token-asli',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
    ProfileStore.instance.clear();
  });

  tearDown(() => ApiConfig.overrideBaseUrl(null));

  group('AccountService.signInWithGoogle (lokal)', () {
    test('profil Google menjadi akun jamaah di perangkat', () async {
      final google = FakeGoogle(_siti);
      final service = AccountService(remote: false, google: google);

      final result = await service.signInWithGoogle();

      expect(result.ok, isTrue);
      final account = AuthSession.current!;
      expect(account.email, 'siti@gmail.com');
      expect(account.nama, 'Siti Aminah');
      expect(account.role, UserRole.jamaah);
      expect(account.isRemote, isFalse);
      expect(ProfileStore.instance.nama, 'Siti Aminah');
      expect(ProfileStore.instance.photoUrl, 'https://lh3.example/siti.jpg');
    });

    test('tanpa nama, bagian depan email dipakai', () async {
      final service = AccountService(
        remote: false,
        google: FakeGoogle(
          const GoogleProfile(email: 'budi@gmail.com', name: '', idToken: 'x'),
        ),
      );

      await service.signInWithGoogle();

      expect(AuthSession.current!.nama, 'budi');
    });

    test('email yang sama dengan akun demo tidak menjadikannya admin', () async {
      final service = AccountService(
        remote: false,
        google: FakeGoogle(
          const GoogleProfile(
            email: 'admin@murobi.id',
            name: 'Penyamar',
            idToken: 'x',
          ),
        ),
      );

      await service.signInWithGoogle();

      expect(AuthSession.isAdmin, isFalse);
    });

    test('dibatalkan pengguna: tidak ada sesi', () async {
      final service = AccountService(remote: false, google: FakeGoogle());

      final result = await service.signInWithGoogle();

      expect(result.ok, isFalse);
      expect(result.error, 'Login Google dibatalkan.');
      expect(AuthSession.current, isNull);
    });

    test('ID klien belum diisi: pesan jelas', () async {
      final google = FakeGoogle()..error = const GoogleNotConfigured();
      final service = AccountService(remote: false, google: google);

      final result = await service.signInWithGoogle();

      expect(result.error, contains('belum dikonfigurasi'));
      expect(AuthSession.current, isNull);
    });

    test('kesalahan lain dari Google: pesan umum, tidak melempar', () async {
      final google = FakeGoogle()..error = StateError('network_error');
      final service = AccountService(remote: false, google: google);

      final result = await service.signInWithGoogle();

      expect(result.error, startsWith('Login Google gagal.'));
    });

    test('keluar juga menutup sesi Google', () async {
      final google = FakeGoogle(_siti);
      final service = AccountService(remote: false, google: google);
      await service.signInWithGoogle();

      await service.signOut();

      expect(google.signOutCalls, 1);
      expect(AuthSession.current, isNull);
    });
  });

  group('AccountService.signInWithGoogle (server)', () {
    test('token dikirim ke server, token sesi disimpan', () async {
      final server = FakeServer((request) => jsonResponse({
            'token': 'tok-google',
            'user': userJson(name: 'Siti Aminah', email: 'siti@gmail.com', noHp: ''),
          }));
      final service = AccountService(
        api: server.api,
        remote: true,
        google: FakeGoogle(_siti),
      );

      final result = await service.signInWithGoogle();

      expect(result.ok, isTrue);
      expect(server.last.method, 'POST');
      expect(server.last.url.path, '/api/auth/google');
      expect(server.lastBody['id_token'], 'id-token-asli');
      expect(server.lastBody.containsKey('access_token'), isFalse);
      expect(AuthSession.current!.isRemote, isTrue);
      expect(AuthSession.current!.email, 'siti@gmail.com');
      expect(server.api.token, 'tok-google');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('api_token_v1'), 'tok-google');
    });

    test('di web hanya access token yang dikirim', () async {
      final server = FakeServer((request) =>
          jsonResponse({'token': 't', 'user': userJson()}));
      final service = AccountService(
        api: server.api,
        remote: true,
        google: FakeGoogle(
          const GoogleProfile(
            email: 'a@b.com',
            name: 'Ab',
            accessToken: 'akses-web',
          ),
        ),
      );

      await service.signInWithGoogle();

      expect(server.lastBody['access_token'], 'akses-web');
      expect(server.lastBody.containsKey('id_token'), isFalse);
    });

    test('ditolak server: pesan server tampil dan tidak ada sesi', () async {
      final server = FakeServer((request) => jsonResponse(
            {'message': 'Akun Google tidak dapat diverifikasi.'},
            401,
          ));
      final service = AccountService(
        api: server.api,
        remote: true,
        google: FakeGoogle(_siti),
      );

      final result = await service.signInWithGoogle();

      expect(result.error, 'Akun Google tidak dapat diverifikasi.');
      expect(AuthSession.current, isNull);
      expect(server.api.token, isNull);
    });

    test('akun menunggu persetujuan admin ditolak dengan pesan server', () async {
      final server = FakeServer((request) => jsonResponse(
            {'message': 'Akun Anda menunggu persetujuan admin.'},
            403,
          ));
      final service = AccountService(
        api: server.api,
        remote: true,
        google: FakeGoogle(_siti),
      );

      final result = await service.signInWithGoogle();

      expect(result.error, 'Akun Anda menunggu persetujuan admin.');
    });

    test('server mati: pesan jaringan', () async {
      final server = FakeServer(FakeServer.offline);
      final service = AccountService(
        api: server.api,
        remote: true,
        google: FakeGoogle(_siti),
      );

      final result = await service.signInWithGoogle();

      expect(result.error, contains('Tidak dapat terhubung'));
    });

    test('server belum mengatur Google: pesan server diteruskan', () async {
      final server = FakeServer((request) => jsonResponse(
            {'message': 'Login Google belum dikonfigurasi di server.'},
            503,
          ));
      final service = AccountService(
        api: server.api,
        remote: true,
        google: FakeGoogle(_siti),
      );

      final result = await service.signInWithGoogle();

      expect(result.error, 'Login Google belum dikonfigurasi di server.');
    });
  });

  group('Tombol Google', () {
    final googleButton = find.byType(FaIcon);

    Future<void> pump(WidgetTester tester, Widget home) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: home,
        routes: {'/dashboard': (_) => const Scaffold(body: Text('DASHBOARD'))},
      ));
    }

    testWidgets('halaman masuk: berhasil menuju dashboard', (tester) async {
      final google = FakeGoogle(_siti);
      await pump(
        tester,
        LoginWidget(accountService: AccountService(remote: false, google: google)),
      );

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(google.signInCalls, 1);
    });

    testWidgets('halaman masuk: dibatalkan menampilkan pesan, tetap di halaman',
        (tester) async {
      await pump(
        tester,
        LoginWidget(
          accountService: AccountService(remote: false, google: FakeGoogle()),
        ),
      );

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      expect(find.text('Login Google dibatalkan.'), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
    });

    testWidgets('halaman masuk: belum dikonfigurasi menampilkan petunjuk',
        (tester) async {
      final google = FakeGoogle()..error = const GoogleNotConfigured();
      await pump(
        tester,
        LoginWidget(accountService: AccountService(remote: false, google: google)),
      );

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('GOOGLE_CLIENT_ID'), findsOneWidget);
    });

    testWidgets('halaman daftar: Google membuat akun dan masuk', (tester) async {
      final google = FakeGoogle(_siti);
      await pump(
        tester,
        SignUpWidget(accountService: AccountService(remote: false, google: google)),
      );

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(AuthSession.current!.email, 'siti@gmail.com');
    });

    testWidgets('ketukan ganda tidak membuka Google dua kali', (tester) async {
      final google = FakeGoogle(_siti);
      await pump(
        tester,
        LoginWidget(accountService: AccountService(remote: false, google: google)),
      );

      await tester.tap(googleButton);
      await tester.tap(googleButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(google.signInCalls, 1);
    });
  });
}
