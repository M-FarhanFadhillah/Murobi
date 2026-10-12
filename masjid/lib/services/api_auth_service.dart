import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:masjid/utils/api.dart';

// Komunikasi dengan API lokal untuk login nomor telepon (OTP). Endpoint di
// bawah ini belum tersedia di backend (lihat docs/API.md). Login Google ada di
// AccountService.signInWithGoogle.
class ApiAuthService {
  ApiAuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  // Meminta backend mengirim kode OTP ke nomor telepon.
  Future<bool> sendOtp(String phone) async {
    final response = await _client.post(
      _uri('api/auth/otp/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return response.statusCode == 200;
  }

  // Memverifikasi kode OTP yang dimasukkan jamaah.
  Future<bool> verifyOtp(String phone, String code) async {
    final response = await _client.post(
      _uri('api/auth/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    return response.statusCode == 200;
  }
}
