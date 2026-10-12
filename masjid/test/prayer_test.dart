import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:masjid/services/api_prayer_service.dart';
import 'package:masjid/widget/prayer_times_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _aladhan([int status = 200]) => http.Response(
      jsonEncode({
        'data': {
          'timings': {
            'Fajr': '04:22 (WIB)',
            'Dhuhr': '11:46 (WIB)',
            'Asr': '14:51 (WIB)',
            'Maghrib': '17:52 (WIB)',
            'Isha': '19:01 (WIB)',
          },
        },
      }),
      status,
    );

final DateTime _senin = DateTime(2026, 10, 12, 9);

ApiPrayerService _service(
  Future<http.Response> Function(http.Request) handler, {
  DateTime? now,
  Duration timeout = const Duration(seconds: 5),
}) =>
    ApiPrayerService(
      client: MockClient(handler),
      now: () => now ?? _senin,
      timeout: timeout,
    );

Future<http.Response> _offline(http.Request _) =>
    Future.error(http.ClientException('offline'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ApiPrayerService', () {
    test('memuat jadwal dan mengambil jam saja', () async {
      final times = await _service((_) async => _aladhan()).fetchToday();

      expect(times.subuh, '04:22');
      expect(times.isya, '19:01');
      expect(times.staleSince, isNull);
    });

    test('jadwal yang berhasil dimuat disimpan untuk dipakai tanpa internet',
        () async {
      await _service((_) async => _aladhan()).fetchToday();

      final times = await _service(_offline).fetchToday();

      expect(times.dzuhur, '11:46');
      // Disimpan hari yang sama: tidak ditandai usang.
      expect(times.staleSince, isNull);
    });

    test('jadwal tersimpan dari hari lain ditandai dengan tanggalnya', () async {
      await _service((_) async => _aladhan()).fetchToday();

      final times = await _service(
        _offline,
        now: _senin.add(const Duration(days: 3)),
      ).fetchToday();

      expect(times.ashar, '14:51');
      expect(times.staleSince, DateTime(2026, 10, 12));
    });

    test('jadwal tersimpan lebih dari 7 hari tidak dipakai', () async {
      await _service((_) async => _aladhan()).fetchToday();

      final tujuhHari = _service(
        _offline,
        now: _senin.add(const Duration(days: 7)),
      );
      expect((await tujuhHari.fetchToday()).staleSince, isNotNull);

      final delapanHari = _service(
        _offline,
        now: _senin.add(const Duration(days: 8)),
      );
      await expectLater(delapanHari.fetchToday(), throwsA(anything));
    });

    test('tanggal tersimpan di masa depan (jam perangkat diubah) diabaikan',
        () async {
      await _service(
        (_) async => _aladhan(),
        now: _senin.add(const Duration(days: 5)),
      ).fetchToday();

      await expectLater(_service(_offline).fetchToday(), throwsA(anything));
    });

    test('tanpa internet dan tanpa jadwal tersimpan: tetap error', () async {
      await expectLater(_service(_offline).fetchToday(), throwsA(anything));
    });

    test('status bukan 200 atau isi rusak memakai jadwal tersimpan', () async {
      await _service((_) async => _aladhan()).fetchToday();

      expect((await _service((_) async => _aladhan(503)).fetchToday()).subuh,
          '04:22');
      expect(
        (await _service((_) async => http.Response('bukan json', 200))
                .fetchToday())
            .subuh,
        '04:22',
      );
      expect(
        (await _service((_) async => http.Response('{"data":{}}', 200))
                .fetchToday())
            .subuh,
        '04:22',
      );
    });

    test('koneksi yang menggantung dibatasi waktu lalu memakai cadangan',
        () async {
      await _service((_) async => _aladhan()).fetchToday();

      final hang = Completer<http.Response>();
      final times = await _service(
        (_) => hang.future,
        timeout: const Duration(milliseconds: 50),
      ).fetchToday();

      expect(times.subuh, '04:22');
    });

    test('data tersimpan yang rusak diabaikan, bukan menjatuhkan aplikasi',
        () async {
      SharedPreferences.setMockInitialValues({'prayer_times_v1': '{rusak'});

      await expectLater(_service(_offline).fetchToday(), throwsA(anything));
    });

    test('jadwal baru menimpa jadwal tersimpan', () async {
      await _service((_) async => _aladhan()).fetchToday();
      final besok = _senin.add(const Duration(days: 1));
      await _service(
        (_) async => http.Response(
          jsonEncode({
            'data': {
              'timings': {
                'Fajr': '04:21',
                'Dhuhr': '11:46',
                'Asr': '14:50',
                'Maghrib': '17:52',
                'Isha': '19:01',
              },
            },
          }),
          200,
        ),
        now: besok,
      ).fetchToday();

      final times = await _service(_offline, now: besok).fetchToday();

      expect(times.subuh, '04:21');
      expect(times.staleSince, isNull);
    });
  });

  group('PrayerTimesRow', () {
    Future<void> pump(WidgetTester tester, ApiPrayerService service) async {
      await tester.binding.setSurfaceSize(const Size(390, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PrayerTimesRow(service: service))),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('online: lima waktu tampil tanpa catatan', (tester) async {
      await pump(tester, _service((_) async => _aladhan()));

      expect(find.text('04:22'), findsOneWidget);
      expect(find.text("Isya'"), findsOneWidget);
      expect(find.textContaining('Jadwal tersimpan'), findsNothing);
    });

    testWidgets('offline dengan jadwal tersimpan lama: tampil dengan catatan',
        (tester) async {
      await _service((_) async => _aladhan()).fetchToday();

      await pump(
        tester,
        _service(_offline, now: _senin.add(const Duration(days: 2))),
      );

      expect(find.text('04:22'), findsOneWidget);
      expect(find.textContaining('Jadwal tersimpan (12/10)'), findsOneWidget);
      expect(find.text('Jadwal sholat belum tersedia'), findsNothing);
    });

    testWidgets('offline tanpa cadangan: pesan dan tombol muat ulang',
        (tester) async {
      var online = false;
      await pump(
        tester,
        _service((_) async {
          if (!online) throw http.ClientException('offline');
          return _aladhan();
        }),
      );

      expect(find.text('Jadwal sholat belum tersedia'), findsOneWidget);

      online = true;
      await tester.tap(find.byTooltip('Muat ulang'));
      await tester.pumpAndSettle();

      expect(find.text('04:22'), findsOneWidget);
      expect(find.text('Jadwal sholat belum tersedia'), findsNothing);
    });
  });
}
