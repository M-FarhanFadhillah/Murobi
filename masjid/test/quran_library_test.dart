import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:masjid/bloc/ayat/ayat_bloc.dart';
import 'package:masjid/cubit/surat/surat_cubit.dart';
import 'package:masjid/data/api_service.dart';
import 'package:masjid/data/models/surat_model.dart';
import 'package:masjid/data/quran_juz.dart';
import 'package:masjid/services/quran_reading_store.dart';
import 'package:masjid/services/quran_settings.dart';
import 'package:masjid/ui/ayat_page.dart';
import 'package:masjid/ui/surat_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_player.dart';
import 'support/no_bundled_quran.dart';

const Map<int, int> _ayatCount = {1: 7, 2: 286, 3: 200};

Map<String, dynamic> _suratJson(
  int nomor,
  String nama,
  String latin,
  String tempat,
  String arti,
) =>
    {
      'nomor': nomor,
      'nama': nama,
      'nama_latin': latin,
      'jumlah_ayat': _ayatCount[nomor],
      'tempat_turun': tempat,
      'arti': arti,
      'deskripsi': 'x',
      'audio':
          'https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/00$nomor.mp3',
    };

final List<Map<String, dynamic>> _suratList = [
  _suratJson(1, 'الفاتحة', 'Al-Fatihah', 'mekah', 'Pembukaan'),
  _suratJson(2, 'البقرة', 'Al-Baqarah', 'madinah', 'Sapi'),
  _suratJson(3, 'آل عمران', "Ali 'Imran", 'madinah', 'Keluarga Imran'),
];

http.Response _json(Object body) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

// Detail surat dengan ayat bernomor; teks Arab dibuat sederhana untuk uji.
Map<String, dynamic> _detailJson(int nomor) {
  final surat = _suratList.firstWhere((s) => s['nomor'] == nomor);
  return {
    ...surat,
    'status': true,
    'ayat': [
      for (var i = 1; i <= _ayatCount[nomor]!; i++)
        {
          'id': i,
          'surah': nomor,
          'nomor': i,
          'ar': 'arab $i',
          'tr': 'latin $i',
          'idn': 'terjemahan $i',
        },
    ],
    'surat_selanjutnya': false,
    'surat_sebelumnya': false,
  };
}

MockClient _client() => MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/surat') return _json(_suratList);
      return _json(_detailJson(int.parse(path.split('/').last)));
    });

