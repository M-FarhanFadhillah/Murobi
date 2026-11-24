import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_models.dart';

// Akun yang sedang dipakai, atau null bila pengguna belum masuk (tamu: semua
// fitur umum tetap bisa dipakai). Tanpa alamat server (ApiConfig.enabled ==
// false) aplikasi memakai akun dummy di bawah ini dan akun hasil daftar yang
// disimpan di perangkat; dengan server, akun berasal dari API (lihat
// AccountService).
enum UserRole { jamaah, admin }

class UserAccount {
  const UserAccount({
    required this.id,
    required this.nama,
    required this.email,
    required this.phone,
    required this.role,
    this.password = '',
    this.photoUrl,
    this.isRemote = false,
  });

  // Akun dari server. ID diberi awalan agar tidak bentrok dengan akun dummy.
  factory UserAccount.fromApi(ApiUser user) => UserAccount(
        id: 'api-${user.id}',
        nama: user.name,
        email: user.email,
        phone: user.noHp,
        role: user.isAdmin ? UserRole.admin : UserRole.jamaah,
        photoUrl: user.photoUrl,
        isRemote: true,
      );

  final String id;

  // Hanya terisi untuk akun dummy; akun server tidak menyimpan kata sandi.
  final String password;
  final String nama;
  final String email;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final bool isRemote;

  String get roleLabel => role == UserRole.admin ? 'Admin Masjid' : 'Jamaah';
}

// Kata sandi akun hasil daftar (mode lokal) yang disimpan di perangkat: hanya
// garam acak dan hash SHA-256 berulang, tidak pernah teks aslinya.
class LocalCredential {
  const LocalCredential(this.salt, this.hash);

  factory LocalCredential.create(String password) {
    final random = Random.secure();
    final salt = base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
    return LocalCredential(salt, _digest(salt, password));
  }

  static const int _rounds = 10000;

  final String salt;
  final String hash;

  bool matches(String password) => _digest(salt, password) == hash;

  static String _digest(String salt, String password) {
    var bytes = sha256.convert(utf8.encode('$salt:$password')).bytes;
    for (var i = 1; i < _rounds; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Url.encode(bytes);
  }
}

class AuthSession {
  AuthSession._();

  static const List<UserAccount> _accounts = [
    UserAccount(
      id: 'jamaah',
      password: 'jamaah123',
      nama: 'Jamaah As-Syifa',
      email: 'jamaah@murobi.id',
      phone: '0812345678',
      role: UserRole.jamaah,
    ),
    UserAccount(
      id: 'admin',
      password: 'admin123',
      nama: 'Admin Masjid As-Syifa',
      email: 'admin@murobi.id',
      phone: '0812987654',
      role: UserRole.admin,
    ),
  ];

  // Akun jamaah hasil "Daftar" (mode lokal). Disimpan di perangkat oleh
  // AccountService lewat [registeredToJson] / [loadRegistered].
  static final List<UserAccount> _registered = [];

  // Kata sandi akun hasil daftar, dalam bentuk hash (lihat LocalCredential).
  static final Map<String, LocalCredential> _credentials = {};

  // Kata sandi pengganti akun dummy bawaan hasil "Ubah Kata Sandi". Sengaja
  // hanya di memori: kata sandi akun bawaan tidak disimpan di perangkat.
  static final Map<String, String> _passwordOverrides = {};

  static bool _passwordMatches(UserAccount account, String password) {
    final override = _passwordOverrides[account.id];
    if (override != null) return override == password;
    final credential = _credentials[account.id];
    if (credential != null) return credential.matches(password);
    return account.password.isNotEmpty && account.password == password;
  }

  static UserAccount? _current;

  static UserAccount? get current => _current;

  // Berubah setiap kali pengguna masuk, keluar, atau data akunnya diperbarui.
  // Halaman yang tampilannya bergantung pada akun (Profil, menu admin)
  // mendengarkannya. null = tamu (belum masuk).
  static final ValueNotifier<UserAccount?> changes = ValueNotifier(null);

  static void _setCurrent(UserAccount? account) {
    _current = account;
    changes.value = account;
  }

  static bool get isAdmin => _current?.role == UserRole.admin;

  // Admin mengelola kegiatan dan materi dari aplikasi, baik pada mode lokal
  // (data di perangkat) maupun mode server (lewat API; server menolak non-admin).
  static bool get canManageContent => isAdmin;

  // Menandai akun dari server sebagai akun aktif (login, pemulihan sesi, atau
  // setelah data diri diubah).
  static void startRemote(UserAccount account) => _setCurrent(account);

