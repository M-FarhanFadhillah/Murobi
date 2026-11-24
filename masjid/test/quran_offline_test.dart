import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:masjid/data/api_service.dart';
import 'package:masjid/ui/quran_tab.dart';
import 'package:masjid/widget/banner_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Al-Qur'an bisa dibaca kapan saja tanpa internet: teks 114 surah disertakan
// di aplikasi (assets/quran/). Murotal tetap memerlukan internet.

// Klien HTTP yang selalu gagal (perangkat offline) dan mencatat permintaan.
MockClient _offline(List<Uri> requests) => MockClient((request) async {
      requests.add(request.url);
      throw http.ClientException('offline');
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Data Al-Qur\'an bawaan (offline)', () {
    test('daftar 114 surah tersedia tanpa internet dan tanpa permintaan jaringan',
        () async {
      final requests = <Uri>[];
      final result = await ApiService(client: _offline(requests)).getAllSurat();

      final list = result.getOrElse(() => fail('daftar surah gagal dimuat'));
      expect(list.length, 114);
      expect(list.first.namaLatin, 'Al-Fatihah');
      expect(list.last.namaLatin, 'An-Nas');
      expect(requests, isEmpty);
    });

    test('isi semua surah lengkap: 6236 ayat Arab, latin, dan terjemahan', () async {
      final requests = <Uri>[];
      final service = ApiService(client: _offline(requests));
      var totalAyat = 0;

      for (var nomor = 1; nomor <= 114; nomor++) {
        final result = await service.getDetailSurat(nomor);
        final surat = result.getOrElse(() => fail('surah $nomor gagal dimuat'));
        final ayat = surat.ayat!;
        expect(surat.nomor, nomor);
        expect(ayat.length, surat.jumlahAyat, reason: 'surah $nomor');
        for (final a in ayat) {
          expect(a.ar, isNotEmpty);
          expect(a.idn, isNotEmpty);
        }
        totalAyat += ayat.length;
      }

      expect(totalAyat, 6236);
      expect(requests, isEmpty);
    });

    test('Al-Fatihah ayat pertama dan alamat murotal (untuk saat online)', () async {
      final result = await ApiService(client: _offline([])).getDetailSurat(1);
      final surat = result.getOrElse(() => fail('Al-Fatihah gagal dimuat'));

      expect(surat.ayat!.first.tr, startsWith('Bismill'));
      expect(surat.ayat!.first.idn, startsWith('Dengan nama Allah'));
      expect(surat.audio, startsWith('https://'));
      expect(surat.suratSelanjutnya?.namaLatin, 'Al-Baqarah');
    });

    test('surah terakhir (An-Nas) tanpa surah selanjutnya tetap terbaca', () async {
      final result = await ApiService(client: _offline([])).getDetailSurat(114);

      final surat = result.getOrElse(() => fail('An-Nas gagal dimuat'));
      expect(surat.jumlahAyat, 6);
      expect(surat.suratSelanjutnya, isNull);
    });
  });

  group('Tab Al-Qur\'an tanpa internet', () {
    testWidgets('daftar surah tampil dan surah bisa dibuka', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // QuranTab memakai http.Client sungguhan; di lingkungan tes semua
      // permintaan jaringan gagal, sama seperti perangkat yang offline.
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QuranTab())));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();

      expect(find.text('Al-Fatihah'), findsOneWidget);
      expect(find.textContaining('Periksa koneksi'), findsNothing);

      await tester.tap(find.text('Al-Fatihah'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bismill'), findsWidgets);
      expect(find.textContaining('Dengan nama Allah'), findsWidgets);
    });
  });

  group('BannerCarousel', () {
    const images = ['assets/images/infaq.png', 'assets/images/donor.png'];

    Future<double> bannerAspect(WidgetTester tester, double width) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: BannerCarousel(images: images))),
      ));
      await tester.pump();
      final size = tester.getSize(
        find.descendant(of: find.byType(PageView), matching: find.byType(Container)).first,
      );
      return size.width / size.height;
    }

    testWidgets('proporsi banner sama dengan gambar di layar sempit (HP)', (tester) async {
      expect(await bannerAspect(tester, 360), closeTo(1.92, 0.02));
    });

    testWidgets('proporsi banner tetap benar di layar lebar (tidak pipih)', (tester) async {
      expect(await bannerAspect(tester, 900), closeTo(1.92, 0.02));
    });
  });
}
