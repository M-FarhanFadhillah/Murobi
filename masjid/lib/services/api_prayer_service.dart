import 'dart:convert';

import 'package:http/http.dart' as http;

class PrayerTimes {
  const PrayerTimes({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
}

// Jadwal sholat dari Aladhan API. Method 20 = Kemenag RI, kota Bandar Lampung.
class ApiPrayerService {
  ApiPrayerService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _url = Uri.parse(
    'https://api.aladhan.com/v1/timingsByCity'
    '?city=Bandar%20Lampung&country=Indonesia&method=20',
  );

  Future<PrayerTimes> fetchToday() async {
    final response = await _client.get(_url);
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
}