  // Akun lokal (tanpa server): login Google atau sesi yang dipulihkan.
  static void startLocal(UserAccount account) => _setCurrent(account);

  // Akun dummy bawaan dengan ID [id], atau null. Dipakai saat memulihkan sesi
  // lokal supaya peran (admin/jamaah) berasal dari kode, bukan dari data yang
  // tersimpan di perangkat.
  static UserAccount? builtInAccount(String id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  // Akun lokal (bawaan atau hasil daftar) dengan ID [id], atau null.
  static UserAccount? localAccount(String id) {
    final builtIn = builtInAccount(id);
    if (builtIn != null) return builtIn;
    for (final account in _registered) {
      if (account.id == id) return account;
    }
    return null;
  }

  // Mencocokkan ID (atau email / nomor HP) dan kata sandi dengan akun lokal.
  static bool login(String id, String password) {
    final normalizedId = id.trim().toLowerCase();
    for (final account in [..._accounts, ..._registered]) {
      final idMatches = account.id == normalizedId ||
          (account.email.isNotEmpty &&
              account.email.toLowerCase() == normalizedId) ||
          account.phone == normalizedId;
      if (idMatches && _passwordMatches(account, password)) {
        _setCurrent(account);
        return true;
      }
    }
    return false;
  }

  // Mendaftarkan akun jamaah baru (tanpa email). Mengembalikan pesan error,
  // atau null jika berhasil. Nomor telepon dipakai sebagai ID untuk masuk.
  static String? register({
    required String nama,
    required String phone,
    required String password,
  }) {
    final normalizedPhone = phone.trim();
    for (final account in [..._accounts, ..._registered]) {
      if (account.phone == normalizedPhone || account.id == normalizedPhone) {
        return 'Nomor telepon sudah terdaftar.';
      }
    }
    _registered.add(
      UserAccount(
        id: normalizedPhone,
        nama: nama.trim(),
        email: '',
        phone: normalizedPhone,
        role: UserRole.jamaah,
      ),
    );
    _credentials[normalizedPhone] = LocalCredential.create(password);
    return null;
  }

  // Mengubah kata sandi akun yang sedang masuk. Mengembalikan pesan error,
  // atau null jika berhasil.
  static String? changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    final account = _current;
    if (account == null) return 'Anda belum masuk.';
    if (!_passwordMatches(account, oldPassword)) return 'Kata sandi lama salah.';
    if (newPassword == oldPassword) {
      return 'Kata sandi baru harus berbeda dari yang lama.';
    }
    if (_credentials.containsKey(account.id)) {
      // Akun hasil daftar: hash baru ikut disimpan di perangkat.
      _credentials[account.id] = LocalCredential.create(newPassword);
    } else {
      _passwordOverrides[account.id] = newPassword;
    }
    return null;
  }

  // Akun hasil daftar beserta hash kata sandinya, untuk disimpan di perangkat.
  static List<Map<String, dynamic>> registeredToJson() => [
        for (final account in _registered)
          if (_credentials[account.id] != null)
            {
              'id': account.id,
              'nama': account.nama,
              'email': account.email,
              'phone': account.phone,
              'salt': _credentials[account.id]!.salt,
              'hash': _credentials[account.id]!.hash,
            },
      ];

  // Memuat akun hasil daftar yang tersimpan. Data rusak dilewati; akun yang
  // sudah ada di memori tidak digandakan. Selalu sebagai jamaah. Akun lama
  // (sebelum email dihapus dari pendaftaran) memakai email sebagai ID dan tetap
  // bisa masuk dengan email atau nomor telepon.
  static void loadRegistered(List<dynamic> json) {
    for (final item in json) {
      if (item is! Map) continue;
      final id = item['id'];
      final salt = item['salt'];
      final hash = item['hash'];
      if (id is! String || salt is! String || hash is! String) continue;
      if (localAccount(id) != null) continue;
      _registered.add(
        UserAccount(
          id: id,
          nama: '${item['nama'] ?? ''}',
          email: '${item['email'] ?? id}',
          phone: '${item['phone'] ?? ''}',
          role: UserRole.jamaah,
        ),
      );
      _credentials[id] = LocalCredential(salt, hash);
    }
  }

  static void logout() => _setCurrent(null);

  // Mengembalikan keadaan awal (dipakai pengujian).
  @visibleForTesting
  static void resetForTest() {
    _setCurrent(null);
    _registered.clear();
    _credentials.clear();
    _passwordOverrides.clear();
  }
}
