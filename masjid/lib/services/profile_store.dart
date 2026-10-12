import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data profil pengguna yang sedang login. Akun dummy menyimpan perubahan di
// perangkat (shared_preferences) per akun; akun dari server memakai data server
// (lihat AccountService) dan tidak menulis ke penyimpanan perangkat.
class ProfileStore extends ChangeNotifier {
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  String nama = '';
  String email = '';
  String phone = '';

  // Foto yang dipilih di perangkat ini. Didahulukan atas [photoUrl].
  Uint8List? photoBytes;

  // Alamat foto profil di server (hanya akun dari server).
  String? photoUrl;

  String? _accountId;

  String _key(String field) => 'profile_${_accountId}_$field';

  // Foto untuk ditampilkan, atau null jika belum ada.
  ImageProvider? get photoImage {
    final bytes = photoBytes;
    if (bytes != null) return MemoryImage(bytes);
    final url = photoUrl;
    if (url != null) return NetworkImage(url);
    return null;
  }

  // Memuat profil akun. Akun dummy dibaca dari penyimpanan (jika belum ada,
  // dari data akunnya); akun server langsung memakai data dari server.
  Future<void> loadFor(UserAccount account) async {
    _accountId = account.id;
    nama = account.nama;
    email = account.email;
    phone = account.phone;
    photoBytes = null;
    photoUrl = account.photoUrl;

    if (account.isRemote) {
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      nama = prefs.getString(_key('nama')) ?? nama;
      email = prefs.getString(_key('email')) ?? email;
      phone = prefs.getString(_key('phone')) ?? phone;
      final photo = prefs.getString(_key('photo'));
      if (photo != null) photoBytes = base64Decode(photo);
    } catch (_) {
      // Penyimpanan tidak tersedia: tetap pakai data akun.
    }
    notifyListeners();
  }

  // Menerapkan data akun terbaru dari server (setelah ubah data atau foto).
  void applyRemote(UserAccount account) {
    nama = account.nama;
    email = account.email;
    phone = account.phone;
    photoUrl = account.photoUrl;
    notifyListeners();
  }

  Future<void> update({
    required String nama,
    required String email,
    required String phone,
  }) async {
    this.nama = nama;
    this.email = email;
    this.phone = phone;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key('nama'), nama);
      await prefs.setString(_key('email'), email);
      await prefs.setString(_key('phone'), phone);
    } catch (_) {}
  }

  Future<void> setPhoto(Uint8List bytes) async {
    photoBytes = bytes;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key('photo'), base64Encode(bytes));
    } catch (_) {}
  }

  // Menampilkan foto yang baru diunggah ke server tanpa menunggu unduhan ulang.
  void showUploadedPhoto(Uint8List bytes) {
    photoBytes = bytes;
    notifyListeners();
  }

  void clear() {
    _accountId = null;
    nama = '';
    email = '';
    phone = '';
    photoBytes = null;
    photoUrl = null;
    notifyListeners();
  }
}
