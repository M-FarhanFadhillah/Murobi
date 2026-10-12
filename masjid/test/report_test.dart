import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/screens/profile/report_problem.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:masjid/services/report_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_server.dart';

Map<String, dynamic> _reportJson({
  int id = 1,
  String name = 'Siti Aminah',
  String email = 'siti@gmail.com',
  String message = 'Jadwal sholat tidak muncul',
  int status = 0,
  String createdAt = '2026-10-12T10:00:00+00:00',
}) =>
    {
      'id': id,
      'user_id': 7,
      'user_name': name,
      'user_email': email,
      'message': message,
      'status': status,
      'created_at': createdAt,
    };

UserAccount _server({bool admin = false}) => UserAccount(
      id: 'api-3',
      nama: admin ? 'Admin' : 'Siti',
      email: 'x@y.com',
      phone: '',
      role: admin ? UserRole.admin : UserRole.jamaah,
      isRemote: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
    ProfileStore.instance.clear();
  });

  tearDown(() => ApiConfig.overrideBaseUrl(null));

  group('ReportStore (lokal)', () {
    test('jamaah hanya melihat laporannya sendiri, admin melihat semuanya',
        () async {
      final store = ReportStore(remote: false);

      AuthSession.login('jamaah', 'jamaah123');
      expect(await store.send('  Foto profil gagal diunggah  '), isTrue);
      expect(store.items.single.pesan, 'Foto profil gagal diunggah');
      expect(store.items.single.nama, 'Jamaah As-Syifa');
      expect(store.items.single.selesai, isFalse);

      // Jamaah lain tidak melihat laporan itu.
      AuthSession.register(
        nama: 'Budi',
        phone: '081311112222',
        email: 'budi@contoh.com',
        password: 'Rahasia#123',
      );
      AuthSession.login('budi@contoh.com', 'Rahasia#123');
      expect(store.items, isEmpty);
      await store.send('Bacaan audio berhenti sendiri');
      expect(store.items.length, 1);

      // Admin melihat keduanya, terbaru di atas.
      AuthSession.login('admin', 'admin123');
      expect(store.items.map((e) => e.nama), ['Budi', 'Jamaah As-Syifa']);
      expect(store.belumSelesai, 2);
    });

    test('laporan tetap ada setelah dimuat ulang oleh instance lain', () async {
      AuthSession.login('jamaah', 'jamaah123');
      await ReportStore(remote: false).send('Tombol Google tidak berfungsi');

      final reloaded = ReportStore(remote: false);
      await reloaded.load();
      expect(reloaded.items.single.pesan, 'Tombol Google tidak berfungsi');
      expect(reloaded.loading, isFalse);
    });

    test('admin menandai selesai, membuka lagi, dan menghapus', () async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await store.send('Laporan pertama');
      AuthSession.login('admin', 'admin123');
      final id = store.items.single.id;

      expect(await store.setSelesai(id, true), isTrue);
      expect(store.items.single.selesai, isTrue);
      expect(store.belumSelesai, 0);

      final reloaded = ReportStore(remote: false);
      await reloaded.load();
      expect(reloaded.items.single.selesai, isTrue);

      expect(await store.setSelesai(id, false), isTrue);
      expect(store.belumSelesai, 1);

      expect(await store.remove(id), isTrue);
      expect(store.items, isEmpty);
      await reloaded.load();
      expect(reloaded.items, isEmpty);
    });

    test('tanpa masuk laporan tidak dapat dikirim', () async {
      final store = ReportStore(remote: false);

      expect(await store.send('Halo'), isFalse);
      expect(store.writeError, 'Anda belum masuk.');
    });

    test('jumlah laporan di perangkat dibatasi', () async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      for (var i = 0; i < ReportStore.maxLocal + 5; i++) {
        await store.send('Laporan nomor $i');
      }

      expect(store.items.length, ReportStore.maxLocal);
      expect(store.items.first.pesan, 'Laporan nomor ${ReportStore.maxLocal + 4}');
    });
  });

  group('ReportStore (server)', () {
    test('jamaah memuat laporannya sendiri, admin memuat semua', () async {
      final server = FakeServer((request) => jsonResponse([_reportJson()]));
      final store = ReportStore(api: server.api, remote: true);

      AuthSession.startRemote(_server());
      await store.load();
      expect(server.last.url.path, '/api/reports/mine');
      expect(store.items.single.id, 'api-1');
      expect(store.items.single.nama, 'Siti Aminah');

      AuthSession.startRemote(_server(admin: true));
      await store.load();
      expect(server.last.url.path, '/api/reports');
    });

    test('gagal memuat: pesan kesalahan tampil dan daftar tidak berubah',
        () async {
      final server = FakeServer(FakeServer.offline);
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server());

      await store.load();

      expect(store.error, contains('Tidak dapat terhubung'));
      expect(store.items, isEmpty);
      expect(store.loading, isFalse);
    });

    test('send mengirim pesan dan menaruhnya di atas', () async {
      final server = FakeServer((request) => jsonResponse(
            _reportJson(id: 9, message: 'Gambar poster tidak muncul'),
            201,
          ));
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server());

      expect(await store.send('  Gambar poster tidak muncul '), isTrue);

      expect(server.last.method, 'POST');
      expect(server.last.url.path, '/api/reports');
      expect(server.lastBody, {'message': 'Gambar poster tidak muncul'});
      expect(store.items.single.id, 'api-9');
    });

    test('send ditolak server: pesan validasi diteruskan', () async {
      final server = FakeServer((request) => jsonResponse({
            'message': 'x',
            'errors': {
              'message': ['Isi laporan minimal 5 karakter.'],
            },
          }, 422));
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server());

      expect(await store.send('abcde'), isFalse);
      expect(store.writeError, 'Isi laporan minimal 5 karakter.');
      expect(store.items, isEmpty);
    });

    test('admin menandai selesai: dikirim ke server, gagal tidak mengubah daftar',
        () async {
      var fail = false;
      final server = FakeServer((request) {
        if (request.method == 'GET') return jsonResponse([_reportJson()]);
        if (fail) return jsonResponse({'message': 'Server error'}, 500);
        return jsonResponse(_reportJson(status: 1));
      });
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server(admin: true));
      await store.load();

      fail = true;
      expect(await store.setSelesai('api-1', true), isFalse);
      expect(store.items.single.selesai, isFalse);
      expect(store.writeError, 'Server error');

      fail = false;
      expect(await store.setSelesai('api-1', true), isTrue);
      expect(server.last.method, 'PATCH');
      expect(server.last.url.path, '/api/reports/1');
      expect(server.lastBody, {'status': 1});
      expect(store.items.single.selesai, isTrue);
    });

    test('admin menghapus laporan; 404 dianggap sudah terhapus', () async {
      var status = 200;
      final server = FakeServer((request) {
        if (request.method == 'GET') {
          return jsonResponse([_reportJson(), _reportJson(id: 2)]);
        }
        return jsonResponse({'message': 'x'}, status);
      });
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server(admin: true));
      await store.load();

      status = 403;
      expect(await store.remove('api-1'), isFalse);
      expect(store.items.length, 2);

      status = 200;
      expect(await store.remove('api-1'), isTrue);
      expect(server.last.method, 'DELETE');
      expect(store.items.map((e) => e.id), ['api-2']);

      status = 404;
      expect(await store.remove('api-2'), isTrue);
      expect(store.items, isEmpty);
    });

    test('reset (keluar akun) mengosongkan laporan akun sebelumnya', () async {
      final server = FakeServer((request) => jsonResponse([_reportJson()]));
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server(admin: true));
      await store.load();

      store.reset();

      expect(store.items, isEmpty);
    });
  });

  group('Halaman laporan', () {
    Future<void> useSurface(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    Future<void> pumpPage(WidgetTester tester, ReportStore store) async {
      await useSurface(tester);
      await tester.pumpWidget(
        MaterialApp(home: ReportProblemPage(store: store)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('jamaah menulis laporan dan melihatnya sebagai gelembung',
        (tester) async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await pumpPage(tester, store);

      expect(find.text('Laporkan Permasalahan'), findsOneWidget);
      expect(find.textContaining("Assalamu'alaikum"), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Jadwal sholat kosong');
      await tester.tap(find.byTooltip('Kirim'));
      await tester.pumpAndSettle();

      expect(find.text('Jadwal sholat kosong'), findsOneWidget);
      expect(find.textContaining('Terkirim'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty);
      // Tidak ada lagi balasan otomatis.
      expect(find.text('Terima kasih atas laporan Anda.'), findsNothing);
      expect(store.items.length, 1);
    });

    testWidgets('laporan terlalu pendek ditolak dengan pesan', (tester) async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await pumpPage(tester, store);

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.tap(find.byTooltip('Kirim'));
      await tester.pump();

      expect(find.text('Isi laporan minimal 5 karakter.'), findsOneWidget);
      expect(store.items, isEmpty);
    });

    testWidgets('jamaah melihat laporannya yang sudah ditangani admin',
        (tester) async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await store.send('Foto profil gagal');
      AuthSession.login('admin', 'admin123');
      await store.setSelesai(store.items.single.id, true);
      AuthSession.login('jamaah', 'jamaah123');

      await pumpPage(tester, store);

      expect(find.text('Sudah ditangani admin'), findsOneWidget);
    });

    testWidgets('admin melihat laporan dari para jamaah', (tester) async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await store.send('Foto profil gagal diunggah');
      AuthSession.login('admin', 'admin123');
      await pumpPage(tester, store);

      expect(find.text('Laporan Masalah'), findsOneWidget);
      expect(find.text('Jamaah As-Syifa'), findsOneWidget);
      expect(find.text('Foto profil gagal diunggah'), findsOneWidget);
      expect(find.text('Baru'), findsOneWidget);
      expect(find.text('1 laporan baru dari 1 laporan'), findsOneWidget);
      // Tidak ada kolom tulis laporan pada tampilan admin.
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('admin menandai selesai lalu membuka lagi', (tester) async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await store.send('Foto profil gagal diunggah');
      AuthSession.login('admin', 'admin123');
      await pumpPage(tester, store);

      await tester.tap(find.text('Tandai selesai'));
      await tester.pumpAndSettle();
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Buka lagi'), findsOneWidget);
      expect(find.text('1 laporan, semuanya sudah ditangani'), findsOneWidget);

      await tester.tap(find.text('Buka lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Baru'), findsOneWidget);
    });

    testWidgets('admin menghapus laporan setelah konfirmasi', (tester) async {
      final store = ReportStore(remote: false);
      AuthSession.login('jamaah', 'jamaah123');
      await store.send('Foto profil gagal diunggah');
      AuthSession.login('admin', 'admin123');
      await pumpPage(tester, store);

      await tester.tap(find.byTooltip('Hapus laporan'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus laporan?'), findsOneWidget);

      // Batal: laporan tetap ada.
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Foto profil gagal diunggah'), findsOneWidget);

      await tester.tap(find.byTooltip('Hapus laporan'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Foto profil gagal diunggah'), findsNothing);
      expect(find.text('Belum ada laporan dari jamaah.'), findsOneWidget);
      expect(store.items, isEmpty);
    });

    testWidgets('admin: gagal memuat menampilkan pesan dan tombol coba lagi',
        (tester) async {
      final server = FakeServer(FakeServer.offline);
      final store = ReportStore(api: server.api, remote: true);
      AuthSession.startRemote(_server(admin: true));
      await pumpPage(tester, store);

      expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);

      server.handler = (_) => jsonResponse([_reportJson()]);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Jadwal sholat tidak muncul'), findsOneWidget);
    });
  });

  group('Halaman profil', () {
    Future<void> pumpProfile(WidgetTester tester, String id, String pw) async {
      final service = AccountService(remote: false);
      await service.signIn(id, pw);
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ProfilePages(accountService: service)),
        routes: {
          '/reportproblem': (_) => const ReportProblemPage(),
        },
      ));
    }

    testWidgets('pengaturan bahasa sudah dihapus', (tester) async {
      await pumpProfile(tester, 'jamaah', 'jamaah123');

      expect(find.text('Bahasa'), findsNothing);
      expect(find.text('Bahasa Indonesia'), findsNothing);
      expect(find.byIcon(Icons.translate_rounded), findsNothing);
    });

    testWidgets('jamaah: menu "Laporkan Permasalahan" membuka halaman tulis',
        (tester) async {
      await pumpProfile(tester, 'jamaah', 'jamaah123');

      await tester.tap(find.text('Laporkan Permasalahan'));
      await tester.pumpAndSettle();

      expect(find.byType(ReportSendPage), findsOneWidget);
    });

    testWidgets('admin: menu berisi laporan dari jamaah', (tester) async {
      await pumpProfile(tester, 'admin', 'admin123');

      expect(find.text('Laporkan Permasalahan'), findsNothing);
      await tester.tap(find.text('Laporan Masalah Jamaah'));
      await tester.pumpAndSettle();

      expect(find.byType(ReportInboxPage), findsOneWidget);
    });
  });
}
