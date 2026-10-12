import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:masjid/data/api/api_config.dart';

// Kegagalan saat memanggil API. [message] sudah berbahasa Indonesia dan siap
// ditampilkan ke pengguna.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.errors = const {},
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;

  // Pesan per kolom untuk kode 422.
  final Map<String, List<String>> errors;

  // True jika server tidak terjangkau (tanpa internet, mati, atau terlalu lama).
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

// Satu berkas untuk unggahan multipart.
class MultipartPart {
  const MultipartPart({
    required this.field,
    required this.bytes,
    required this.filename,
  });

  final String field;
  final Uint8List bytes;
  final String filename;
}

// Klien HTTP untuk API Laravel: header JSON, token Bearer, batas waktu, dan
// pengubahan semua kegagalan menjadi [ApiException].
class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.tokenProvider,
    this.timeout = const Duration(seconds: 15),
    this.retryDelay = const Duration(milliseconds: 300),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  final http.Client _client;
  final String? _baseUrl;

  // Mengambil token Bearer saat setiap permintaan dikirim (null = tanpa token).
  final String? Function()? tokenProvider;
  final Duration timeout;

  // Jeda sebelum mengulang permintaan GET yang putus di tengah jalan.
  final Duration retryDelay;

  static const String networkMessage =
      'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

  String get baseUrl => _baseUrl ?? '${ApiConfig.baseUrl}/api';

  Uri uri(String path, [Map<String, String>? query]) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$cleanPath').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }

  Map<String, String> _headers({bool json = false}) {
    final token = tokenProvider?.call();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    final url = uri(path, query);
    // GET aman diulang: koneksi lama yang sudah ditutup server (umum pada
    // jaringan seluler) sering gagal sekali lalu berhasil pada percobaan kedua.
    return _send(url, () => _client.get(url, headers: _headers()), retries: 1);
  }

  Future<dynamic> post(String path, {Object? body}) {
    final url = uri(path);
    return _send(url, () => _client.post(
          url,
          headers: _headers(json: true),
          body: jsonEncode(body ?? {}),
        ));
  }

  Future<dynamic> patch(String path, {Object? body}) {
    final url = uri(path);
    return _send(url, () => _client.patch(
          url,
          headers: _headers(json: true),
          body: jsonEncode(body ?? {}),
        ));
  }

  Future<dynamic> delete(String path) {
    final url = uri(path);
    return _send(url, () => _client.delete(url, headers: _headers()));
  }

  // Mengunggah satu berkas (multipart/form-data), mis. foto profil.
  Future<dynamic> postFile(
    String path, {
    required String field,
    required Uint8List bytes,
    required String filename,
  }) {
    return postMultipart(
      path,
      file: MultipartPart(field: field, bytes: bytes, filename: filename),
    );
  }

  // POST multipart/form-data: field teks dan (opsional) satu berkas.
  Future<dynamic> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    MultipartPart? file,
  }) {
    final url = uri(path);
    return _send(url, () async {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(_headers())
        ..fields.addAll(fields);
      if (file != null) {
        request.files.add(http.MultipartFile.fromBytes(
          file.field,
          file.bytes,
          filename: file.filename,
        ));
      }
      return http.Response.fromStream(await _client.send(request));
    });
  }

  Future<dynamic> _send(
    Uri url,
    Future<http.Response> Function() request, {
    int retries = 0,
  }) async {
    http.Response? received;
    for (var attempt = 0; received == null; attempt++) {
      try {
        received = await request().timeout(timeout);
      } catch (error) {
        // Termasuk SocketException, ClientException, dan TimeoutException.
        // Penyebab aslinya dicatat (hanya mode debug) untuk memudahkan mencari
        // masalah alamat server, CORS, atau jaringan.
        if (kDebugMode) debugPrint('API gagal: $url -> $error');
        // Waktu habis tidak diulang agar pengguna tidak menunggu dua kali lipat.
        final retry = attempt < retries && error is! TimeoutException;
        if (!retry) {
          throw const ApiException(networkMessage, isNetworkError: true);
        }
        if (retryDelay > Duration.zero) await Future<void>.delayed(retryDelay);
      }
    }
    final response = received;

    dynamic decoded;
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (body.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(
      _messageFrom(decoded, response.statusCode),
      statusCode: response.statusCode,
      errors: _errorsFrom(decoded),
    );
  }

  static Map<String, List<String>> _errorsFrom(dynamic json) {
    if (json is! Map || json['errors'] is! Map) return const {};
    return {
      for (final entry in (json['errors'] as Map).entries)
        entry.key.toString(): [
          if (entry.value is List)
            for (final message in entry.value as List) message.toString(),
        ],
    };
  }

  // Pesan untuk pengguna: kesalahan kolom pertama, lalu "message" dari server.
  static String _messageFrom(dynamic json, int status) {
    // Pesan pembatasan dari Laravel berbahasa Inggris ("Too Many Attempts."),
    // jadi selalu diganti pesan bawaan berbahasa Indonesia.
    if (json is Map && status != 429) {
      final errors = _errorsFrom(json);
      for (final messages in errors.values) {
        if (messages.isNotEmpty) return messages.first;
      }
      final message = json['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    switch (status) {
      case 401:
        return 'Sesi berakhir. Silakan masuk lagi.';
      case 403:
        return 'Anda tidak diizinkan melakukan ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 429:
        return 'Terlalu banyak percobaan. Coba lagi sebentar lagi.';
      default:
        return 'Terjadi kesalahan pada server (kode $status).';
    }
  }
}
