import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:masjid/bloc/ayat/ayat_bloc.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/data/api_service.dart';
import 'package:masjid/data/models/surat_model.dart';
import 'package:masjid/services/quran_settings.dart';
import 'package:masjid/ui/ayat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_player.dart';
import 'support/ttf_glyphs.dart';

// Transliterasi Latin Al-Qur'an memakai huruf bertitik (ḍ ḥ ṣ ṭ ẓ ṡ) yang tidak
// ada di Poppins. Tanpa font cadangan, huruf itu tampil sebagai kotak di
// perangkat yang tidak punya font sistem pengganti (mis. emulator MuMu).
// Tes ini memastikan font cadangan disertakan di aplikasi, memuat semua huruf
// yang dipakai, dan benar-benar dipasang pada teks Latin halaman ayat.

const String _fontAsset = 'assets/fonts/RobotoStatic-Regular.ttf';

// Teks 114 surah bawaan hanya ada bila assets/quran/ disertakan di proyek.
final String? _tanpaDataBawaan = File('assets/quran/surat.json').existsSync()
    ? null
    : 'assets/quran/ belum disertakan di proyek ini';

const String _huruf = 'ḌḍḤḥṠṡṢṣṬṭẓ';

final SuratModel _surat = SuratModel(
  nomor: 1,
  nama: 'الفاتحة',
  namaLatin: 'Al-Fatihah',
  jumlahAyat: 1,
  tempatTurun: TempatTurun.MEKAH,
  arti: 'Pembukaan',
  deskripsi: 'x',
  audio: 'https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/001.mp3',
);

const String _transliterasi = 'Bismillāhir-raḥmānir-raḥīm(i).';

http.Response _detailResponse() {
  final body = jsonEncode({
    'nomor': 1,
    'nama': 'الفاتحة',
    'nama_latin': 'Al-Fatihah',
    'jumlah_ayat': 1,
    'tempat_turun': 'mekah',
    'arti': 'Pembukaan',
    'deskripsi': 'x',
    'audio': 'u',
    'status': true,
    'ayat': [
      {
        'id': 1,
        'surah': 1,
        'nomor': 1,
        'ar': 'بِسْمِ اللَّهِ',
        'tr': _transliterasi,
        'idn': 'Dengan nama Allah',
      },
    ],
    'surat_selanjutnya': false,
    'surat_sebelumnya': false,
  });
  return http.Response.bytes(
    utf8.encode(body),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

// Karakter kontrol tidak punya glyph di font mana pun, jadi tidak bisa diatasi
// dengan font. Data bawaan masih memuat U+0091 (tanda ‘ yang salah baca dari
// cp1252) pada 5:101, 9:69, 23:3, 30:56, dan 44:47; itu galat data, bukan font.
bool _isControl(int codePoint) =>
    codePoint < 0x20 || (codePoint >= 0x7F && codePoint < 0xA0);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  late Set<int> glyphs;

  setUpAll(() async {
    final font = await rootBundle.load(_fontAsset);
    glyphs = ttfCodePoints(font.buffer.asUint8List(
      font.offsetInBytes,
      font.lengthInBytes,
    ));
  });

  group('Font cadangan transliterasi Latin', () {
    test('berkas font terdaftar di pubspec dan dapat dimuat sebagai font',
        () async {
      final font = await rootBundle.load(_fontAsset);
      expect(font.lengthInBytes, greaterThan(100 * 1024));

      final loader = FontLoader(AppFonts.latinExtended)
        ..addFont(Future<ByteData>.value(font));
      await loader.load();
    });

    test('pembaca cmap membedakan huruf yang ada dan yang tidak ada', () {
      expect(glyphs, contains('a'.codeUnitAt(0)));
      expect(glyphs, isNot(contains(0x0E01))); // huruf Thai, tidak ada
      expect(glyphs, isNot(contains(0x0627))); // huruf Arab, tidak ada
    });

    test('memuat huruf bertitik yang tidak ada di Poppins', () {
      final hilang = _huruf.runes.where((r) => !glyphs.contains(r)).toList();

      expect(
        hilang.map((r) => String.fromCharCode(r)).join(' '),
        isEmpty,
        reason: 'Huruf ini akan tampil sebagai kotak',
      );
    });

    test('memuat huruf bermakron dan tanda kutip yang dipakai transliterasi',
        () {
      const dipakai = 'āīūĀżʿ‘’…';
      final hilang = dipakai.runes.where((r) => !glyphs.contains(r)).toList();

      expect(hilang.map((r) => String.fromCharCode(r)).join(' '), isEmpty);
    });

    test('semua karakter transliterasi 114 surah termuat di font cadangan',
        () async {
      final dipakai = <int, String>{};
      for (var nomor = 1; nomor <= 114; nomor++) {
        final json = jsonDecode(
          await rootBundle.loadString('assets/quran/surat_$nomor.json'),
        ) as Map<String, dynamic>;
        for (final ayat in json['ayat'] as List) {
          final tr = (ayat as Map<String, dynamic>)['tr'] as String? ?? '';
          for (final rune in tr.runes) {
            dipakai.putIfAbsent(rune, () => 'surah $nomor ayat ${ayat['nomor']}');
          }
        }
      }

      final hilang = dipakai.keys
          .where((r) => !_isControl(r) && !glyphs.contains(r))
          .map((r) =>
              'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')} '
              '(${String.fromCharCode(r)}) di ${dipakai[r]}')
          .toList();

      expect(hilang, isEmpty);
      // Pastikan tes ini memang membaca teks yang memuat huruf bertitik.
      expect(dipakai.keys, contains(0x1E25));
    }, skip: _tanpaDataBawaan);
  });

  group('Teks Latin di halaman ayat', () {
    Future<Text> pumpAyatPage(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => AyatBloc(ApiService(
              client: MockClient((_) async => _detailResponse()),
            )),
            child: AyatPage(
              surat: _surat,
              settings: QuranSettings(),
              createAudioPlayer: () => FakeAudioPlayer(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      return tester.widget<Text>(find.textContaining('raḥmānir').first);
    }

    testWidgets('memakai font cadangan yang memuat seluruh teksnya',
        (tester) async {
      final text = await pumpAyatPage(tester);

      final context = tester.element(find.textContaining('raḥmānir').first);
      final style = DefaultTextStyle.of(context).style.merge(text.style);
      expect(style.fontFamilyFallback, contains(AppFonts.latinExtended));

      final hilang =
          text.data!.runes.where((r) => !glyphs.contains(r)).toList();
      expect(hilang.map((r) => String.fromCharCode(r)).join(' '), isEmpty);
    });
  });
}
