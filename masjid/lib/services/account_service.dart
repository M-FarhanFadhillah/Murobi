import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/api_models.dart';
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

  // Data akun server terakhir; dipakai bila aplikasi dibuka tanpa internet.
  static const String _userKey = 'api_user_v1';

  // Sesi mode lokal (tanpa kata sandi), agar tidak perlu masuk ulang.
  static const String _localSessionKey = 'local_session_v1';

  // Akun hasil "Daftar" pada mode lokal (kata sandi berupa hash). Sengaja tidak
  // ikut dihapus saat keluar: akunnya tetap ada untuk dipakai masuk lagi.
  static const String _localAccountsKey = 'local_accounts_v1';

  final MurobiApi _api;
  final GoogleAuthClient _google;

  // True jika memakai server.
  final bool remote;

  Future<AuthResult> signIn(String id, String password) async {
    if (!remote) {
      await _loadLocalAccounts();
      if (!AuthSession.login(id, password)) {
        return const AuthResult.error('ID atau kata sandi salah.');
      }
      await _saveLocalSession(AuthSession.current!);
      await ProfileStore.instance.loadFor(AuthSession.current!);
      return const AuthResult.ok();
    }

    try {
      final result = await _api.login(id.trim(), password);
      _api.token = result.token;
      await _saveToken(result.token);
      await _saveUser(result.user);
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
      await _saveLocalSession(account);
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
      await _saveUser(result.user);
      final account = UserAccount.fromApi(result.user);
      AuthSession.startRemote(account);
      await ProfileStore.instance.loadFor(account);
      return const AuthResult.ok();
    } on ApiException catch (error) {
      return AuthResult.error(error.message);
    }
  }

  // Pendaftaran jamaah tanpa email: nama, nomor telepon, dan kata sandi.
  Future<AuthResult> signUp({
    required String nama,
    required String phone,
    required String password,
  }) async {
    if (!remote) {
      await _loadLocalAccounts();
      final error = AuthSession.register(
        nama: nama,
        phone: phone,
        password: password,
      );
      if (error != null) return AuthResult.error(error);
      await _saveLocalAccounts();
      return const AuthResult.ok(
        'Akun berhasil dibuat. Silakan masuk dengan nomor telepon Anda.',
      );
    }

    try {
      final message = await _api.register(
        name: nama.trim(),
        noHp: phone.trim(),
        password: password,
      );
      return AuthResult.ok(message);
    } on ApiException catch (error) {
      return AuthResult.error(error.message);
    }
  }

  // Memulihkan sesi yang tersimpan saat aplikasi dibuka, supaya pengguna yang
  // sudah masuk tidak perlu masuk ulang. True jika berhasil masuk.
  Future<bool> restore() async {
    if (!remote) return _restoreLocal();
    final token = await _readToken();
    if (token == null) return false;

    _api.token = token;
    try {
      final user = await _api.me();
      await _saveUser(user);
      final account = UserAccount.fromApi(user);
      AuthSession.startRemote(account);
      await ProfileStore.instance.loadFor(account);
      return true;
    } on ApiException catch (error) {
      // Token ditolak (dicabut atau akun tidak lagi aktif): sesi dihapus.
      if (error.isUnauthorized || error.statusCode == 403) {
        await _forgetSession();
        return false;
      }
      // Gangguan jaringan atau server: token dipertahankan. Bila data akun
      // terakhir tersimpan, pengguna tetap masuk (konten dimuat dari cache dan
      // diperbarui saat server terjangkau lagi).
      final cached = await _readUser();
      if (cached == null) {
        _api.token = null;
        return false;
      }
      final account = UserAccount.fromApi(cached);
      AuthSession.startRemote(account);
      await ProfileStore.instance.loadFor(account);
      return true;
    }
  }

  // Mode lokal: akun dummy bawaan dipulihkan apa adanya (termasuk peran
  // admin); akun lain (hasil daftar atau Google) selalu sebagai jamaah.
  Future<bool> _restoreLocal() async {
    await _loadLocalAccounts();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localSessionKey);
      if (raw == null) return false;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final id = json['id'] as String;
      final account = AuthSession.localAccount(id) ??
          UserAccount(
            id: id,
            nama: json['nama'] as String? ?? '',
            email: json['email'] as String? ?? '',
            phone: json['phone'] as String? ?? '',
            role: UserRole.jamaah,
            photoUrl: json['photoUrl'] as String?,
          );
      AuthSession.startLocal(account);
      await ProfileStore.instance.loadFor(account);
      return true;
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: masuk seperti biasa.
      await _forgetSession();
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
      await _saveUser(user);
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
      await _saveUser(user);
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
      if (error != null) return AuthResult.error(error);
      // Akun hasil daftar: hash kata sandi baru disimpan di perangkat.
      await _saveLocalAccounts();
      return const AuthResult.ok();
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
      await prefs.remove(_userKey);
      await prefs.remove(_localSessionKey);
    } catch (_) {}
  }

  Future<void> _loadLocalAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localAccountsKey);
      if (raw == null) return;
      AuthSession.loadRegistered(jsonDecode(raw) as List<dynamic>);
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: hanya akun bawaan.
    }
  }

  Future<void> _saveLocalAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localAccountsKey,
        jsonEncode(AuthSession.registeredToJson()),
      );
    } catch (_) {
      // Tanpa penyimpanan, akun hasil daftar hanya hidup selama aplikasi terbuka.
    }
  }

  // Tanpa kata sandi: hanya identitas akun yang perlu ditampilkan.
  Future<void> _saveLocalSession(UserAccount account) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localSessionKey,
        jsonEncode({
          'id': account.id,
          'nama': account.nama,
          'email': account.email,
          'phone': account.phone,
          'photoUrl': account.photoUrl,
        }),
      );
    } catch (_) {
      // Tanpa penyimpanan, sesi hanya bertahan selama aplikasi terbuka.
    }
  }

  Future<void> _saveUser(ApiUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<ApiUser?> _readUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      if (raw == null) return null;
      return ApiUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
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
