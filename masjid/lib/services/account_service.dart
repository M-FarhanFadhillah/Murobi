import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/murobi_api.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/google_auth.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:masjid/services/report_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hasil operasi akun: berhasil (dengan pesan opsional) atau gagal dengan pesan
// berbahasa Indonesia yang siap ditampilkan.
class AuthResult {
  const AuthResult.ok([this.message]) : error = null;

  const AuthResult.error(String this.error) : message = null;

  final String? message;
  final String? error;

  bool get ok => error == null;
}

// Semua operasi akun (masuk, daftar, profil, kata sandi, keluar). Tanpa alamat
// server memakai akun dummy di perangkat; dengan server memakai API Murobi.
class AccountService {
  AccountService({MurobiApi? api, bool? remote, GoogleAuthClient? google})
      : _api = api ?? MurobiApi.instance,
        _google = google ?? DeviceGoogleAuth(),
        remote = remote ?? ApiConfig.enabled;

  static final AccountService instance = AccountService();

  static const String _tokenKey = 'api_token_v1';

  final MurobiApi _api;
  final GoogleAuthClient _google;

  // True jika memakai server.
  final bool remote;

  Future<AuthResult> signIn(String id, String password) async {
    if (!remote) {
      if (!AuthSession.login(id, password)) {
        return const AuthResult.error('ID atau kata sandi salah.');
      }
      await ProfileStore.instance.loadFor(AuthSession.current!);
      return const AuthResult.ok();
    }

    try {
      final result = await _api.login(id.trim(), password);
      _api.token = result.token;
      await _saveToken(result.token);
      final account = UserAccount.fromApi(result.user);
      AuthSession.startRemote(account);
      await ProfileStore.instance.loadFor(account);
      return const AuthResult.ok();
    } on ApiException catch (error) {
      return AuthResult.error(error.message);
    }
  }

  // Masuk (atau mendaftar sekaligus) dengan akun Google. Dengan server, token
  // Google diperiksa server lalu akun dicocokkan/dibuat lewat email. Tanpa
  // server, profil Google dipakai langsung sebagai akun jamaah di perangkat.
  Future<AuthResult> signInWithGoogle() async {
    final GoogleProfile? profile;
    try {
      profile = await _google.signIn();
    } on GoogleNotConfigured {
      return const AuthResult.error(
        'Login Google belum dikonfigurasi (GOOGLE_CLIENT_ID belum diisi).',
      );
    } catch (error) {
      // Penyebab aslinya (mis. People API belum aktif, origin belum didaftarkan)
      // hanya dicatat pada mode debug; pengguna melihat pesan umum.
      if (kDebugMode) debugPrint('Login Google gagal: $error');
      return const AuthResult.error(
        'Login Google gagal. Periksa koneksi internet lalu coba lagi.',
      );
    }
    if (profile == null) {
      return const AuthResult.error('Login Google dibatalkan.');
    }

    if (!remote) {
      final email = profile.email.trim().toLowerCase();
      final account = UserAccount(
        id: 'google-$email',
        nama: profile.name.isEmpty ? email.split('@').first : profile.name,
        email: email,
        phone: '',
        role: UserRole.jamaah,
        photoUrl: profile.photoUrl,
      );
      AuthSession.startLocal(account);
      await ProfileStore.instance.loadFor(account);
      return const AuthResult.ok();
    }

    try {
      final result = await _api.loginWithGoogle(
        idToken: profile.idToken,
        accessToken: profile.accessToken,
      );
      _api.token = result.token;
      await _saveToken(result.token);
      final account = UserAccount.fromApi(result.user);
      AuthSession.startRemote(account);
      await ProfileStore.instance.loadFor(account);
      return const AuthResult.ok();
    } on ApiException catch (error) {
      return AuthResult.error(error.message);
    }
  }

  Future<AuthResult> signUp({
    required String nama,
    required String phone,
    required String email,
    required String password,
  }) async {
    if (!remote) {
      final error = AuthSession.register(
        nama: nama,
        phone: phone,
        email: email,
        password: password,
      );
      return error == null
          ? const AuthResult.ok(
              'Akun berhasil dibuat. Silakan masuk dengan email Anda.',
            )
          : AuthResult.error(error);
    }

    try {
      final message = await _api.register(
        name: nama.trim(),
        email: email.trim(),
        noHp: phone.trim(),
        password: password,
      );
      return AuthResult.ok(message);
    } on ApiException catch (error) {
      return AuthResult.error(error.message);
    }
  }

  // Memulihkan sesi dari token yang tersimpan. True jika berhasil masuk.
  Future<bool> restore() async {
    if (!remote) return false;
    final token = await _readToken();
    if (token == null) return false;

    _api.token = token;
    try {
      final account = UserAccount.fromApi(await _api.me());
      AuthSession.startRemote(account);
      await ProfileStore.instance.loadFor(account);
      return true;
    } on ApiException catch (error) {
      // Token ditolak (dicabut atau akun tidak lagi aktif): hapus. Gangguan
      // jaringan: token dipertahankan agar bisa dicoba lagi nanti.
      if (error.isUnauthorized || error.statusCode == 403) {
        await _forgetSession();
      } else {
        _api.token = null;
      }
      return false;
    }
  }

  Future<AuthResult> updateProfile({
    required String nama,
    required String email,
    required String phone,
  }) async {
    if (!remote) {
      await ProfileStore.instance.update(nama: nama, email: email, phone: phone);
      return const AuthResult.ok();
    }

    try {
      final user = await _api.updateMe(name: nama, email: email, noHp: phone);
      final account = UserAccount.fromApi(user);
      AuthSession.startRemote(account);
      ProfileStore.instance.applyRemote(account);
      return const AuthResult.ok();
    } on ApiException catch (error) {
      return _failed(error);
    }
  }

  Future<AuthResult> updatePhoto(Uint8List bytes) async {
    if (!remote) {
      await ProfileStore.instance.setPhoto(bytes);
      return const AuthResult.ok();
    }

    try {
      final user = await _api.uploadPhoto(bytes);
      final account = UserAccount.fromApi(user);
      AuthSession.startRemote(account);
      ProfileStore.instance
        ..showUploadedPhoto(bytes)
        ..applyRemote(account);
      return const AuthResult.ok();
    } on ApiException catch (error) {
      return _failed(error);
    }
  }

  Future<AuthResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!remote) {
      final error = AuthSession.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return error == null ? const AuthResult.ok() : AuthResult.error(error);
    }

    try {
      await _api.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const AuthResult.ok();
    } on ApiException catch (error) {
      return _failed(error);
    }
  }

  Future<void> signOut() async {
    if (remote && _api.token != null) {
      try {
        await _api.logout();
      } on ApiException {
        // Tanpa jaringan token tetap dihapus di perangkat ini.
      }
    }
    await _forgetSession();
    await _google.signOut();
  }

  // Kegagalan operasi yang butuh token: sesi yang kedaluwarsa mengakhiri sesi
  // supaya layar bisa mengarahkan ke halaman masuk.
  Future<AuthResult> _failed(ApiException error) async {
    if (error.isUnauthorized) await _forgetSession();
    return AuthResult.error(error.message);
  }

  Future<void> _forgetSession() async {
    _api.token = null;
    AuthSession.logout();
    ProfileStore.instance.clear();
    ReportStore.instance.reset();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {}
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {
      // Tanpa penyimpanan, sesi hanya bertahan selama aplikasi terbuka.
    }
  }

  Future<String?> _readToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token == null || token.isEmpty ? null : token;
    } catch (_) {
      return null;
    }
  }
}
