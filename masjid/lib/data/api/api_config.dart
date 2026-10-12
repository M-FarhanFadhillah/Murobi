import 'package:flutter/foundation.dart';

// Konfigurasi sambungan ke server Laravel (Master-Admin). Lihat docs/API.md.
//
// Tanpa pengaturan apa pun aplikasi berjalan dalam MODE LOKAL (login dummy dan
// data tersimpan di perangkat). Untuk memakai server, jalankan dengan alamat
// dasarnya, mis.:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   (emulator Android)
//   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000 (HP asli, satu Wi-Fi)
class ApiConfig {
  ApiConfig._();

  static const String _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  static String? _override;

  // Alamat dasar tanpa garis miring di belakang, atau string kosong.
  static String get baseUrl {
    final raw = (_override ?? _fromEnvironment).trim();
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  // True jika aplikasi memakai server (mode API).
  static bool get enabled => baseUrl.isNotEmpty;

  // Dipakai pengujian untuk mengganti alamat dasar.
  @visibleForTesting
  static void overrideBaseUrl(String? url) => _override = url;
}
