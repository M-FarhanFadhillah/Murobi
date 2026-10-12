import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:masjid/data/models/surat_detail_model.dart';
import 'package:masjid/data/models/surat_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Mengambil data Al-Qur'an dari equran.id. Setiap data yang berhasil diambil
// disalin ke perangkat, sehingga surah yang pernah dibuka tetap bisa dibaca
// saat tidak ada internet.
class ApiService {
  final http.Client client;
  ApiService({
    required this.client,
  });

  static const String _baseUrl = 'https://equran.id/api/surat';
  static const String _cachePrefix = 'quran_cache_';

  static const String failureMessage =
      'Data belum dapat dimuat. Periksa koneksi internet Anda.';

  Future<Either<String, List<SuratModel>>> getAllSurat() {
    return _load(
      url: _baseUrl,
      cacheKey: '${_cachePrefix}surat',
      parse: (body) => List<SuratModel>.from(
        jsonDecode(body).map(
          (x) => SuratModel.fromJson(x),
        ),
      ).toList(),
    );
  }

  Future<Either<String, SuratDetailModel>> getDetailSurat(int nomorSurat) {
    return _load(
      url: '$_baseUrl/$nomorSurat',
      cacheKey: '${_cachePrefix}surat_$nomorSurat',
      parse: (body) => SuratDetailModel.fromJson(jsonDecode(body)),
    );
  }

  Future<Either<String, T>> _load<T>({
    required String url,
    required String cacheKey,
    required T Function(String body) parse,
  }) async {
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = parse(response.body);
        await _saveCache(cacheKey, response.body);
        return Right(result);
      }
    } catch (_) {
      // Server tidak terjangkau atau data tidak valid: coba salinan tersimpan.
    }

    final cached = await _readCache(cacheKey);
    if (cached != null) {
      try {
        return Right(parse(cached));
      } catch (_) {
        // Salinan rusak: dianggap tidak ada.
      }
    }
    return Left<String, T>(failureMessage);
  }

  Future<void> _saveCache(String key, String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, body);
    } catch (_) {
      // Penyimpanan penuh atau tidak tersedia: abaikan, data tetap tampil.
    }
  }

  Future<String?> _readCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }
}
