import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimes {
  const PrayerTimes({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    this.staleSince,
  });

  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  // Tanggal jadwal ini diambil bila berasal dari salinan tersimpan hari
  // sebelumnya (tanpa internet). Null untuk jadwal hari ini.
  final DateTime? staleSince;
}

// Jadwal sholat dari Aladhan API. Method 20 = Kemenag RI, kota Bandar Lampung.
// Jadwal yang berhasil dimuat disimpan di perangkat; tanpa internet jadwal
// tersimpan (maksimal [maxCacheDays] hari) dipakai agar Beranda tetap terisi.
class ApiPrayerService {
  ApiPrayerService({
    http.Client? client,
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 10),
  })  : _client = client ?? http.Client(),
        _now = now ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _now;
  final Duration timeout;

  static const String _cacheKey = 'prayer_times_v1';

  // Waktu sholat bergeser hanya sekitar satu menit per minggu; lebih lama dari
  // ini jadwal tersimpan dianggap tidak layak ditampilkan.
  static const int maxCacheDays = 7;

  static final Uri _url = Uri.parse(
    'https://api.aladhan.com/v1/timingsByCity'
    '?city=Bandar%20Lampung&country=Indonesia&method=20',
  );

  Future<PrayerTimes> fetchToday() async {
    try {
      final times = await _fetch();
      await _save(times);
      return times;
    } catch (_) {
      final cached = await _readCache();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<PrayerTimes> _fetch() async {
    final response = await _client.get(_url).timeout(timeout);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat jadwal sholat (${response.statusCode})');
    }

    final timings =
        (jsonDecode(response.body)['data']['timings']) as Map<String, dynamic>;

    // Nilai dari API bisa berbentuk "04:35 (WIB)", jadi ambil jam saja.
    String clock(String key) => (timings[key] as String).split(' ').first;

    return PrayerTimes(
      subuh: clock('Fajr'),
      dzuhur: clock('Dhuhr'),
      ashar: clock('Asr'),
      maghrib: clock('Maghrib'),
      isya: clock('Isha'),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _save(PrayerTimes t) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'date': _dateKey(_now()),
          'subuh': t.subuh,
          'dzuhur': t.dzuhur,
          'ashar': t.ashar,
          'maghrib': t.maghrib,
          'isya': t.isya,
        }),
      );
    } catch (_) {
      // Penyimpanan tidak tersedia: cadangan hanya pelengkap.
    }
  }

  Future<PrayerTimes?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;

      final saved = DateTime.parse(json['date'] as String);
      final now = _now();
      final today = DateTime(now.year, now.month, now.day);
      final age = today.difference(DateTime(saved.year, saved.month, saved.day));
      // Tanggal di masa depan (jam perangkat diubah) atau terlalu lama: abaikan.
      if (age.isNegative || age.inDays > maxCacheDays) return null;

      return PrayerTimes(
        subuh: json['subuh'] as String,
        dzuhur: json['dzuhur'] as String,
        ashar: json['ashar'] as String,
        maghrib: json['maghrib'] as String,
        isya: json['isya'] as String,
        staleSince: age.inDays == 0 ? null : saved,
      );
    } catch (_) {
      return null;
    }
  }
}
