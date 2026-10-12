import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/login/login.dart';
import 'package:masjid/login/sign_up.dart';
import 'package:masjid/screens/dashboard/edukasi_detail_page.dart';
import 'package:masjid/screens/dashboard/edukasi_form_page.dart';
import 'package:masjid/screens/dashboard/edukasi_pages.dart';
import 'package:masjid/screens/kegiatan/kegiatan_masjid_page.dart';
import 'package:masjid/screens/profile/change_password_dialog.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/screens/splashscreen.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/edukasi_store.dart';
import 'package:masjid/services/kegiatan_store.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_server.dart';

// Server untuk alur akun: /login mengembalikan [user]; permintaan lain dijawab
// oleh [other].
FakeServer _accountServer({
  Map<String, dynamic>? user,
  ServerHandler? other,
}) {
  return FakeServer((request) {
    if (request.url.path == '/api/login') {
      return jsonResponse({'token': 'tok', 'user': user ?? userJson()});
    }
    return other?.call(request) ?? jsonResponse({'user': user ?? userJson()});
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
    ProfileStore.instance.clear();
  });

  tearDown(() => ApiConfig.overrideBaseUrl(null));

  Future<void> useSurface(WidgetTester tester, [double height = 844]) async {
    await tester.binding.setSurfaceSize(Size(390, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  final masukButton = find.widgetWithText(ElevatedButton, 'Masuk');

  group('LoginWidget (server)', () {
    Future<void> pumpLogin(WidgetTester tester, AccountService service) async {
      await useSurface(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: LoginWidget(accountService: service),
          routes: {'/dashboard': (_) => const Scaffold(body: Text('DASHBOARD'))},
        ),
      );
    }

    testWidgets('petunjuk akun demo disembunyikan', (tester) async {
      final server = _accountServer();
      await pumpLogin(tester, AccountService(api: server.api, remote: true));

      expect(find.textContaining('Akun demo'), findsNothing);
    });

    testWidgets('petunjuk akun demo tampil pada mode lokal', (tester) async {
      await pumpLogin(tester, AccountService(remote: false));

      expect(find.textContaining('Akun demo'), findsOneWidget);
    });

    testWidgets('masuk berhasil membuka dashboard dengan data dari server',
        (tester) async {
      final server = _accountServer(user: userJson(name: 'Budi Santoso'));
      await pumpLogin(tester, AccountService(api: server.api, remote: true));

      await tester.enterText(find.byType(TextFormField).at(0), 'budi@contoh.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Rahasia#123');
      await tester.tap(masukButton);
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(ProfileStore.instance.nama, 'Budi Santoso');
      expect(server.requests.where((r) => r.url.path == '/api/login'), hasLength(1));
    });

    testWidgets('pesan server ditampilkan saat masuk ditolak', (tester) async {
      final server = FakeServer((_) => jsonResponse(
          {'message': 'Akun Anda menunggu persetujuan admin.'}, 403));
      await pumpLogin(tester, AccountService(api: server.api, remote: true));

      await tester.enterText(find.byType(TextFormField).at(0), 'budi@contoh.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Rahasia#123');
      await tester.tap(masukButton);
      await tester.pumpAndSettle();

      expect(find.text('Akun Anda menunggu persetujuan admin.'), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
    });

    testWidgets('tanpa jaringan: pesan jaringan, bukan crash', (tester) async {
      final server = FakeServer(FakeServer.offline);
      await pumpLogin(tester, AccountService(api: server.api, remote: true));

      await tester.enterText(find.byType(TextFormField).at(0), 'budi@contoh.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Rahasia#123');
      await tester.tap(masukButton);
      await tester.pumpAndSettle();

      expect(find.text(ApiClient.networkMessage), findsOneWidget);
    });
  });

  group('SignUpWidget (server)', () {
    Future<void> fill(WidgetTester tester) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Budi Santoso');
      await tester.enterText(fields.at(1), '081311112222');
      await tester.enterText(fields.at(2), 'budi@contoh.com');
      await tester.enterText(fields.at(3), 'Rahasia#123');
      await tester.enterText(fields.at(4), 'Rahasia#123');
    }

    Future<void> pumpSignUp(WidgetTester tester, AccountService service) async {
      await useSurface(tester, 1400);
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpWidget(accountService: service),
          routes: {'/login': (_) => const Scaffold(body: Text('LOGIN'))},
        ),
      );
    }

    final daftarButton = find.widgetWithText(ElevatedButton, 'Daftar');

    testWidgets('berhasil: pindah ke login dan menampilkan pesan persetujuan admin',
        (tester) async {
      final server = FakeServer((_) => jsonResponse({
            'message':
                'Pendaftaran berhasil. Akun Anda menunggu persetujuan admin.',
            'user': userJson(status: 0),
          }, 201));
      await pumpSignUp(tester, AccountService(api: server.api, remote: true));

      await fill(tester);
      await tester.tap(daftarButton);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.textContaining('menunggu persetujuan admin'), findsOneWidget);
      expect(server.lastBody['no_hp'], '081311112222');
    });

    testWidgets('ditolak server: tetap di halaman daftar dengan pesan kolom',
        (tester) async {
      final server = FakeServer((_) => jsonResponse({
            'message': 'invalid',
            'errors': {'email': ['Email sudah terdaftar.']},
          }, 422));
      await pumpSignUp(tester, AccountService(api: server.api, remote: true));

      await fill(tester);
      await tester.tap(daftarButton);
      await tester.pumpAndSettle();

      expect(find.text('Email sudah terdaftar.'), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
    });
  });

  group('ChangePasswordDialog (server)', () {
    testWidgets('kata sandi lama salah (422) tampil di bawah kolom', (tester) async {
      final server = _accountServer(other: (_) => jsonResponse({
            'message': 'invalid',
            'errors': {'old_password': ['Kata sandi lama salah.']},
          }, 422));
      final service = AccountService(api: server.api, remote: true);
      await service.signIn('ahmad@gmail.com', 'x');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => ChangePasswordDialog(accountService: service),
                ),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'salah');
      await tester.enterText(fields.at(1), 'Baru#12345');
      await tester.enterText(fields.at(2), 'Baru#12345');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Kata sandi lama salah.'), findsOneWidget);
      expect(find.text('Ubah Kata Sandi'), findsOneWidget); // dialog tetap terbuka
    });
  });

  group('ProfilePages (server)', () {
    Future<AccountService> pumpProfile(
      WidgetTester tester, {
      Map<String, dynamic>? user,
      ServerHandler? other,
    }) async {
      final server = _accountServer(user: user, other: other);
      final service = AccountService(api: server.api, remote: true);
      await service.signIn('ahmad@gmail.com', 'x');
      ApiConfig.overrideBaseUrl('http://test');

      await useSurface(tester, 1400);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProfilePages(accountService: service)),
          routes: {'/login': (_) => const Scaffold(body: Text('LOGIN'))},
        ),
      );
      return service;
    }

    testWidgets('data dari server tampil dan admin melihat menu kelola',
        (tester) async {
      await pumpProfile(
        tester,
        user: userJson(admin: true, name: 'Master Admin', email: 'admin@gmail.com'),
      );

      expect(find.text('Master Admin'), findsWidgets);
      expect(find.text('admin@gmail.com'), findsOneWidget);
      expect(find.text('Admin Masjid'), findsOneWidget);
      expect(find.text('Kelola Kegiatan Masjid'), findsOneWidget);
    });

    testWidgets('edit data diri tersimpan ke server', (tester) async {
      await pumpProfile(
        tester,
        other: (request) => jsonResponse({
          'user': userJson(name: 'Ahmad Fadhillah'),
        }),
      );

      await tester.tap(find.text('EDIT'));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(0), 'Ahmad Fadhillah');
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();

      expect(find.text('Profil berhasil diperbarui.'), findsOneWidget);
      expect(find.text('Ahmad Fadhillah'), findsWidgets);
      expect(ProfileStore.instance.nama, 'Ahmad Fadhillah');
    });

    testWidgets('ditolak server: pesan tampil dan mode edit tetap terbuka',
        (tester) async {
      await pumpProfile(
        tester,
        other: (_) => jsonResponse({
          'message': 'invalid',
          'errors': {'email': ['Email sudah terdaftar.']},
        }, 422),
      );

      await tester.tap(find.text('EDIT'));
      await tester.pump();
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();

      expect(find.text('Email sudah terdaftar.'), findsOneWidget);
      expect(find.text('SIMPAN'), findsOneWidget); // masih mengedit
    });

    testWidgets('sesi berakhir saat menyimpan: kembali ke halaman masuk',
        (tester) async {
      await pumpProfile(
        tester,
        other: (_) => jsonResponse({'message': 'Unauthenticated.'}, 401),
      );

      await tester.tap(find.text('EDIT'));
      await tester.pump();
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      expect(AuthSession.current, isNull);
    });

    testWidgets('keluar mencabut token lalu kembali ke halaman masuk',
        (tester) async {
      final service = await pumpProfile(
        tester,
        other: (_) => jsonResponse({'message': 'Berhasil keluar.'}),
      );

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      expect(AuthSession.current, isNull);
      expect(service.remote, isTrue);
    });
  });

  group('SplashScreen (server)', () {
    Future<void> pumpSplash(WidgetTester tester, AccountService service) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(accountService: service),
          routes: {'/dashboard': (_) => const Scaffold(body: Text('DASHBOARD'))},
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }

    testWidgets('token tersimpan yang sah langsung membuka beranda', (tester) async {
      SharedPreferences.setMockInitialValues({'api_token_v1': 'tok'});
      final server = _accountServer();

      await pumpSplash(tester, AccountService(api: server.api, remote: true));

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(ProfileStore.instance.nama, 'Ahmad Al Farizi');
    });

    testWidgets('token ditolak membuka halaman masuk', (tester) async {
      SharedPreferences.setMockInitialValues({'api_token_v1': 'dicabut'});
      final server = FakeServer((_) => jsonResponse({'message': 'x'}, 401));

      await pumpSplash(tester, AccountService(api: server.api, remote: true));

      expect(find.text('DASHBOARD'), findsNothing);
      expect(masukButton, findsOneWidget);
    });
  });

  group('Form materi admin (server)', () {
    FakeServer eduWritable({int status = 201, Map<String, dynamic>? body}) {
      return FakeServer((request) {
        if (request.method == 'POST') {
          return jsonResponse(
            body ??
                {
                  'id': 60,
                  'jenis_education_id': 1,
                  'judul': 'Artikel dari aplikasi',
                  'kategori': 0,
                  'deskripsi': 'Isi artikel dari aplikasi admin.',
                  'content_url': null,
                  'created_at': '2026-10-12T05:00:00.000000Z',
                },
            status,
          );
        }
        if (request.url.path == '/api/edu/video') return jsonResponse([]);
        return jsonResponse([
          {
            'id': 2,
            'judul': 'Modul Sholat',
            'kategori': 1,
            'deskripsi': 'Panduan sholat lengkap untuk pemula.',
            'created_at': '2026-10-01T05:00:00.000000Z',
            'content_url': null,
          },
        ]);
      });
    }

    Future<void> pumpForm(
      WidgetTester tester,
      EdukasiStore store, {
      EdukasiItem? existing,
    }) async {
      AuthSession.login('admin', 'admin123');
      await useSurface(tester, 1000);
      await tester.pumpWidget(MaterialApp(
        home: EdukasiFormPage(
          store: store,
          existing: existing,
          initialKategori: 'Rekomendasi',
        ),
      ));
    }

    testWidgets('kategori awal Rekomendasi diganti kategori server, lalu tersimpan',
        (tester) async {
      final server = eduWritable();
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      await pumpForm(tester, store);
      // Rekomendasi bukan kategori di server, jadi pilihan awalnya Anak-anak.
      expect(find.text('Anak-anak'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Artikel dari aplikasi');
      await tester.enterText(fields.at(1), 'Isi artikel dari aplikasi admin.');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(server.last.method, 'POST');
      expect(server.last.url.path, '/api/edu');
      final form = parseMultipart(server.last);
      expect(form.fields['jenis'], 'book');
      expect(form.fields['kategori'], '0');
      expect(form.fields['judul'], 'Artikel dari aplikasi');
      expect(store.items.first.id, 'api-60');
    });

    testWidgets('ditolak server: pesan server tampil dan form tetap terbuka',
        (tester) async {
      final server = eduWritable(status: 403, body: {
        'message': 'Hanya admin yang boleh melakukan ini.',
      });
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      await pumpForm(tester, store);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Artikel dari aplikasi');
      await tester.enterText(fields.at(1), 'Isi artikel dari aplikasi admin.');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Hanya admin yang boleh melakukan ini.'), findsOneWidget);
      expect(find.text('Tambah Materi'), findsOneWidget);
      expect(store.items, hasLength(1)); // tidak bertambah
    });

    testWidgets('mengubah materi dari server: jenis tidak dapat diganti',
        (tester) async {
      final server = eduWritable(status: 200, body: {
        'id': 2,
        'jenis_education_id': 1,
        'judul': 'Modul Sholat Baru',
        'kategori': 1,
        'deskripsi': 'Panduan sholat.',
        'content_url': null,
        'created_at': '2026-10-01T05:00:00.000000Z',
      });
      final store = EdukasiStore(api: server.api, remote: true);
      await store.load();

      await pumpForm(tester, store, existing: store.byId('api-2'));

      final video = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Video'));
      expect(video.onSelected, isNull);
      expect(find.text('Ubah Materi'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Modul Sholat Baru');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(server.last.url.path, '/api/edu/2');
      expect(store.byId('api-2')!.judul, 'Modul Sholat Baru');
    });
  });

  group('Kegiatan dan Edukasi (server)', () {
    ServerHandler kegiatanHandler() => (_) => jsonResponse([
          {
            'id': 5,
            'masjid_id': 1,
            'activity_name': 'Kajian Subuh',
            'deskripsi': 'Setiap hari Subuh di serambi.',
            'pict_url': null,
          },
        ]);

    testWidgets('jamaah tidak melihat tombol Unggah dan geser-hapus', (tester) async {
      AuthSession.login('jamaah', 'jamaah123');
      ApiConfig.overrideBaseUrl('http://test');
      final server = FakeServer(kegiatanHandler());
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(home: KegiatanMasjidPage(store: store)));
      await tester.pump();

      expect(find.text('Unggah'), findsNothing);
      expect(find.textContaining('Mode admin'), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
      expect(find.text('Kajian Subuh'), findsWidgets);
      expect(find.text('Setiap hari Subuh di serambi.'), findsOneWidget);
    });

    testWidgets('admin melihat Unggah dan menghapus kegiatan dengan geser',
        (tester) async {
      AuthSession.login('admin', 'admin123');
      ApiConfig.overrideBaseUrl('http://test');
      final server = FakeServer((request) => request.method == 'DELETE'
          ? jsonResponse({'message': 'Kegiatan dihapus.'})
          : kegiatanHandler()(request));
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(home: KegiatanMasjidPage(store: store)));
      await tester.pump();

      expect(find.text('Unggah'), findsOneWidget);
      expect(find.textContaining('masjid yang dipilih di Beranda'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);

      await tester.drag(find.byType(Dismissible), const Offset(500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(server.last.method, 'DELETE');
      expect(server.last.url.path, '/api/activity/5');
      expect(find.text('Kegiatan dihapus.'), findsOneWidget);
      // SnackBar juga memakai Dismissible, jadi poster diperiksa lewat kuncinya.
      expect(find.byKey(const ValueKey('api-5')), findsNothing);
    });

    testWidgets('hapus kegiatan gagal: pesan server tampil dan poster kembali',
        (tester) async {
      AuthSession.login('admin', 'admin123');
      ApiConfig.overrideBaseUrl('http://test');
      final server = FakeServer((request) => request.method == 'DELETE'
          ? jsonResponse({'message': 'Hanya admin yang boleh melakukan ini.'}, 403)
          : kegiatanHandler()(request));
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(home: KegiatanMasjidPage(store: store)));
      await tester.pump();

      await tester.drag(find.byType(Dismissible), const Offset(500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await tester.pumpAndSettle();
      // Daftar dikembalikan setelah jeda singkat agar Dismissible sempat lepas.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Hanya admin yang boleh melakukan ini.'), findsOneWidget);
      expect(find.byKey(const ValueKey('api-5')), findsOneWidget);
    });

    testWidgets('gagal memuat: pesan dan tombol Coba lagi', (tester) async {
      final server = FakeServer(FakeServer.offline);
      final store = KegiatanStore(api: server.api, remote: true);
      await store.selectMasjid(1);

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(home: KegiatanMasjidPage(store: store)));
      await tester.pump();
      expect(find.text(ApiClient.networkMessage), findsOneWidget);

      server.handler = kegiatanHandler();
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text(ApiClient.networkMessage), findsNothing);
      expect(find.text('Kajian Subuh'), findsWidgets);
    });

    FakeServer eduServer() => FakeServer((request) {
          final isBook = request.url.path == '/api/edu/book';
          return jsonResponse(isBook
              ? [
                  {
                    'id': 2,
                    'judul': 'Modul Sholat',
                    'kategori': 1,
                    'deskripsi': 'Panduan sholat.',
                    'created_at': '2026-10-01T05:00:00.000000Z',
                    'content_url': 'http://test/api/files/konten-edukasi/m.pdf',
                  },
                ]
              : [
                  {
                    'id': 4,
                    'judul': 'Video Wudhu',
                    'kategori': 0,
                    'deskripsi': 'Cara wudhu.',
                    'created_at': '2026-10-02T05:00:00.000000Z',
                    'content_url': 'http://test/api/files/konten-edukasi/v.mp4',
                  },
                ]);
        });

    testWidgets('daftar materi: admin melihat tombol Tambah, tab bekerja',
        (tester) async {
      AuthSession.login('admin', 'admin123');
      ApiConfig.overrideBaseUrl('http://test');
      final store = EdukasiStore(api: eduServer().api, remote: true);

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(home: EdukasiWidget(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('Tambah materi'), findsOneWidget);
      // Tab Rekomendasi: materi terbaru dari semua kategori.
      expect(find.text('Video Wudhu'), findsOneWidget);
      expect(find.text('Modul Sholat'), findsOneWidget);

      // Deretan tab dapat digulir, jadi tab "Remaja" digulirkan ke layar dulu.
      await tester.ensureVisible(find.text('Remaja'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remaja'));
      await tester.pumpAndSettle();
      expect(find.text('Modul Sholat'), findsOneWidget);
      expect(find.text('Video Wudhu'), findsNothing);
    });

    testWidgets('daftar materi: gagal memuat lalu Coba lagi', (tester) async {
      final server = FakeServer(FakeServer.offline);
      final store = EdukasiStore(api: server.api, remote: true);

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(home: EdukasiWidget(store: store)));
      await tester.pumpAndSettle();
      expect(find.text(ApiClient.networkMessage), findsOneWidget);

      server.handler = eduServer().handler;
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Modul Sholat'), findsOneWidget);
    });

    testWidgets('detail: tombol Buka Berkas dan Tonton Video membuka tautan server',
        (tester) async {
      final store = EdukasiStore(api: eduServer().api, remote: true);
      await store.load();
      final opened = <String>[];

      await useSurface(tester);
      await tester.pumpWidget(MaterialApp(
        home: EdukasiDetailPage(
          itemId: 'api-2',
          store: store,
          openUrl: (url) async {
            opened.add(url);
            return true;
          },
        ),
      ));
      await tester.pump();
      await tester.tap(find.text('Buka Berkas'));
      await tester.pump();
      expect(opened, ['http://test/api/files/konten-edukasi/m.pdf']);
      expect(find.text('Tonton Video'), findsNothing);

      await tester.pumpWidget(MaterialApp(
        home: EdukasiDetailPage(
          itemId: 'api-4',
          store: store,
          openUrl: (url) async {
            opened.add(url);
            return true;
          },
        ),
      ));
      await tester.pump();
      await tester.tap(find.text('Tonton Video'));
      await tester.pump();
      expect(opened.last, 'http://test/api/files/konten-edukasi/v.mp4');
      expect(find.text('Buka Berkas'), findsNothing);
    });
  });
}

