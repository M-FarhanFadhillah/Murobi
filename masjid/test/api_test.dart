import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/banner_store.dart';
import 'package:masjid/services/edukasi_store.dart';
import 'package:masjid/services/kegiatan_store.dart';
import 'package:masjid/services/masjid_store.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_server.dart';

final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
    ProfileStore.instance.clear();
  });

  group('ApiConfig', () {
    tearDown(() => ApiConfig.overrideBaseUrl(null));

    test('tanpa alamat server aplikasi berjalan dalam mode lokal', () {
      expect(ApiConfig.enabled, isFalse);
      expect(ApiConfig.baseUrl, isEmpty);
    });

    test('alamat dirapikan: spasi dan garis miring akhir dibuang', () {
      ApiConfig.overrideBaseUrl(' http://10.0.2.2:8000/ ');
      expect(ApiConfig.enabled, isTrue);
      expect(ApiConfig.baseUrl, 'http://10.0.2.2:8000');
    });
  });

  group('ApiClient dan MurobiApi', () {
    test('mengirim Accept JSON dan token Bearer', () async {
      final server = FakeServer((_) => jsonResponse({'user': userJson()}));
      server.api.token = 'abc123';

      await server.api.me();

      expect(server.last.url.toString(), 'http://test/api/me');
      expect(server.last.headers['Accept'], 'application/json');
      expect(server.last.headers['Authorization'], 'Bearer abc123');
    });

    test('tanpa token tidak mengirim header Authorization', () async {
      final server = FakeServer((_) => jsonResponse([]));

      await server.api.banners();

      expect(server.last.headers.containsKey('Authorization'), isFalse);
    });

    test('kode 422 memakai pesan kolom pertama dari server', () async {
      final server = FakeServer((_) => jsonResponse({
            'message': 'The given data was invalid.',
            'errors': {
              'email': ['Email sudah terdaftar.'],
              'no_hp': ['Nomor telepon sudah terdaftar.'],
            },
          }, 422));

      final error = await server.api
          .register(name: 'Budi', email: 'a@b.c', noHp: '08123', password: 'x')
          .then<ApiException?>((_) => null)
          .onError<ApiException>((e, _) => e);

      expect(error, isNotNull);
      expect(error!.statusCode, 422);
      expect(error.message, 'Email sudah terdaftar.');
      expect(error.errors['no_hp'], ['Nomor telepon sudah terdaftar.']);
      expect(error.isNetworkError, isFalse);
    });

    test('kode 401 tanpa isi memakai pesan bawaan', () async {
      final server = FakeServer((_) => http.Response('', 401));

      await expectLater(
        server.api.me(),
        throwsA(isA<ApiException>()
            .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
            .having((e) => e.message, 'message',
                'Sesi berakhir. Silakan masuk lagi.')),
      );
    });

    test('kode 429 (pembatasan) memakai pesan Indonesia, bukan teks Laravel',
        () async {
      final server =
          FakeServer((_) => jsonResponse({'message': 'Too Many Attempts.'}, 429));

      await expectLater(
        server.api.me(),
        throwsA(isA<ApiException>().having((e) => e.message, 'message',
            'Terlalu banyak percobaan. Coba lagi sebentar lagi.')),
      );
    });

    test('kegagalan server berisi HTML tidak membuat crash', () async {
      final server = FakeServer((_) => http.Response('<html>Error</html>', 500));

      await expectLater(
        server.api.me(),
        throwsA(isA<ApiException>().having((e) => e.message, 'message',
            'Terjadi kesalahan pada server (kode 500).')),
      );
    });

    test('server tidak terjangkau menjadi kesalahan jaringan', () async {
      final server = FakeServer(FakeServer.offline);

      await expectLater(
        server.api.me(),
        throwsA(isA<ApiException>()
            .having((e) => e.isNetworkError, 'isNetworkError', isTrue)
            .having((e) => e.message, 'message', ApiClient.networkMessage)),
      );
    });

    test('permintaan yang terlalu lama dibatalkan sebagai kesalahan jaringan',
        () async {
      final server = FakeServer(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 30),
      );

      await expectLater(
        server.api.me(),
        throwsA(isA<ApiException>()
            .having((e) => e.isNetworkError, 'isNetworkError', isTrue)),
      );
    });

    test('GET diulang sekali jika koneksi putus di tengah jalan', () async {
      var attempts = 0;
      final server = FakeServer((request) {
        attempts++;
        if (attempts == 1) return FakeServer.offline(request);
        return jsonResponse([
          {'id': 1, 'judul': 'Berhasil di percobaan kedua', 'cover_url': 'http://x/a.jpg'},
        ]);
      });

      final banners = await server.api.banners();

      expect(banners.single.judul, 'Berhasil di percobaan kedua');
      expect(server.requests, hasLength(2));
    });

    test('GET yang gagal dua kali menjadi kesalahan jaringan (2 permintaan)',
        () async {
      final server = FakeServer(FakeServer.offline);

      await expectLater(
        server.api.masjids(),
        throwsA(isA<ApiException>()
            .having((e) => e.isNetworkError, 'isNetworkError', isTrue)),
      );
      expect(server.requests, hasLength(2));
    });

    test('waktu habis tidak diulang agar pengguna tidak menunggu dua kali',
        () async {
      final server = FakeServer(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 30),
      );

      await expectLater(server.api.banners(), throwsA(isA<ApiException>()));
      expect(server.requests, hasLength(1));
    });

    test('kesalahan server (bukan putus koneksi) tidak diulang', () async {
      final server = FakeServer((_) => http.Response('', 404));

      await expectLater(server.api.banners(), throwsA(isA<ApiException>()));
      expect(server.requests, hasLength(1));
    });

    test('POST tidak pernah diulang otomatis (mencegah pendaftaran ganda)',
        () async {
      final server = FakeServer(FakeServer.offline);

      await expectLater(
        server.api.register(
          name: 'Budi',
          email: 'budi@contoh.com',
          noHp: '081311112222',
          password: 'Rahasia#123',
        ),
        throwsA(isA<ApiException>()),
      );
      expect(server.requests, hasLength(1));
    });

    test('daftar dari server dipetakan ke model', () async {
      final server = FakeServer((request) {
        switch (request.url.path) {
          case '/api/banner':
            return jsonResponse([
              {'id': 1, 'judul': 'A', 'cover_url': 'http://test/api/files/a.jpg'},
              {'id': 2, 'judul': 'B', 'cover_url': null},
            ]);
          case '/api/masjid':
            return jsonResponse([
              {
                'id': 8,
                'masjid_name': 'Al-Fajri',
                'alamat': 'Rajabasa, Bandar Lampung',
                'masjid_pict_url': null,
              },
            ]);
          case '/api/activity':
            return jsonResponse([
              {
                'id': 5,
                'masjid_id': 8,
                'activity_name': 'Kajian Subuh',
                'deskripsi': 'Setiap Subuh',
                'created_at': '2026-10-01T05:00:00.000000Z',
                'pict_url': 'http://test/api/files/k.jpg',
              },
            ]);
          case '/api/edu/book':
            return jsonResponse([
              {
                'id': 1,
                'judul': 'Buku',
                'kategori': 2,
                'deskripsi': 'd',
                'created_at': '2026-10-01T05:00:00.000000Z',
                'content_url': 'http://test/api/files/konten-edukasi/b.pdf',
              },
            ]);
        }
        return http.Response('', 404);
      });

      final banners = await server.api.banners();
      expect(banners.map((e) => e.judul), ['A', 'B']);
      expect(banners.last.coverUrl, isNull);

      final masjids = await server.api.masjids();
      expect(masjids.single.nama, 'Al-Fajri');
      expect(masjids.single.alamat, 'Rajabasa, Bandar Lampung');

      final activities = await server.api.activities(masjidId: 8);
      expect(server.last.url.queryParameters, {'masjid_id': '8'});
      expect(activities.single.nama, 'Kajian Subuh');
      expect(activities.single.deskripsi, 'Setiap Subuh');
      expect(activities.single.createdAt.toUtc(), DateTime.utc(2026, 10, 1, 5));

      final books = await server.api.books();
      expect(books.single.kategori, 2);
      expect(books.single.isVideo, isFalse);
    });

    test('field yang janggal diberi nilai bawaan, bukan error', () async {
      final server = FakeServer((_) => jsonResponse([
            {'id': '7', 'judul': null, 'kategori': 'x', 'created_at': 'rusak'},
            'bukan-objek',
          ]));

      final books = await server.api.books();

      expect(books, hasLength(1)); // elemen bukan objek dilewati
      expect(books.single.id, 7);
      expect(books.single.judul, '');
      expect(books.single.kategori, 0);
    });

    test('respons bukan larik ditolak dengan pesan yang jelas', () async {
      final server = FakeServer((_) => jsonResponse({'message': 'aneh'}));

      await expectLater(
        server.api.banners(),
        throwsA(isA<ApiException>().having(
            (e) => e.message, 'message', 'Respons server tidak dikenali.')),
      );
    });

    test('saat server mati daftar terakhir yang berhasil dipakai (cache)',
        () async {
      final server = FakeServer((_) => jsonResponse([
            {'id': 1, 'judul': 'Banner tersimpan', 'cover_url': 'http://x/a.jpg'},
          ]));
      await server.api.banners();

      server.handler = FakeServer.offline;
      final cached = await server.api.banners();

      expect(cached.single.judul, 'Banner tersimpan');
    });

    test('server error 5xx juga memakai cache, tetapi 404 tidak', () async {
      final server = FakeServer((_) => jsonResponse([
            {'id': 1, 'judul': 'Tersimpan', 'cover_url': 'http://x/a.jpg'},
          ]));
      await server.api.banners();

      server.handler = (_) => http.Response('boom', 503);
      expect((await server.api.banners()).single.judul, 'Tersimpan');

      server.handler = (_) => http.Response('', 404);
      await expectLater(server.api.banners(), throwsA(isA<ApiException>()));
    });

    test('cache dipisah per parameter (masjid_id)', () async {
      final server = FakeServer((request) => jsonResponse([
            {
              'id': 1,
              'masjid_id': int.parse(request.url.queryParameters['masjid_id']!),
              'activity_name': 'Kegiatan masjid ${request.url.queryParameters['masjid_id']}',
            },
          ]));
      await server.api.activities(masjidId: 1);
      await server.api.activities(masjidId: 2);

      server.handler = FakeServer.offline;

      expect((await server.api.activities(masjidId: 1)).single.nama,
          'Kegiatan masjid 1');
      expect((await server.api.activities(masjidId: 2)).single.nama,
          'Kegiatan masjid 2');
    });

    test('tanpa cache dan tanpa jaringan, kesalahan diteruskan', () async {
      final server = FakeServer(FakeServer.offline);

      await expectLater(
        server.api.masjids(),
        throwsA(isA<ApiException>()
            .having((e) => e.isNetworkError, 'isNetworkError', isTrue)),
      );
    });
  });

  group('AccountService (server)', () {
    AccountService serviceFor(FakeServer server) =>
        AccountService(api: server.api, remote: true);

    test('masuk berhasil: sesi, profil, dan token tersimpan', () async {
      final server = FakeServer((_) => jsonResponse({
            'token': 'tok-1',
            'token_type': 'Bearer',
            'user': userJson(photoUrl: 'http://test/api/files/profil-pict/f.jpg'),
          }));

      final result = await serviceFor(server).signIn('  ahmad@gmail.com ', 'Rahasia#123');

      expect(result.ok, isTrue);
      expect(server.last.method, 'POST');
      expect(server.last.url.path, '/api/login');
      expect(server.lastBody['login'], 'ahmad@gmail.com');
      expect(server.lastBody['password'], 'Rahasia#123');
      expect(server.api.token, 'tok-1');

      final account = AuthSession.current!;
      expect(account.isRemote, isTrue);
      expect(account.nama, 'Ahmad Al Farizi');
      expect(account.roleLabel, 'Jamaah');
      expect(ProfileStore.instance.email, 'ahmad@gmail.com');
      expect(ProfileStore.instance.photoUrl,
          'http://test/api/files/profil-pict/f.jpg');
      expect((await SharedPreferences.getInstance()).getString('api_token_v1'),
          'tok-1');
    });

    test('masuk sebagai admin menampilkan peran Admin Masjid', () async {
      final server = FakeServer((_) => jsonResponse({
            'token': 't',
            'user': userJson(admin: true, name: 'Master Admin'),
          }));

      await serviceFor(server).signIn('admin@gmail.com', 'x');

      expect(AuthSession.isAdmin, isTrue);
      expect(AuthSession.current!.roleLabel, 'Admin Masjid');
    });

    test('masuk gagal: pesan dari server dan sesi tetap kosong', () async {
      final server = FakeServer(
          (_) => jsonResponse({'message': 'ID atau kata sandi salah.'}, 401));

      final result = await serviceFor(server).signIn('x', 'y');

      expect(result.ok, isFalse);
      expect(result.error, 'ID atau kata sandi salah.');
      expect(AuthSession.current, isNull);
      expect(server.api.token, isNull);
    });

    test('akun yang menunggu persetujuan tidak bisa masuk', () async {
      final server = FakeServer((_) => jsonResponse(
          {'message': 'Akun Anda menunggu persetujuan admin.'}, 403));

      final result = await serviceFor(server).signIn('a@b.c', 'x');

      expect(result.error, 'Akun Anda menunggu persetujuan admin.');
      expect(AuthSession.current, isNull);
    });

    test('masuk tanpa jaringan memberi pesan jaringan', () async {
      final server = FakeServer(FakeServer.offline);

      final result = await serviceFor(server).signIn('a@b.c', 'x');

      expect(result.error, ApiClient.networkMessage);
    });

    test('daftar berhasil mengembalikan pesan dari server', () async {
      final server = FakeServer((_) => jsonResponse({
            'message': 'Pendaftaran berhasil. Akun Anda menunggu persetujuan admin.',
            'user': userJson(status: 0),
          }, 201));

      final result = await serviceFor(server).signUp(
        nama: ' Budi Santoso ',
        phone: '081311112222',
        email: 'budi@contoh.com',
        password: 'Rahasia#123',
      );

      expect(result.ok, isTrue);
      expect(result.message, contains('menunggu persetujuan admin'));
      expect(server.lastBody, {
        'name': 'Budi Santoso',
        'email': 'budi@contoh.com',
        'no_hp': '081311112222',
        'password': 'Rahasia#123',
      });
      expect(AuthSession.current, isNull); // belum masuk sebelum disetujui
    });

    test('daftar dengan email yang sudah ada menampilkan pesan server', () async {
      final server = FakeServer((_) => jsonResponse({
            'message': 'invalid',
            'errors': {'email': ['Email sudah terdaftar.']},
          }, 422));

      final result = await serviceFor(server).signUp(
        nama: 'Budi',
        phone: '081311112222',
        email: 'budi@contoh.com',
        password: 'Rahasia#123',
      );

      expect(result.error, 'Email sudah terdaftar.');
    });

    test('pulihkan sesi dari token tersimpan', () async {
      SharedPreferences.setMockInitialValues({'api_token_v1': 'tok-lama'});
      final server = FakeServer((_) => jsonResponse({'user': userJson()}));

      final restored = await serviceFor(server).restore();

      expect(restored, isTrue);
      expect(server.last.headers['Authorization'], 'Bearer tok-lama');
      expect(AuthSession.current!.nama, 'Ahmad Al Farizi');
    });

    test('tanpa token tersimpan tidak ada yang dipulihkan', () async {
      final server = FakeServer((_) => jsonResponse({'user': userJson()}));

      expect(await serviceFor(server).restore(), isFalse);
      expect(server.requests, isEmpty);
    });

    test('token ditolak server dihapus dari perangkat', () async {
      SharedPreferences.setMockInitialValues({'api_token_v1': 'dicabut'});
      final server = FakeServer((_) => jsonResponse({'message': 'x'}, 401));

      expect(await serviceFor(server).restore(), isFalse);

      expect((await SharedPreferences.getInstance()).getString('api_token_v1'),
          isNull);
      expect(AuthSession.current, isNull);
    });

    test('tanpa jaringan token dipertahankan untuk dicoba lagi nanti', () async {
      SharedPreferences.setMockInitialValues({'api_token_v1': 'masih-sah'});
      final server = FakeServer(FakeServer.offline);

      expect(await serviceFor(server).restore(), isFalse);

      expect((await SharedPreferences.getInstance()).getString('api_token_v1'),
          'masih-sah');
    });

    test('ubah data diri dikirim ke server dan profil diperbarui', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return jsonResponse({
          'user': userJson(name: 'Ahmad Fadhillah', noHp: '+6281999999999'),
        });
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      final result = await service.updateProfile(
        nama: 'Ahmad Fadhillah',
        email: 'ahmad@gmail.com',
        phone: '+6281999999999',
      );

      expect(result.ok, isTrue);
      expect(server.last.method, 'PATCH');
      expect(server.last.url.path, '/api/me');
      expect(server.last.headers['Authorization'], 'Bearer t');
      expect(server.lastBody['no_hp'], '+6281999999999');
      expect(ProfileStore.instance.nama, 'Ahmad Fadhillah');
      expect(ProfileStore.instance.phone, '+6281999999999');
      expect(AuthSession.current!.nama, 'Ahmad Fadhillah');
    });

    test('ubah data diri ditolak: profil tidak berubah, pesan dari server',
        () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return jsonResponse({
          'message': 'invalid',
          'errors': {'email': ['Email sudah terdaftar.']},
        }, 422);
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      final result = await service.updateProfile(
        nama: 'Ahmad',
        email: 'lain@gmail.com',
        phone: '081994851234',
      );

      expect(result.error, 'Email sudah terdaftar.');
      expect(ProfileStore.instance.email, 'ahmad@gmail.com');
    });

    test('sesi kedaluwarsa saat ubah data mengakhiri sesi', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return jsonResponse({'message': 'Unauthenticated.'}, 401);
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      final result = await service.updateProfile(
        nama: 'Ahmad',
        email: 'ahmad@gmail.com',
        phone: '081994851234',
      );

      expect(result.ok, isFalse);
      expect(AuthSession.current, isNull);
      expect(server.api.token, isNull);
      expect((await SharedPreferences.getInstance()).getString('api_token_v1'),
          isNull);
    });

    test('unggah foto memakai multipart dan menampilkan foto baru', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return jsonResponse({
          'user': userJson(photoUrl: 'http://test/api/files/profil-pict/baru.jpg'),
        });
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      final result = await service.updatePhoto(_png);

      expect(result.ok, isTrue);
      expect(server.last.url.path, '/api/me/photo');
      expect(server.last.headers['content-type'],
          startsWith('multipart/form-data'));
      // Isi berkas biner, jadi dibaca per byte (bukan UTF-8).
      final body = latin1.decode(server.last.bodyBytes);
      expect(body, contains('name="profil_pict"'));
      expect(body, contains('filename="foto.jpg"'));
      expect(body, contains('PNG'));
      expect(ProfileStore.instance.photoBytes, _png);
      expect(ProfileStore.instance.photoUrl,
          'http://test/api/files/profil-pict/baru.jpg');
      expect(ProfileStore.instance.photoImage, isNotNull);
    });

    test('ubah kata sandi: berhasil, salah (422), dan admin (403)', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return jsonResponse({'message': 'Kata sandi berhasil diubah.'});
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      expect(
        (await service.changePassword(
                oldPassword: 'Lama#1234', newPassword: 'Baru#12345'))
            .ok,
        isTrue,
      );
      expect(server.lastBody, {
        'old_password': 'Lama#1234',
        'new_password': 'Baru#12345',
      });

      server.handler = (_) => jsonResponse({
            'message': 'invalid',
            'errors': {'old_password': ['Kata sandi lama salah.']},
          }, 422);
      expect(
        (await service.changePassword(
                oldPassword: 'salah', newPassword: 'Baru#12345'))
            .error,
        'Kata sandi lama salah.',
      );

      server.handler = (_) => jsonResponse(
          {'message': 'Kata sandi admin diubah lewat panel web.'}, 403);
      expect(
        (await service.changePassword(
                oldPassword: 'a', newPassword: 'Baru#12345'))
            .error,
        'Kata sandi admin diubah lewat panel web.',
      );
      expect(AuthSession.current, isNotNull); // 403 bukan sesi berakhir
    });

    test('keluar mencabut token di server lalu membersihkan perangkat', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return jsonResponse({'message': 'Berhasil keluar.'});
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      await service.signOut();

      expect(server.last.url.path, '/api/logout');
      expect(server.last.headers['Authorization'], 'Bearer t');
      expect(AuthSession.current, isNull);
      expect(ProfileStore.instance.nama, isEmpty);
      expect(server.api.token, isNull);
      expect((await SharedPreferences.getInstance()).getString('api_token_v1'),
          isNull);
    });

    test('keluar tanpa jaringan tetap membersihkan perangkat', () async {
      final server = FakeServer((request) {
        if (request.url.path == '/api/login') {
          return jsonResponse({'token': 't', 'user': userJson()});
        }
        return FakeServer.offline(request);
      });
      final service = serviceFor(server);
      await service.signIn('ahmad@gmail.com', 'x');

      await service.signOut();

      expect(AuthSession.current, isNull);
      expect(server.api.token, isNull);
    });

    test('mode lokal tetap memakai akun dummy dan tidak memanggil server', () async {
      final server = FakeServer((_) => jsonResponse({}));
      final service = AccountService(api: server.api, remote: false);

      expect((await service.signIn('jamaah', 'jamaah123')).ok, isTrue);
      expect((await service.signIn('jamaah', 'salah')).error,
          'ID atau kata sandi salah.');
      expect(
        (await service.signUp(
          nama: 'Budi',
          phone: '081311112222',
          email: 'budi@contoh.com',
          password: 'Rahasia#123',
        ))
            .ok,
        isTrue,
      );
      expect(await service.restore(), isFalse);
      expect(server.requests, isEmpty);
    });
  });

  group('AuthSession.canManageContent', () {
    tearDown(() => ApiConfig.overrideBaseUrl(null));

    test('admin mengelola konten pada mode lokal maupun server', () {
      AuthSession.login('admin', 'admin123');
      expect(AuthSession.canManageContent, isTrue);

      ApiConfig.overrideBaseUrl('http://test');
      expect(AuthSession.isAdmin, isTrue);
      expect(AuthSession.canManageContent, isTrue);
    });

    test('jamaah tidak pernah mengelola konten', () {
      AuthSession.login('jamaah', 'jamaah123');
      expect(AuthSession.canManageContent, isFalse);
    });
  });

  group('KegiatanStore (server)', () {
    ServerHandler activitiesFor() => (request) {
          final id = request.url.queryParameters['masjid_id'];
          return jsonResponse([
            {
              'id': 5,
              'masjid_id': int.parse(id!),
              'activity_name': 'Kajian masjid $id',
              'deskripsi': 'Deskripsi $id',
              'pict_url': 'http://test/api/files/gambar-kegiatan/k$id.jpg',
            },
          ]);
        };

    test('memuat kegiatan masjid terpilih', () async {
      final server = FakeServer(activitiesFor());
      final store = KegiatanStore(api: server.api, remote: true);
      expect(store.items, isEmpty);

      await store.selectMasjid(1);

      expect(server.last.url.queryParameters, {'masjid_id': '1'});
      final item = store.items.single;
      expect(item.id, 'api-5');
      expect(item.judul, 'Kajian masjid 1');
      expect(item.deskripsi, 'Deskripsi 1');
      expect(item.imageUrl, 'http://test/api/files/gambar-kegiatan/k1.jpg');
      expect(store.error, isNull);
      expect(store.loading, isFalse);
    });

    test('sebelum masjid dipilih statusnya memuat, bukan "belum ada kegiatan"',
        () async {
      final server = FakeServer(activitiesFor());
      final store = KegiatanStore(api: server.api, remote: true);

      expect(store.loading, isTrue);
      expect(store.items, isEmpty);
      expect(store.error, isNull);

      await store.selectMasjid(1);
      expect(store.loading, isFalse);
    });

    test('berganti masjid mengosongkan kegiatan masjid sebelumnya', () async {
      final server = FakeServer(activitiesFor());
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      final gate = Completer<http.Response>();
      server.handler = (_) => gate.future;
      final loading = store.selectMasjid(2);

      expect(store.items, isEmpty); // tidak menampilkan kegiatan masjid 1
      expect(store.loading, isTrue);

      gate.complete(jsonResponse([
        {'id': 9, 'masjid_id': 2, 'activity_name': 'Kajian masjid 2'},
      ]));
      await loading;
      expect(store.items.single.judul, 'Kajian masjid 2');
    });

    test('jawaban masjid lama yang terlambat diabaikan', () async {
      final slow = Completer<http.Response>();
      final server = FakeServer((request) {
        if (request.url.queryParameters['masjid_id'] == '1') return slow.future;
        return jsonResponse([
          {'id': 9, 'masjid_id': 2, 'activity_name': 'Kajian masjid 2'},
        ]);
      });
      final store = KegiatanStore(api: server.api, remote: true);

      final first = store.selectMasjid(1);
      final second = store.selectMasjid(2);
      await second;
      slow.complete(jsonResponse([
        {'id': 1, 'masjid_id': 1, 'activity_name': 'Kajian masjid 1'},
      ]));
      await first;

      expect(store.items.map((e) => e.judul), ['Kajian masjid 2']);
    });

    test('gagal memuat: pesan kesalahan tersedia, lalu bisa dicoba lagi', () async {
      final server = FakeServer(FakeServer.offline);
      final store = KegiatanStore(api: server.api, remote: true);

      await store.selectMasjid(1);
      expect(store.items, isEmpty);
      expect(store.error, ApiClient.networkMessage);

      server.handler = activitiesFor();
      await store.refresh();
      expect(store.error, isNull);
      expect(store.items, hasLength(1));
    });

    test('tanpa ID masjid (daftar masjid gagal) tidak menampilkan kegiatan', () async {
      final server = FakeServer(activitiesFor());
      final store = KegiatanStore(api: server.api, remote: true);

      await store.selectMasjid(null);

      expect(store.items, isEmpty);
      expect(store.error, 'Daftar masjid belum dapat dimuat.');
      expect(server.requests, isEmpty);
    });

    FakeServer writableServer({http.Response Function()? onWrite}) {
      return FakeServer((request) {
        if (request.method == 'POST') {
          return onWrite?.call() ??
              jsonResponse({
                'id': 77,
                'masjid_id': 1,
                'activity_name': 'Baru',
                'deskripsi': '',
                'pict_url': 'http://test/api/files/gambar-kegiatan/b.jpg',
                'created_at': '2026-10-12T05:00:00.000000Z',
              }, 201);
        }
        if (request.method == 'DELETE') {
          return onWrite?.call() ?? jsonResponse({'message': 'Kegiatan dihapus.'});
        }
        return activitiesFor()(request);
      });
    }

    test('admin menambah kegiatan: multipart ke masjid terpilih, tampil teratas',
        () async {
      final server = writableServer();
      server.api.token = 'tok-admin';
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);
      expect(store.canUploadMore, isTrue);

      final saved = await store.add('  Baru  ', _png);

      expect(saved, isTrue);
      expect(server.last.method, 'POST');
      expect(server.last.url.path, '/api/activity');
      expect(server.last.headers['Authorization'], 'Bearer tok-admin');
      final form = parseMultipart(server.last);
      expect(form.fields['masjid_id'], '1');
      expect(form.fields['activity_name'], 'Baru');
      expect(form.files, ['pict']);
      expect(store.items.first.id, 'api-77');
      expect(store.items.first.imageUrl, 'http://test/api/files/gambar-kegiatan/b.jpg');
      expect(store.items, hasLength(2));
      expect(store.writeError, isNull);
    });

    test('tambah kegiatan ditolak server: pesan tersedia, daftar tetap', () async {
      final server = writableServer(
        onWrite: () => jsonResponse(
            {'message': 'Hanya admin yang boleh melakukan ini.'}, 403),
      );
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      expect(await store.add('Baru', _png), isFalse);

      expect(store.writeError, 'Hanya admin yang boleh melakukan ini.');
      expect(store.items, hasLength(1));
    });

    test('tambah kegiatan tanpa masjid terpilih tidak memanggil server', () async {
      final server = writableServer();
      final store = KegiatanStore(api: server.api, remote: true);

      expect(await store.add('Baru', _png), isFalse);

      expect(store.writeError, 'Pilih masjid di Beranda terlebih dahulu.');
      expect(server.requests, isEmpty);
    });

    test('hapus kegiatan: hilang seketika lalu DELETE dikirim', () async {
      final server = writableServer();
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      final removal = store.remove('api-5');
      expect(store.items, isEmpty); // Dismissible butuh item hilang seketika
      expect(await removal, isTrue);

      expect(server.last.method, 'DELETE');
      expect(server.last.url.path, '/api/activity/5');
    });

    test('hapus kegiatan gagal: daftar dikembalikan dan pesan tersedia', () async {
      final server = writableServer(
        onWrite: () => jsonResponse({'message': 'Terjadi kesalahan.'}, 500),
      );
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      expect(await store.remove('api-5'), isFalse);

      expect(store.items.single.id, 'api-5');
      expect(store.writeError, 'Terjadi kesalahan.');
    });

    test('hapus kegiatan yang sudah tidak ada di server (404) dianggap berhasil',
        () async {
      final server = writableServer(
        onWrite: () => jsonResponse({'message': 'Not Found.'}, 404),
      );
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      expect(await store.remove('api-5'), isTrue);
      expect(store.items, isEmpty);
    });

    test('mode lokal tidak memanggil server', () async {
      final server = FakeServer(activitiesFor());
      final store = KegiatanStore(api: server.api, remote: false);

      await store.selectMasjid(1);

      expect(server.requests, isEmpty);
      expect(store.items, isNotEmpty); // data bawaan
    });
  });

  group('EdukasiStore (server)', () {
    Map<String, dynamic> row(int id, String judul, int kategori, String? url,
        DateTime created) {
      return {
        'id': id,
        'judul': judul,
        'kategori': kategori,
        'deskripsi': 'Deskripsi $judul',
        'created_at': created.toUtc().toIso8601String(),
        'content_url': url,
      };
    }

    final base = DateTime.utc(2026, 10, 1);

    FakeServer serverWith({
      List<Map<String, dynamic>> books = const [],
      List<Map<String, dynamic>> videos = const [],
    }) {
      return FakeServer((request) {
        if (request.url.path == '/api/edu/book') return jsonResponse(books);
        if (request.url.path == '/api/edu/video') return jsonResponse(videos);
        return http.Response('', 404);
      });
    }

    test('buku dan video dipetakan ke materi artikel dan video', () async {
      final server = serverWith(
        books: [
          row(1, 'Poster', 0, 'http://t/files/konten-edukasi/a.PNG', base),
          row(2, 'Modul', 1, 'http://t/files/konten-edukasi/m.pdf', base),
          row(3, 'Tanpa berkas', 2, null, base),
        ],
        videos: [row(4, 'Video', 0, 'http://t/files/konten-edukasi/v.mp4', base)],
      );
      final store = EdukasiStore(api: server.api, remote: true);

      await store.load();

      final poster = store.byId('api-1')!;
      expect(poster.isVideo, isFalse);
      expect(poster.kategori, 'Anak-anak');
      expect(poster.coverUrl, 'http://t/files/konten-edukasi/a.PNG');
      expect(poster.fileUrl, isNull);
      expect(poster.isi, 'Deskripsi Poster');

      final modul = store.byId('api-2')!;
      expect(modul.kategori, 'Remaja');
      expect(modul.coverUrl, isNull);
      expect(modul.fileUrl, 'http://t/files/konten-edukasi/m.pdf');

      final tanpa = store.byId('api-3')!;
      expect(tanpa.kategori, 'Orang Tua');
      expect(tanpa.coverUrl, isNull);
      expect(tanpa.fileUrl, isNull);

      final video = store.byId('api-4')!;
      expect(video.isVideo, isTrue);
      expect(video.videoUrl, 'http://t/files/konten-edukasi/v.mp4');
      expect(video.coverUrl, isNull);
    });

    test('tab kategori memfilter dan mengurutkan yang terbaru di atas', () async {
      final server = serverWith(books: [
        row(1, 'Lama', 0, null, base),
        row(2, 'Baru', 0, null, base.add(const Duration(days: 2))),
        row(3, 'Remaja', 1, null, base),
      ]);
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      expect(store.byKategori('Anak-anak').map((e) => e.judul), ['Baru', 'Lama']);
      expect(store.byKategori('Remaja').map((e) => e.judul), ['Remaja']);
      expect(store.byKategori('Orang Tua'), isEmpty);
    });

    test('Rekomendasi berisi materi terbaru dari semua kategori (maks. 5)', () async {
      final server = serverWith(books: [
        for (var i = 0; i < 7; i++)
          row(i + 1, 'Materi $i', i % 3, null, base.add(Duration(days: i))),
      ]);
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      final rekomendasi = store.byKategori('Rekomendasi');

      expect(rekomendasi, hasLength(EdukasiStore.maxRekomendasi));
      expect(rekomendasi.first.judul, 'Materi 6');
      expect(rekomendasi.last.judul, 'Materi 2');
    });

    test('kategori tak dikenal hanya muncul di Rekomendasi', () async {
      final server = serverWith(books: [row(1, 'Aneh', 9, null, base)]);
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      expect(store.byKategori('Rekomendasi').single.judul, 'Aneh');
      expect(store.byKategori('Anak-anak'), isEmpty);
      expect(store.byKategori('Remaja'), isEmpty);
      expect(store.byKategori('Orang Tua'), isEmpty);
    });

    test('gagal memuat: pesan tersedia dan refresh memperbaikinya', () async {
      final server = FakeServer(FakeServer.offline);
      final store = EdukasiStore(api: server.api, remote: true);

      await store.load();
      expect(store.items, isEmpty);
      expect(store.error, ApiClient.networkMessage);

      server.handler = (request) => jsonResponse(
          request.url.path == '/api/edu/book'
              ? [row(1, 'Buku', 0, null, base)]
              : []);
      await store.refresh();
      expect(store.error, isNull);
      expect(store.items.single.judul, 'Buku');
    });

    // Server yang menjawab daftar dan menerima tulis (POST/DELETE).
    FakeServer writable({
      Map<String, dynamic>? created,
      int writeStatus = 201,
      Map<String, dynamic>? writeBody,
    }) {
      return FakeServer((request) {
        if (request.method == 'POST' || request.method == 'DELETE') {
          return jsonResponse(
              writeBody ?? created ?? {'message': 'ok'}, writeStatus);
        }
        if (request.url.path == '/api/edu/book') {
          return jsonResponse([row(1, 'Buku', 0, null, base)]);
        }
        if (request.url.path == '/api/edu/video') {
          return jsonResponse(
              [row(2, 'Video lama', 1, 'https://youtu.be/dQw4w9WgXcQ', base)]);
        }
        return http.Response('', 404);
      });
    }

    EdukasiItem newItem({
      String judul = 'Judul Baru Artikel',
      String kategori = 'Remaja',
      EdukasiType tipe = EdukasiType.artikel,
      String isi = 'Isi artikel yang cukup panjang.',
      String? videoUrl,
      Uint8List? coverBytes,
    }) {
      return EdukasiItem(
        id: 'baru',
        judul: judul,
        kategori: kategori,
        tipe: tipe,
        penulis: 'Admin Masjid',
        createdAt: base,
        isi: isi,
        videoUrl: videoUrl,
        coverBytes: coverBytes,
      );
    }

    test('pilihan kategori: server hanya tiga, lokal termasuk Rekomendasi', () {
      final remote = EdukasiStore(remote: true);
      final local = EdukasiStore(remote: false);

      expect(remote.kategoriChoices, ['Anak-anak', 'Remaja', 'Orang Tua']);
      expect(local.kategoriChoices, contains('Rekomendasi'));
      expect(remote.canAddMore, isTrue);
    });

    test('admin menambah artikel: multipart jenis book, kategori angka, gambar',
        () async {
      final server = writable(created: {
        'id': 50,
        'jenis_education_id': 1,
        'judul': 'Judul Baru Artikel',
        'kategori': 1,
        'deskripsi': 'Isi artikel yang cukup panjang.',
        'content_url': 'http://test/api/files/konten-edukasi/c.jpg',
        'created_at': '2026-10-12T05:00:00.000000Z',
      });
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      final saved = await store.add(newItem(coverBytes: _png));

      expect(saved, isTrue);
      expect(server.last.url.path, '/api/edu');
      final form = parseMultipart(server.last);
      expect(form.fields['jenis'], 'book');
      expect(form.fields['judul'], 'Judul Baru Artikel');
      expect(form.fields['kategori'], '1'); // Remaja
      expect(form.fields['deskripsi'], 'Isi artikel yang cukup panjang.');
      expect(form.files, ['content']);
      expect(store.items.first.id, 'api-50');
      expect(store.items.first.coverUrl, 'http://test/api/files/konten-edukasi/c.jpg');
      expect(store.byKategori('Remaja').first.id, 'api-50');
    });

    test('admin menambah video: tautan dikirim, deskripsi kosong memakai judul',
        () async {
      final server = writable(created: {
        'id': 51,
        'jenis_education_id': 2,
        'judul': 'Video Baru Wudhu',
        'kategori': 0,
        'deskripsi': 'Video Baru Wudhu',
        'content_url': 'https://youtu.be/dQw4w9WgXcQ',
        'created_at': '2026-10-12T05:00:00.000000Z',
      });
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      final saved = await store.add(newItem(
        judul: 'Video Baru Wudhu',
        kategori: 'Anak-anak',
        tipe: EdukasiType.video,
        isi: '',
        videoUrl: 'https://youtu.be/dQw4w9WgXcQ',
        coverBytes: _png, // sampul diabaikan untuk video
      ));

      expect(saved, isTrue);
      final form = parseMultipart(server.last);
      expect(form.fields['jenis'], 'video');
      expect(form.fields['kategori'], '0');
      expect(form.fields['deskripsi'], 'Video Baru Wudhu');
      expect(form.fields['video_url'], 'https://youtu.be/dQw4w9WgXcQ');
      expect(form.files, isEmpty);
      expect(store.items.first.isVideo, isTrue);
    });

    test('tambah materi ditolak server (422): pesan kolom tersedia, daftar tetap',
        () async {
      final server = writable(
        writeStatus: 422,
        writeBody: {
          'message': 'invalid',
          'errors': {'judul': ['Judul wajib diisi.']},
        },
      );
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      expect(await store.add(newItem()), isFalse);

      expect(store.writeError, 'Judul wajib diisi.');
      expect(store.items, hasLength(2));
    });

    test('ubah materi: hanya bagian yang berubah dikirim ke /api/edu/{id}', () async {
      final server = writable(writeStatus: 200, writeBody: {
        'id': 2,
        'jenis_education_id': 2,
        'judul': 'Video diubah',
        'kategori': 2,
        'deskripsi': 'Deskripsi baru',
        'content_url': 'https://youtu.be/dQw4w9WgXcQ',
        'created_at': '2026-10-01T05:00:00.000000Z',
      });
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();
      final current = store.byId('api-2')!;

      // Tautan tidak berubah: video_url tidak dikirim.
      final saved = await store.update(EdukasiItem(
        id: current.id,
        judul: 'Video diubah',
        kategori: 'Orang Tua',
        tipe: current.tipe,
        penulis: current.penulis,
        createdAt: current.createdAt,
        isi: 'Deskripsi baru',
        videoUrl: current.videoUrl,
      ));

      expect(saved, isTrue);
      expect(server.last.url.path, '/api/edu/2');
      final form = parseMultipart(server.last);
      expect(form.fields['judul'], 'Video diubah');
      expect(form.fields['kategori'], '2');
      expect(form.fields.containsKey('video_url'), isFalse);
      expect(form.fields.containsKey('jenis'), isFalse); // jenis tak dapat diubah
      expect(store.byId('api-2')!.judul, 'Video diubah');
      expect(store.byId('api-2')!.kategori, 'Orang Tua');

      // Tautan baru dikirim.
      await store.update(EdukasiItem(
        id: current.id,
        judul: 'Video diubah',
        kategori: 'Orang Tua',
        tipe: current.tipe,
        penulis: current.penulis,
        createdAt: current.createdAt,
        isi: 'Deskripsi baru',
        videoUrl: 'https://youtu.be/aaaaaaaaaaa',
      ));
      expect(parseMultipart(server.last).fields['video_url'],
          'https://youtu.be/aaaaaaaaaaa');
    });

    test('ubah materi yang tidak dikenal gagal tanpa memanggil server', () async {
      final server = writable();
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();
      final before = server.requests.length;

      expect(await store.update(newItem()), isFalse);

      expect(store.writeError, 'Materi tidak ditemukan.');
      expect(server.requests.length, before);
    });

    test('hapus materi: hilang seketika lalu DELETE; gagal mengembalikan daftar',
        () async {
      final server = writable(writeStatus: 200, writeBody: {'message': 'Materi dihapus.'});
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      final removal = store.remove('api-1');
      expect(store.byId('api-1'), isNull);
      expect(await removal, isTrue);
      expect(server.last.method, 'DELETE');
      expect(server.last.url.path, '/api/edu/1');

      server.handler = (_) => jsonResponse({'message': 'Terjadi kesalahan.'}, 500);
      expect(await store.remove('api-2'), isFalse);
      expect(store.byId('api-2'), isNotNull); // dikembalikan
      expect(store.writeError, 'Terjadi kesalahan.');
    });
  });

  group('MasjidStore dan BannerStore (server)', () {
    test('daftar masjid dari server menggantikan daftar bawaan', () async {
      final server = FakeServer((_) => jsonResponse([
            {'id': 8, 'masjid_name': 'Al-Fajri', 'alamat': 'Rajabasa, Bandar Lampung'},
          ]));
      final store = MasjidStore(api: server.api, remote: true);

      await store.load();

      final masjid = store.masjids.single;
      expect(masjid.id, 8);
      expect(masjid.nama, 'Al-Fajri');
      expect(masjid.lokasi, 'Rajabasa, Bandar Lampung');
      expect(masjid.kecamatanLabel, 'Rajabasa, Bandar Lampung');
    });

    test('server mati: daftar bawaan (tanpa ID) dan pesan kesalahan', () async {
      final server = FakeServer(FakeServer.offline);
      final store = MasjidStore(api: server.api, remote: true);

      await store.load();

      expect(store.masjids, MasjidStore.defaults);
      expect(store.masjids.every((e) => e.id == null), isTrue);
      expect(store.error, ApiClient.networkMessage);
    });

    test('daftar masjid kosong dari server tidak mengosongkan pilihan', () async {
      final server = FakeServer((_) => jsonResponse([]));
      final store = MasjidStore(api: server.api, remote: true);

      await store.load();

      expect(store.masjids, MasjidStore.defaults);
    });

    test('mode lokal memakai daftar bawaan tanpa memanggil server', () async {
      final server = FakeServer((_) => jsonResponse([]));
      final store = MasjidStore(api: server.api, remote: false);

      await store.load();

      expect(store.masjids, MasjidStore.defaults);
      expect(server.requests, isEmpty);
      expect(MasjidStore.defaults.first.kecamatanLabel, 'Kecamatan Rajabasa');
      expect(MasjidStore.defaults.first.lokasi, 'Rajabasa, Bandar Lampung');
    });

    test('banner dari server: hanya yang punya gambar', () async {
      final server = FakeServer((_) => jsonResponse([
            {'id': 1, 'judul': 'A', 'cover_url': 'http://t/a.jpg'},
            {'id': 2, 'judul': 'B', 'cover_url': null},
          ]));
      final store = BannerStore(api: server.api, remote: true);
      expect(store.images, isEmpty);

      await store.load();

      expect(store.images, ['http://t/a.jpg']);
    });

    test('banner: server mati tanpa cache menyembunyikan carousel', () async {
      final server = FakeServer(FakeServer.offline);
      final store = BannerStore(api: server.api, remote: true);

      await store.load();

      expect(store.images, isEmpty);
    });

    test('banner mode lokal memakai gambar bawaan', () async {
      final store = BannerStore(remote: false);

      await store.load();

      expect(store.images, BannerStore.defaults);
    });
  });
}
