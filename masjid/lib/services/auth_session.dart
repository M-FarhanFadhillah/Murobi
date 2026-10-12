import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_models.dart';

// Akun yang sedang dipakai. Tanpa alamat server (ApiConfig.enabled == false)
// aplikasi memakai akun dummy di bawah ini; dengan server, akun berasal dari
// API (lihat AccountService) dan data akunnya tidak disimpan di perangkat.
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

  // Akun hasil pendaftaran. Hanya disimpan di memori selama aplikasi berjalan.
  static final List<UserAccount> _registered = [];

  // Kata sandi pengganti hasil "Ubah Kata Sandi", per ID akun. Sengaja hanya di
  // memori: kata sandi tidak disimpan di perangkat.
  static final Map<String, String> _passwordOverrides = {};

  static String _passwordOf(UserAccount account) =>
      _passwordOverrides[account.id] ?? account.password;

  static UserAccount? _current;

  static UserAccount? get current => _current;

  static bool get isAdmin => _current?.role == UserRole.admin;

  // Admin mengelola kegiatan dan materi dari aplikasi, baik pada mode lokal
  // (data di perangkat) maupun mode server (lewat API; server menolak non-admin).
  static bool get canManageContent => isAdmin;

  // Menandai akun dari server sebagai akun aktif (login, pemulihan sesi, atau
  // setelah data diri diubah).
  static void startRemote(UserAccount account) {
    _current = account;
  }

  // Akun lokal dari login Google (tanpa server): hanya hidup selama sesi ini.
  static void startLocal(UserAccount account) {
    _current = account;
  }

  // Mencocokkan ID (atau email / nomor HP) dan kata sandi dengan akun dummy.
  static bool login(String id, String password) {
    final normalizedId = id.trim().toLowerCase();
    for (final account in [..._accounts, ..._registered]) {
      final idMatches = account.id == normalizedId ||
          account.email.toLowerCase() == normalizedId ||
          account.phone == normalizedId;
      if (idMatches && _passwordOf(account) == password) {
        _current = account;
        return true;
      }
    }
    return false;
  }

  // Mendaftarkan akun jamaah baru. Mengembalikan pesan error, atau null jika
  // berhasil. Email dipakai sebagai ID untuk masuk.
  static String? register({
    required String nama,
    required String phone,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim();
    for (final account in [..._accounts, ..._registered]) {
      if (account.email.toLowerCase() == normalizedEmail) {
        return 'Email sudah terdaftar.';
      }
      if (account.phone == normalizedPhone) {
        return 'Nomor telepon sudah terdaftar.';
      }
    }
    _registered.add(
      UserAccount(
        id: normalizedEmail,
        password: password,
        nama: nama.trim(),
        email: normalizedEmail,
        phone: normalizedPhone,
        role: UserRole.jamaah,
      ),
    );
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
    if (_passwordOf(account) != oldPassword) return 'Kata sandi lama salah.';
    if (newPassword == oldPassword) {
      return 'Kata sandi baru harus berbeda dari yang lama.';
    }
    _passwordOverrides[account.id] = newPassword;
    return null;
  }

  static void logout() {
    _current = null;
  }

  // Mengembalikan keadaan awal (dipakai pengujian).
  @visibleForTesting
  static void resetForTest() {
    _current = null;
    _registered.clear();
    _passwordOverrides.clear();
  }
}
