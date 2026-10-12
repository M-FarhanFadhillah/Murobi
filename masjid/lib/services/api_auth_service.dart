import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:masjid/utils/api.dart';

// Komunikasi dengan API lokal untuk login nomor telepon (OTP) dan Google.
// Endpoint di bawah ini harus tersedia di backend (lihat dokumentasi skripsi).
class ApiAuthService {
  ApiAuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

  // Login dengan akun Google. Mengembalikan false jika dibatalkan atau gagal.
  Future<bool> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return false;

    final auth = await account.authentication;
    final response = await _client.post(
      _uri('api/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': auth.idToken}),
    );
    return response.statusCode == 200;
  }
}
