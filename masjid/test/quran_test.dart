import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:masjid/bloc/ayat/ayat_bloc.dart';
import 'package:masjid/data/api_service.dart';
import 'package:masjid/data/models/surat_model.dart';
import 'package:masjid/services/quran_settings.dart';
import 'package:masjid/ui/ayat_page.dart';
import 'package:masjid/widget/quran_audio_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_player.dart';

const String _audioUrl =
    'https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/001.mp3';

final SuratModel _surat = SuratModel(
  nomor: 1,
  nama: 'الفاتحة',
  namaLatin: 'Al-Fatihah',
  jumlahAyat: 2,
  tempatTurun: TempatTurun.MEKAH,
  arti: 'Pembukaan',
  deskripsi: 'x',
  audio: _audioUrl,
);

// Respons detail surat seperti dari equran.id (surat terakhir: surat_selanjutnya false).
http.Response _detailResponse({bool lastSurah = false}) {
  final body = jsonEncode({
    'nomor': 1,
    'nama': 'الفاتحة',
    'nama_latin': 'Al-Fatihah',
    'jumlah_ayat': 2,
    'tempat_turun': 'mekah',
    'arti': 'Pembukaan',
    'deskripsi': 'x',
    'audio': _audioUrl,
    'status': true,
    'ayat': [
      {
        'id': 1,
        'surah': 1,
        'nomor': 1,
        'ar': 'بِسْمِ',
        'tr': 'Bismi',
        'idn': 'Dengan nama Allah'
      },
      {
        'id': 2,
        'surah': 1,
        'nomor': 2,
        'ar': 'الْحَمْدُ',
        'tr': 'Alhamdu',
        'idn': 'Segala puji'
      },
    ],
    'surat_selanjutnya': lastSurah
        ? false
        : {
            'id': '63cfff0f84e68e45fd1db8a5',
            'nomor': 2,
            'nama': 'البقرة',
            'nama_latin': 'Al-Baqarah',
            'jumlah_ayat': 286,
            'tempat_turun': 'madinah',
            'arti': 'Sapi',
            'deskripsi': 'x',
            'audio': 'u',
          },
    'surat_sebelumnya': false,
  });
  return http.Response.bytes(
    utf8.encode(body),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('QuranSettings', () {
    test('bawaan 100% dengan mode lengkap', () async {
      final settings = QuranSettings();
      await settings.load();

      expect(settings.fontScale, 1.0);
      expect(settings.mode, QuranViewMode.semua);
    });

    test('zoom dibatasi 80% sampai 200%', () async {
      final settings = QuranSettings();
      await settings.load();

      for (var i = 0; i < 20; i++) {
        await settings.zoomIn();
      }
      expect(settings.fontScale, 2.0);
      expect(settings.canZoomIn, isFalse);

      for (var i = 0; i < 30; i++) {
        await settings.zoomOut();
      }
      expect(settings.fontScale, 0.8);
      expect(settings.canZoomOut, isFalse);
    });

    test('ukuran huruf dan mode layar tersimpan di perangkat', () async {
      final settings = QuranSettings();
      await settings.setFontScale(1.3);
      await settings.setMode(QuranViewMode.arabSaja);

      final reloaded = QuranSettings();
      await reloaded.load();
      expect(reloaded.fontScale, 1.3);
      expect(reloaded.mode, QuranViewMode.arabSaja);
    });

    test('nilai tersimpan yang tidak valid diabaikan', () async {
      SharedPreferences.setMockInitialValues({
        'quran_font_scale': 9.0,
        'quran_view_mode': 'tidak-ada',
      });
      final settings = QuranSettings();
      await settings.load();

      expect(settings.fontScale, 2.0);
      expect(settings.mode, QuranViewMode.semua);
    });

    test('mode layar menentukan bagian ayat yang tampil', () {
      expect(QuranViewMode.semua.showLatin, isTrue);
      expect(QuranViewMode.semua.showTranslation, isTrue);
      expect(QuranViewMode.arabTerjemahan.showLatin, isFalse);
      expect(QuranViewMode.arabTerjemahan.showTranslation, isTrue);
      expect(QuranViewMode.arabSaja.showLatin, isFalse);
      expect(QuranViewMode.arabSaja.showTranslation, isFalse);
    });
  });

  group('pemutar audio', () {
    test('formatAudioDuration', () {
      expect(formatAudioDuration(Duration.zero), '00:00');
      expect(formatAudioDuration(const Duration(seconds: 75)), '01:15');
      expect(
        formatAudioDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    test('qariFromAudioUrl mengambil nama qari dari alamat audio', () {
      expect(qariFromAudioUrl(_audioUrl), 'Misyari Rasyid Al-Afasi');
      expect(qariFromAudioUrl('https://contoh.com/001.mp3'), isNull);
    });
  });

  group('ApiService', () {
    test('data yang berhasil diambil disalin ke perangkat', () async {
      final service =
          ApiService(client: MockClient((_) async => _detailResponse()));
      final result = await service.getDetailSurat(1);

      expect(result.isRight(), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('quran_cache_surat_1'), isNotNull);
    });

    test('tanpa internet memakai salinan tersimpan', () async {
      await ApiService(client: MockClient((_) async => _detailResponse()))
          .getDetailSurat(1);

      final offline = ApiService(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      final result = await offline.getDetailSurat(1);

      expect(result.isRight(), isTrue);
      expect(
        result.fold((_) => null, (detail) => detail.ayat?.length),
        2,
      );
    });

    test('tanpa internet dan tanpa salinan: pesan ramah, bukan exception',
        () async {
      final offline = ApiService(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      final result = await offline.getDetailSurat(2);

      expect(result.fold((message) => message, (_) => ''),
          ApiService.failureMessage);
    });

    test('status selain 200 dianggap gagal', () async {
      final service = ApiService(
        client: MockClient((_) async => http.Response('error', 500)),
      );
      final result = await service.getDetailSurat(3);

      expect(result.isLeft(), isTrue);
    });

    test('surat terakhir (surat_selanjutnya false) dapat dibaca', () async {
      final service = ApiService(
        client: MockClient((_) async => _detailResponse(lastSurah: true)),
      );
      final result = await service.getDetailSurat(114);

      expect(result.isRight(), isTrue);
      expect(result.fold((_) => 'x', (detail) => detail.suratSelanjutnya), isNull);
    });
  });

  group('AyatPage', () {
    Future<FakeAudioPlayer> pumpAyatPage(
      WidgetTester tester, {
      required MockClient client,
      QuranSettings? settings,
    }) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final audio = FakeAudioPlayer();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => AyatBloc(ApiService(client: client)),
            child: AyatPage(
              surat: _surat,
              settings: settings ?? QuranSettings(),
              createAudioPlayer: () => audio,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return audio;
    }

    final okClient = MockClient((_) async => _detailResponse());

    testWidgets('menampilkan Arab, Latin, dan terjemahan secara bawaan',
        (tester) async {
      await pumpAyatPage(tester, client: okClient);

      expect(find.text('بِسْمِ'), findsOneWidget);
      expect(find.textContaining('Bismi'), findsOneWidget);
      expect(find.textContaining('Dengan nama Allah'), findsOneWidget);
    });

    testWidgets('mode "Arab saja" menyembunyikan Latin dan terjemahan',
        (tester) async {
      await pumpAyatPage(tester, client: okClient);

      await tester.tap(find.byType(DropdownButton<QuranViewMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arab saja').last);
      await tester.pumpAndSettle();

      expect(find.text('بِسْمِ'), findsOneWidget);
      expect(find.textContaining('Bismi'), findsNothing);
      expect(find.textContaining('Dengan nama Allah'), findsNothing);
    });

    testWidgets('tombol + memperbesar dan - memperkecil tulisan ayat',
        (tester) async {
      await pumpAyatPage(tester, client: okClient);
      double arabSize() =>
          tester.widget<Text>(find.text('بِسْمِ')).style!.fontSize!;

      expect(arabSize(), 26.0);
      expect(find.text('100%'), findsOneWidget);

      await tester.tap(find.byTooltip('Perbesar huruf'));
      await tester.pumpAndSettle();
      expect(find.text('110%'), findsOneWidget);
      expect(arabSize(), closeTo(28.6, 0.001));

      await tester.tap(find.byTooltip('Perkecil huruf'));
      await tester.tap(find.byTooltip('Perkecil huruf'));
      await tester.pumpAndSettle();
      expect(find.text('90%'), findsOneWidget);
      expect(arabSize(), closeTo(23.4, 0.001));
    });

    testWidgets('tombol putar memulai bacaan surah dan dapat dijeda',
        (tester) async {
      final audio = await pumpAyatPage(tester, client: okClient);
      expect(find.byType(QuranAudioBar), findsOneWidget);
      expect(find.textContaining('Misyari Rasyid Al-Afasi'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(audio.playCalls, 1);
      expect(audio.lastUrl, _audioUrl);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(audio.pauseCalls, 1);
    });

    testWidgets('gagal memuat: pesan ramah dan tombol Coba lagi',
        (tester) async {
      var attempts = 0;
      final client = MockClient((_) async {
        attempts++;
        if (attempts == 1) throw http.ClientException('offline');
        return _detailResponse();
      });
      await pumpAyatPage(tester, client: client);

      expect(find.textContaining('Periksa koneksi internet'), findsOneWidget);
      expect(find.byType(QuranAudioBar), findsNothing);

      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('بِسْمِ'), findsOneWidget);
      expect(attempts, 2);
    });

    testWidgets('surat terakhir (An-Nas) tampil tanpa error', (tester) async {
      await pumpAyatPage(
        tester,
        client: MockClient((_) async => _detailResponse(lastSurah: true)),
      );

      expect(find.text('بِسْمِ'), findsOneWidget);
      expect(find.textContaining('Periksa koneksi internet'), findsNothing);
    });
  });
}