QuranBookmark _bookmark(int surat, String nama, int ayat) => QuranBookmark(
      suratNomor: surat,
      suratNama: nama,
      ayatNomor: ayat,
      teksArab: 'arab $ayat',
      terjemahan: 'terjemahan $ayat',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('quranJuzStart', () {
    test('30 juz berurutan dan dimulai dari Al-Fatihah ayat 1', () {
      expect(quranJuzStart.length, 30);
      for (var i = 0; i < 30; i++) {
        expect(quranJuzStart[i].juz, i + 1);
      }
      expect(quranJuzStart.first.surat, 1);
      expect(quranJuzStart.first.ayat, 1);
    });

    test('posisi awal juz selalu maju (surah lalu ayat)', () {
      for (var i = 1; i < quranJuzStart.length; i++) {
        final before = quranJuzStart[i - 1];
        final current = quranJuzStart[i];
        final maju = current.surat > before.surat ||
            (current.surat == before.surat && current.ayat > before.ayat);
        expect(maju, isTrue, reason: 'Juz ${current.juz}');
        expect(current.surat, inInclusiveRange(1, 114));
      }
    });

    test('beberapa awal juz yang terkenal', () {
      QuranJuzStart juz(int n) => quranJuzStart[n - 1];
      expect([juz(2).surat, juz(2).ayat], [2, 142]);
      expect([juz(3).surat, juz(3).ayat], [2, 253]);
      expect([juz(15).surat, juz(15).ayat], [17, 1]);
      expect([juz(29).surat, juz(29).ayat], [67, 1]);
      expect([juz(30).surat, juz(30).ayat], [78, 1]);
    });
  });

  group('QuranReadingStore', () {
    test('toggleBookmark menandai lalu menghapus tanda', () async {
      final store = QuranReadingStore();

      expect(
        await store.toggleBookmark(_bookmark(1, 'Al-Fatihah', 1)),
        BookmarkResult.added,
      );
      expect(store.isBookmarked(1, 1), isTrue);
      expect(store.isBookmarked(1, 2), isFalse);

      expect(
        await store.toggleBookmark(_bookmark(1, 'Al-Fatihah', 1)),
        BookmarkResult.removed,
      );
      expect(store.isBookmarked(1, 1), isFalse);
    });

    test('tanda terbaru di atas dan tersimpan di perangkat', () async {
      final store = QuranReadingStore();
      await store.toggleBookmark(_bookmark(1, 'Al-Fatihah', 1));
      await store.toggleBookmark(_bookmark(2, 'Al-Baqarah', 255));

      expect(store.bookmarks.map((b) => b.key), ['2:255', '1:1']);

      final reloaded = QuranReadingStore();
      await reloaded.load();
      expect(reloaded.bookmarks.map((b) => b.key), ['2:255', '1:1']);
      expect(reloaded.bookmarks.first.terjemahan, 'terjemahan 255');
    });

    test('removeBookmark mengubah daftar seketika', () async {
      final store = QuranReadingStore();
      await store.toggleBookmark(_bookmark(1, 'Al-Fatihah', 1));

      final future = store.removeBookmark(1, 1);
      expect(store.bookmarks, isEmpty);
      await future;

      final reloaded = QuranReadingStore();
      await reloaded.load();
      expect(reloaded.bookmarks, isEmpty);
    });

    test('jumlah tanda dibatasi maxBookmarks', () async {
      final store = QuranReadingStore();
      for (var i = 1; i <= QuranReadingStore.maxBookmarks; i++) {
        await store.toggleBookmark(_bookmark(2, 'Al-Baqarah', i));
      }

      expect(
        await store.toggleBookmark(_bookmark(3, "Ali 'Imran", 1)),
        BookmarkResult.limitReached,
      );
      expect(store.bookmarks.length, QuranReadingStore.maxBookmarks);

      // Menghapus tanda yang sudah ada tetap diperbolehkan saat penuh.
      expect(
        await store.toggleBookmark(_bookmark(2, 'Al-Baqarah', 1)),
        BookmarkResult.removed,
      );
    });

    test('posisi terakhir dibaca tersimpan; nilai sama tidak menulis ulang',
        () async {
      final store = QuranReadingStore();
      var notified = 0;
      store.addListener(() => notified++);

      const posisi = QuranLastRead(
        suratNomor: 2,
        suratNama: 'Al-Baqarah',
        ayatNomor: 142,
      );
      await store.setLastRead(posisi);
      await store.setLastRead(posisi);
      expect(notified, 1);

      final reloaded = QuranReadingStore();
      await reloaded.load();
      expect(reloaded.lastRead?.suratNomor, 2);
      expect(reloaded.lastRead?.ayatNomor, 142);
      expect(reloaded.lastRead?.suratNama, 'Al-Baqarah');
    });

    test('data tersimpan yang rusak diabaikan', () async {
      SharedPreferences.setMockInitialValues({
        'quran_bookmarks_v1': 'bukan json',
        'quran_last_read_v1': '{rusak',
      });
      final store = QuranReadingStore();
      await store.load();

      expect(store.bookmarks, isEmpty);
      expect(store.lastRead, isNull);
    });
  });

  Future<QuranReadingStore> pumpSuratPage(
    WidgetTester tester, {
    QuranReadingStore? store,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final reading = store ?? QuranReadingStore();
    final client = _client();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (_) => SuratCubit(
                    ApiService(bundle: noBundledQuran, client: client))),
            BlocProvider(
                create: (_) => AyatBloc(
                    ApiService(bundle: noBundledQuran, client: client))),
          ],
          child: SuratPage(
            readingStore: reading,
            settings: QuranSettings(),
            createAudioPlayer: () => FakeAudioPlayer(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return reading;
  }

  group('SuratPage', () {
    testWidgets('tab Surah menampilkan daftar surah', (tester) async {
      await pumpSuratPage(tester);

      expect(find.text('Al-Fatihah'), findsOneWidget);
      expect(find.text('Al-Baqarah'), findsOneWidget);
      expect(find.text('Terakhir dibaca'), findsNothing);
    });

    testWidgets('tab Juz menampilkan awal setiap juz', (tester) async {
      await pumpSuratPage(tester);

      await tester.tap(find.text('Juz'));
      await tester.pumpAndSettle();

      expect(find.text('Juz 1'), findsOneWidget);
      expect(find.text('Mulai dari Al-Fatihah ayat 1'), findsOneWidget);
      expect(find.text('Juz 2'), findsOneWidget);
      expect(find.text('Mulai dari Al-Baqarah ayat 142'), findsOneWidget);
    });

    testWidgets('pencarian di tab Juz menyaring berdasarkan nama surah',
        (tester) async {
      await pumpSuratPage(tester);
      await tester.tap(find.text('Juz'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'baqarah');
      await tester.pumpAndSettle();

      expect(find.text('Juz 2'), findsOneWidget);
      expect(find.text('Juz 3'), findsOneWidget);
      expect(find.text('Juz 1'), findsNothing);
    });

    testWidgets('mengetuk Juz membuka surah langsung di ayat awalnya',
        (tester) async {
      await pumpSuratPage(tester);
      await tester.tap(find.text('Juz'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Juz 3'));
      await tester.pumpAndSettle();

      // Al-Baqarah ayat 253 tampil tanpa menggulir manual.
      expect(find.text('2:253 terjemahan 253'), findsOneWidget);
      expect(find.text('2:1 terjemahan 1'), findsNothing);
    });

    testWidgets('tab Bookmark kosong menampilkan petunjuk', (tester) async {
      await pumpSuratPage(tester);

      await tester.tap(find.text('Bookmark'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada ayat yang ditandai'), findsOneWidget);
    });

    testWidgets('tab Bookmark menampilkan, membuka, dan menghapus tanda',
        (tester) async {
      final store = QuranReadingStore();
      await store.toggleBookmark(_bookmark(2, 'Al-Baqarah', 255));
      await pumpSuratPage(tester, store: store);

      await tester.tap(find.text('Bookmark'));
      await tester.pumpAndSettle();
      expect(find.text('Al-Baqarah • Ayat 255'), findsOneWidget);
      expect(find.text('terjemahan 255'), findsOneWidget);

      // Membuka tanda langsung ke ayatnya.
      await tester.tap(find.text('Al-Baqarah • Ayat 255'));
      await tester.pumpAndSettle();
      expect(find.text('2:255 terjemahan 255'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Hapus tanda'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada ayat yang ditandai'), findsOneWidget);
      expect(store.bookmarks, isEmpty);
    });

    testWidgets('kartu "Terakhir dibaca" membuka surah di ayat tersimpan',
        (tester) async {
      final store = QuranReadingStore();
      await store.setLastRead(const QuranLastRead(
        suratNomor: 2,
        suratNama: 'Al-Baqarah',
        ayatNomor: 142,
      ));
      await pumpSuratPage(tester, store: store);

      expect(find.text('Terakhir dibaca'), findsOneWidget);
      expect(find.text('Ayat No: 142'), findsOneWidget);

      await tester.tap(find.text('Terakhir dibaca'));
      await tester.pumpAndSettle();
      expect(find.text('2:142 terjemahan 142'), findsOneWidget);
    });

    testWidgets('membaca surah mencatat posisi terakhir dibaca',
        (tester) async {
      final store = await pumpSuratPage(tester);

      await tester.tap(find.text('Al-Fatihah'));
      await tester.pumpAndSettle();
      expect(store.lastRead?.suratNomor, 1);
      expect(store.lastRead?.ayatNomor, 1);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Terakhir dibaca'), findsOneWidget);
      expect(find.text('Ayat No: 1'), findsOneWidget);
    });
  });

  group('AyatPage (tanda dan posisi)', () {
    final surat2 = SuratModel.fromJson(_suratList[1]);

    Future<QuranReadingStore> pumpAyat(
      WidgetTester tester, {
      int initialAyat = 1,
      QuranReadingStore? store,
    }) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final reading = store ?? QuranReadingStore();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) =>
                AyatBloc(ApiService(bundle: noBundledQuran, client: _client())),
            child: AyatPage(
              surat: surat2,
              initialAyat: initialAyat,
              settings: QuranSettings(),
              readingStore: reading,
              createAudioPlayer: () => FakeAudioPlayer(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return reading;
    }

    testWidgets('initialAyat langsung menampilkan ayat tersebut',
        (tester) async {
      await pumpAyat(tester, initialAyat: 200);

      expect(find.text('2:200 terjemahan 200'), findsOneWidget);
      expect(find.text('2:1 terjemahan 1'), findsNothing);
    });

    testWidgets('initialAyat di luar rentang dibatasi ke ayat terakhir',
        (tester) async {
      await pumpAyat(tester, initialAyat: 9999);

      expect(find.text('2:286 terjemahan 286'), findsOneWidget);
    });

    testWidgets('ikon tanda: menandai dan menghapus tanda ayat',
        (tester) async {
      final store = await pumpAyat(tester);

      await tester.tap(find.byTooltip('Tandai ayat').first);
      await tester.pumpAndSettle();
      expect(store.isBookmarked(2, 1), isTrue);
      expect(find.textContaining('Ayat ditandai'), findsOneWidget);
      expect(find.byTooltip('Hapus tanda ayat'), findsOneWidget);

      await tester.tap(find.byTooltip('Hapus tanda ayat'));
      await tester.pumpAndSettle();
      expect(store.isBookmarked(2, 1), isFalse);
      expect(find.byTooltip('Hapus tanda ayat'), findsNothing);
    });

    testWidgets('tanda yang tersimpan tampil sebagai ikon terisi',
        (tester) async {
      final store = QuranReadingStore();
      await store.toggleBookmark(_bookmark(2, 'Al-Baqarah', 1));
      await pumpAyat(tester, store: store);

      expect(find.byTooltip('Hapus tanda ayat'), findsOneWidget);
    });

    testWidgets('menggulir memperbarui posisi terakhir dibaca', (tester) async {
      final store = await pumpAyat(tester);
      expect(store.lastRead?.ayatNomor, 1);

      await tester.drag(
        find.byType(ScrollablePositionedList),
        const Offset(0, -2500),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(store.lastRead!.ayatNomor, greaterThan(3));
      expect(store.lastRead!.suratNomor, 2);
    });
  });
}
