import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/common/waktu.dart';
import 'package:masjid/common/youtube_link.dart';
import 'package:masjid/screens/dashboard/edukasi_detail_page.dart';
import 'package:masjid/screens/dashboard/edukasi_form_page.dart';
import 'package:masjid/screens/dashboard/edukasi_pages.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/edukasi_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DateTime _now = DateTime(2026, 10, 12, 12);

final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

EdukasiStore _newStore() => EdukasiStore(clock: () => _now);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetForTest();
  });

  group('youtube_link', () {
    const id = 'dQw4w9WgXcQ';

    test('mengambil ID dari berbagai bentuk tautan', () {
      expect(youtubeVideoId('https://www.youtube.com/watch?v=$id'), id);
      expect(youtubeVideoId('https://youtu.be/$id?t=10'), id);
      expect(youtubeVideoId('https://m.youtube.com/watch?v=$id&list=PL1'), id);
      expect(youtubeVideoId('youtube.com/shorts/$id'), id);
      expect(youtubeVideoId('https://www.youtube.com/embed/$id'), id);
      expect(youtubeVideoId('  https://youtu.be/$id  '), id);
    });

    test('menolak tautan yang bukan video YouTube', () {
      expect(youtubeVideoId(''), isNull);
      expect(youtubeVideoId('https://www.youtube.com/results?search_query=a'),
          isNull);
      expect(youtubeVideoId('https://contoh.com/watch?v=$id'), isNull);
      expect(youtubeVideoId('https://www.youtube.com/watch?v=pendek'), isNull);
      expect(youtubeVideoId('javascript:alert(1)'), isNull);
      expect(youtubeVideoId('ftp://youtube.com/watch?v=$id'), isNull);
    });

    test('alamat gambar mini', () {
      expect(
        youtubeThumbnailUri('https://youtu.be/$id').toString(),
        'https://img.youtube.com/vi/$id/mqdefault.jpg',
      );
      expect(
        youtubeThumbnailUri('https://youtu.be/$id', large: true).toString(),
        'https://img.youtube.com/vi/$id/hqdefault.jpg',
      );
      expect(youtubeThumbnailUri('https://contoh.com'), isNull);
    });

    test('safeWebUri hanya menerima http/https', () {
      expect(safeWebUri('https://contoh.com/a')?.host, 'contoh.com');
      expect(safeWebUri('contoh.com/a')?.scheme, 'https');
      expect(safeWebUri('tel:123'), isNull);
      expect(safeWebUri('mailto:a@b.com'), isNull);
      expect(safeWebUri('intent://x#Intent;end'), isNull);
      expect(safeWebUri(''), isNull);
    });
  });

  group('waktuRelatif', () {
    String lalu(Duration d) => waktuRelatif(_now.subtract(d), sekarang: _now);

    test('satuan waktu dalam bahasa Indonesia', () {
      expect(lalu(const Duration(seconds: 20)), 'baru saja');
      expect(lalu(const Duration(minutes: 5)), '5 menit lalu');
      expect(lalu(const Duration(hours: 4)), '4 jam lalu');
      expect(lalu(const Duration(days: 3)), '3 hari lalu');
      expect(lalu(const Duration(days: 14)), '2 minggu lalu');
      expect(lalu(const Duration(days: 90)), '3 bulan lalu');
      expect(lalu(const Duration(days: 800)), '2 tahun lalu');
    });

    test('waktu di masa depan dianggap baru saja', () {
      expect(waktuRelatif(_now.add(const Duration(hours: 1)), sekarang: _now),
          'baru saja');
    });
  });

  group('EdukasiStore', () {
    test('berisi materi bawaan: 15 materi dan 3 video', () async {
      final store = _newStore();
      await store.load();

      expect(store.items.length, 15);
      expect(store.items.where((e) => e.isVideo).length, 3);
      expect(store.byKategori('Rekomendasi').length, 3);
      expect(store.byKategori('Anak-anak').length, 4);
      expect(store.byKategori('Remaja').length, 4);
      expect(store.byKategori('Orang Tua').length, 4);
    });

    test('materi video bawaan memakai tautan pencarian YouTube', () async {
      final store = _newStore();
      final video = store.byId('seed-anak-video')!;

      expect(video.isVideo, isTrue);
      expect(video.videoUrl, startsWith('https://www.youtube.com/results'));
      expect(video.videoUrl, contains('belajar+wudhu+untuk+anak'));
      expect(safeWebUri(video.videoUrl!), isNotNull);
    });

    test('daftar kategori diurutkan dari yang terbaru', () async {
      final store = _newStore();
      final terbaru = store.byKategori('Anak-anak').map((e) => e.id).toList();

      // video 8 jam, artikel 3 jam, 1 hari, 3 hari.
      expect(terbaru.first, 'seed-anak-1');
      expect(terbaru.last, 'seed-anak-3');
      expect(
        waktuRelatif(store.byId('seed-anak-1')!.createdAt, sekarang: _now),
        '3 jam lalu',
      );
    });

    test('data bawaan disimpan sekali saat pertama kali dimuat', () async {
      final store = _newStore();
      await store.load();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('edukasi_v1'), isNotNull);
    });

    test('add menaruh materi baru di urutan teratas dan menyimpannya',
        () async {
      final store = _newStore();
      final saved = await store.add(EdukasiItem(
        id: store.newId(),
        judul: 'Materi baru dari admin',
        kategori: 'Remaja',
        tipe: EdukasiType.artikel,
        penulis: 'Admin Masjid',
        createdAt: _now,
        isi: 'Isi materi yang cukup panjang untuk diuji.',
        coverBytes: _png,
      ));

      expect(saved, isTrue);
      expect(store.byKategori('Remaja').first.judul, 'Materi baru dari admin');

      final reloaded = _newStore();
      await reloaded.load();
      final item = reloaded.byKategori('Remaja').first;
      expect(item.judul, 'Materi baru dari admin');
      expect(item.coverBytes, _png);
      expect(reloaded.items.length, 16);
    });

    test('video tersimpan lengkap dengan tautannya', () async {
      final store = _newStore();
      await store.add(EdukasiItem(
        id: 'v1',
        judul: 'Video baru',
        kategori: 'Anak-anak',
        tipe: EdukasiType.video,
        penulis: 'Admin Masjid',
        createdAt: _now,
        videoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      ));

      final reloaded = _newStore();
      await reloaded.load();
      final video = reloaded.byId('v1')!;
      expect(video.isVideo, isTrue);
      expect(video.videoUrl, 'https://youtu.be/dQw4w9WgXcQ');
    });

    test('update mengganti materi; id tidak dikenal ditolak', () async {
      final store = _newStore();
      final asli = store.byId('seed-remaja-1')!;

      final ok = await store.update(EdukasiItem(
        id: asli.id,
        judul: 'Judul diubah',
        kategori: 'Anak-anak',
        tipe: asli.tipe,
        penulis: asli.penulis,
        createdAt: asli.createdAt,
        isi: asli.isi,
        coverAsset: asli.coverAsset,
      ));
      expect(ok, isTrue);
      expect(store.byId('seed-remaja-1')!.judul, 'Judul diubah');
      expect(store.byKategori('Remaja').length, 3);
      expect(store.byKategori('Anak-anak').length, 5);

      final tidakAda = await store.update(EdukasiItem(
        id: 'tidak-ada',
        judul: 'x',
        kategori: 'Remaja',
        tipe: EdukasiType.artikel,
        penulis: 'x',
        createdAt: _now,
      ));
      expect(tidakAda, isFalse);
    });

    test('remove mengubah daftar seketika dan tersimpan', () async {
      final store = _newStore();
      await store.load();

      final future = store.remove('seed-ortu-video');
      expect(store.byId('seed-ortu-video'), isNull);
      await future;

      final reloaded = _newStore();
      await reloaded.load();
      expect(reloaded.byId('seed-ortu-video'), isNull);
      expect(reloaded.items.length, 14);
    });

    test('data tersimpan yang rusak diganti data bawaan', () async {
      SharedPreferences.setMockInitialValues({'edukasi_v1': '{bukan json'});
      final store = _newStore();
      await store.load();

      expect(store.items.length, 15);
    });

    test('jumlah materi dibatasi maxItems', () async {
      final store = _newStore();
      await store.load();

      var index = 0;
      while (store.canAddMore) {
        final ok = await store.add(EdukasiItem(
          id: 'x${index++}',
          judul: 'Materi $index',
          kategori: 'Remaja',
          tipe: EdukasiType.artikel,
          penulis: 'Admin',
          createdAt: _now,
          isi: 'Isi',
        ));
        expect(ok, isTrue);
      }

      expect(store.items.length, EdukasiStore.maxItems);
      final penuh = await store.add(EdukasiItem(
        id: 'lebih',
        judul: 'Terlalu banyak',
        kategori: 'Remaja',
        tipe: EdukasiType.artikel,
        penulis: 'Admin',
        createdAt: _now,
      ));
      expect(penuh, isFalse);
    });
  });

  Future<EdukasiStore> pumpEdukasi(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = _newStore();
    await tester.pumpWidget(MaterialApp(home: EdukasiWidget(store: store)));
    await tester.pumpAndSettle();
    return store;
  }

  group('EdukasiWidget', () {
    testWidgets('jamaah: daftar per kategori dengan penanda Video',
        (tester) async {
      await pumpEdukasi(tester);

      expect(find.text('11 Kampus Ini Tawarkan Beasiswa Hafidz Al-Qur\'an'),
          findsOneWidget);
      expect(find.text('Video'), findsNothing);

      await tester.tap(find.text('Anak-anak'));
      await tester.pumpAndSettle();

      expect(find.text('Video: Belajar Wudhu untuk Anak'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget); // penanda pada kartu video
      expect(find.text('Mengenal Rukun Islam untuk Anak'), findsOneWidget);
    });

    testWidgets('jamaah tidak melihat tombol Tambah maupun geser-hapus',
        (tester) async {
      await pumpEdukasi(tester);

      expect(find.text('Tambah materi'), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('mengetuk kartu membuka detail materi', (tester) async {
      await pumpEdukasi(tester);

      await tester.tap(find.text('Adab Masuk dan Keluar Masjid'));
      await tester.pumpAndSettle();

      expect(find.textContaining('mendahulukan kaki kanan'), findsOneWidget);
      expect(find.text('Oleh Admin Masjid • 2 hari lalu'), findsOneWidget);
    });

    testWidgets('admin: tombol Tambah dan geser-hapus dengan konfirmasi',
        (tester) async {
      AuthSession.login('admin', 'admin123');
      final store = await pumpEdukasi(tester);

      expect(find.text('Tambah materi'), findsOneWidget);
      expect(find.byType(Dismissible), findsWidgets);

      await tester.drag(find.byType(Dismissible).first, const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Hapus materi?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(store.byId('seed-rekomendasi-1'), isNull);
      expect(store.byKategori('Rekomendasi').length, 2);
    });

    testWidgets('admin: membatalkan hapus menyisakan materi', (tester) async {
      AuthSession.login('admin', 'admin123');
      final store = await pumpEdukasi(tester);

      await tester.drag(find.byType(Dismissible).first, const Offset(600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(store.byKategori('Rekomendasi').length, 3);
    });

    testWidgets('admin: menambah artikel lewat formulir', (tester) async {
      AuthSession.login('admin', 'admin123');
      final store = await pumpEdukasi(tester);

      await tester.tap(find.text('Tambah materi'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Materi'), findsOneWidget);

      // Kosong: pesan validasi.
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Judul wajib diisi'), findsOneWidget);
      expect(find.text('Isi artikel wajib diisi'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul'),
        'Keutamaan Sholat Subuh',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Isi artikel'),
        'Sholat Subuh berjamaah memberi ketenangan sejak awal hari.',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Kembali ke daftar dengan pesan; kategori awal = Rekomendasi (tab aktif).
      expect(find.text('Materi berhasil disimpan.'), findsOneWidget);
      expect(find.text('Keutamaan Sholat Subuh'), findsOneWidget);
      expect(store.byKategori('Rekomendasi').first.judul,
          'Keutamaan Sholat Subuh');
      expect(store.byKategori('Rekomendasi').first.penulis, 'Admin Masjid');
    });
  });

  group('EdukasiFormPage', () {
    Future<EdukasiStore> pumpForm(
      WidgetTester tester, {
      EdukasiItem? existing,
      Future<Uint8List?> Function()? pickCover,
    }) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final store = _newStore();
      await tester.pumpWidget(
        MaterialApp(
          home: EdukasiFormPage(
            store: store,
            existing: existing,
            initialKategori: 'Anak-anak',
            pickCover: pickCover,
          ),
        ),
      );
      return store;
    }

    testWidgets('video: tautan wajib dan harus tautan YouTube yang valid',
        (tester) async {
      final store = await pumpForm(tester);

      await tester.tap(find.text('Video'));
      await tester.pump();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Judul'), 'Belajar Sholat');

      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Tautan video wajib diisi'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tautan video YouTube'),
        'https://contoh.com/video',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.textContaining('tautan video YouTube yang valid'),
          findsOneWidget);
      expect(store.items.where((e) => e.judul == 'Belajar Sholat'), isEmpty);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tautan video YouTube'),
        'https://youtu.be/dQw4w9WgXcQ',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final video =
          store.items.firstWhere((e) => e.judul == 'Belajar Sholat');
      expect(video.isVideo, isTrue);
      expect(video.kategori, 'Anak-anak');
      expect(video.videoUrl, 'https://youtu.be/dQw4w9WgXcQ');
      expect(video.coverBytes, isNull);
    });

    testWidgets('artikel: gambar sampul dipilih lewat pemilih gambar',
        (tester) async {
      final store = await pumpForm(tester, pickCover: () async => _png);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Judul'), 'Adab Makan');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Isi artikel'),
        'Membaca basmalah sebelum makan dan makan dengan tangan kanan.',
      );
      await tester.tap(find.text('Pilih gambar sampul'));
      await tester.pump();
      expect(find.text('Ganti gambar'), findsOneWidget);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final artikel = store.items.firstWhere((e) => e.judul == 'Adab Makan');
      expect(artikel.coverBytes, _png);
    });

    testWidgets('mengubah materi yang ada mempertahankan id dan waktu',
        (tester) async {
      final store = _newStore();
      final asli = store.byId('seed-remaja-2')!;
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(home: EdukasiFormPage(store: store, existing: asli)),
      );

      expect(find.text('Ubah Materi'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextFormField, 'Judul'),
          'Tips Mengaji yang Diperbarui');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final baru = store.byId('seed-remaja-2')!;
      expect(baru.judul, 'Tips Mengaji yang Diperbarui');
      expect(baru.createdAt, asli.createdAt);
      expect(store.items.length, 15);
    });

    testWidgets('video bawaan dengan tautan pencarian dapat disimpan tanpa mengubah tautan',
        (tester) async {
      final store = _newStore();
      final video = store.byId('seed-anak-video')!;
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(home: EdukasiFormPage(store: store, existing: video)),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Judul'),
          'Video: Wudhu Anak (diubah)');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(store.byId('seed-anak-video')!.judul, 'Video: Wudhu Anak (diubah)');
    });
  });

  group('EdukasiDetailPage', () {
    Future<EdukasiStore> pumpDetail(
      WidgetTester tester,
      String id, {
      Future<bool> Function(String url)? openUrl,
    }) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final store = _newStore();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EdukasiDetailPage(
                        itemId: id,
                        store: store,
                        openUrl: openUrl,
                      ),
                    ),
                  ),
                  child: const Text('buka detail'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka detail'));
      await tester.pumpAndSettle();
      return store;
    }

    testWidgets('video: tombol Tonton Video membuka tautannya', (tester) async {
      String? dibuka;
      await pumpDetail(tester, 'seed-anak-video', openUrl: (url) async {
        dibuka = url;
        return true;
      });

      expect(find.text('Tonton Video'), findsOneWidget);
      await tester.tap(find.text('Tonton Video'));
      await tester.pump();

      expect(dibuka, contains('youtube.com/results'));
    });

    testWidgets('video: pesan jika tautan tidak dapat dibuka', (tester) async {
      await pumpDetail(tester, 'seed-anak-video', openUrl: (_) async => false);

      await tester.tap(find.text('Tonton Video'));
      await tester.pump();

      expect(find.textContaining('Video tidak dapat dibuka'), findsOneWidget);
    });

    testWidgets('artikel tidak punya tombol Tonton Video', (tester) async {
      await pumpDetail(tester, 'seed-anak-1');

      expect(find.text('Tonton Video'), findsNothing);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.textContaining('Rukun Islam ada lima'), findsOneWidget);
    });

    testWidgets('jamaah tidak melihat aksi ubah dan hapus', (tester) async {
      await pumpDetail(tester, 'seed-anak-1');

      expect(find.byTooltip('Ubah materi'), findsNothing);
      expect(find.byTooltip('Hapus materi'), findsNothing);
    });

    testWidgets('admin menghapus materi dari halaman detail', (tester) async {
      AuthSession.login('admin', 'admin123');
      final store = await pumpDetail(tester, 'seed-anak-1');

      await tester.tap(find.byTooltip('Hapus materi'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus materi?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(store.byId('seed-anak-1'), isNull);
      expect(find.text('buka detail'), findsOneWidget); // kembali ke halaman awal
      expect(find.text('Materi dihapus.'), findsOneWidget);
    });

    testWidgets('admin mengubah materi dari halaman detail', (tester) async {
      AuthSession.login('admin', 'admin123');
      await pumpDetail(tester, 'seed-anak-1');

      await tester.tap(find.byTooltip('Ubah materi'));
      await tester.pumpAndSettle();
      expect(find.text('Ubah Materi'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Judul'),
          'Rukun Islam untuk Si Kecil');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Rukun Islam untuk Si Kecil'), findsOneWidget);
      expect(find.text('Perubahan disimpan.'), findsOneWidget);
    });
  });
}
