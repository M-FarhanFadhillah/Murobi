import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/api_models.dart';
import 'package:masjid/data/api/murobi_api.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Satu laporan masalah dari jamaah.
class Laporan {
  const Laporan({
    required this.id,
    required this.nama,
    required this.email,
    required this.pesan,
    required this.waktu,
    this.selesai = false,
    this.ownerId = '',
  });

  factory Laporan.fromApi(ApiReport r) => Laporan(
        id: 'api-${r.id}',
        nama: r.userName,
        email: r.userEmail,
        pesan: r.message,
        waktu: r.createdAt,
        selesai: r.status == 1,
      );

  factory Laporan.fromJson(Map<String, dynamic> json) => Laporan(
        id: json['id'] as String,
        nama: json['nama'] as String,
        email: json['email'] as String,
        pesan: json['pesan'] as String,
        waktu: DateTime.fromMillisecondsSinceEpoch(json['waktu'] as int),
        selesai: json['selesai'] == true,
        ownerId: json['owner'] as String? ?? '',
      );

  final String id;
  final String nama;
  final String email;
  final String pesan;
  final DateTime waktu;
  final bool selesai;

  // Hanya mode lokal: ID akun pengirim (di perangkat yang sama jamaah dan admin
  // berbagi satu penyimpanan, jadi laporan dipisah lewat ID ini).
  final String ownerId;

  Laporan copyWith({bool? selesai}) => Laporan(
        id: id,
        nama: nama,
        email: email,
        pesan: pesan,
        waktu: waktu,
        selesai: selesai ?? this.selesai,
        ownerId: ownerId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'email': email,
        'pesan': pesan,
        'waktu': waktu.millisecondsSinceEpoch,
        'selesai': selesai,
        'owner': ownerId,
      };
}

// Laporan masalah. Jamaah mengirim dan melihat laporannya sendiri; admin
// melihat laporan semua jamaah, menandainya selesai, atau menghapusnya. Tanpa
// server laporan disimpan di perangkat (shared_preferences); dengan server
// lewat API.
class ReportStore extends ChangeNotifier {
  ReportStore({MurobiApi? api, bool? remote})
      : _api = api ?? MurobiApi.instance,
        remote = remote ?? ApiConfig.enabled;

  static final ReportStore instance = ReportStore();

  static const String _prefsKey = 'laporan_v1';

  // Batas jumlah laporan di perangkat (mode lokal); yang terlama dibuang.
  static const int maxLocal = 200;

  final MurobiApi _api;

  // True jika data berasal dari server.
  final bool remote;

  List<Laporan> _all = [];
  bool loading = false;

  // Pesan kegagalan memuat (null jika berhasil).
  String? error;

  // Pesan kegagalan terakhir mengirim/mengubah/menghapus (null jika berhasil).
  String? writeError;

  int _generation = 0;

  // Laporan yang ditampilkan, terbaru di atas: semua laporan untuk admin, dan
  // hanya milik sendiri untuk jamaah. (Server sudah menyaring sendiri.)
  List<Laporan> get items {
    final me = AuthSession.current;
    final list = remote || AuthSession.isAdmin || me == null
        ? _all
        : _all.where((e) => e.ownerId == me.id);
    return List.unmodifiable(list);
  }

  // Jumlah laporan yang belum ditangani.
  int get belumSelesai => items.where((e) => !e.selesai).length;

  Future<void> load() async {
    final generation = ++_generation;
    loading = true;
    error = null;
    notifyListeners();

    if (remote) {
      try {
        final list = AuthSession.isAdmin
            ? await _api.allReports()
            : await _api.myReports();
        if (generation != _generation) return;
        _all = list.map(Laporan.fromApi).toList();
      } on ApiException catch (e) {
        if (generation != _generation) return;
        error = e.message;
      }
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_prefsKey);
        if (generation != _generation) return;
        _all = raw == null
            ? []
            : (jsonDecode(raw) as List<dynamic>)
                .map((e) => Laporan.fromJson(e as Map<String, dynamic>))
                .toList();
      } catch (_) {
        // Data rusak atau penyimpanan tidak tersedia: mulai dari daftar kosong.
        if (generation != _generation) return;
        _all = [];
      }
    }
    loading = false;
    notifyListeners();
  }

  // Mengirim laporan baru dari akun yang sedang masuk. False jika gagal; alasan
  // ada di [writeError].
  Future<bool> send(String pesan) async {
    writeError = null;
    final text = pesan.trim();
    final me = AuthSession.current;
    if (me == null) {
      writeError = 'Anda belum masuk.';
      return false;
    }

    if (remote) {
      try {
        final created = await _api.sendReport(text);
        _all = [Laporan.fromApi(created), ..._all];
        notifyListeners();
        return true;
      } on ApiException catch (e) {
        writeError = e.message;
        return false;
      }
    }

    final previous = _all;
    _all = [
      Laporan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nama: me.nama,
        email: me.email,
        pesan: text,
        waktu: DateTime.now(),
        ownerId: me.id,
      ),
      ...previous,
    ];
    if (_all.length > maxLocal) _all = _all.sublist(0, maxLocal);
    notifyListeners();

    if (await _persist()) return true;
    writeError = 'Laporan tidak dapat disimpan di perangkat.';
    _all = previous;
    notifyListeners();
    return false;
  }

  // Admin: menandai laporan sudah ditangani (atau membukanya kembali).
  Future<bool> setSelesai(String id, bool selesai) async {
    writeError = null;
    final previous = _all;
    final updated = [
      for (final e in previous) e.id == id ? e.copyWith(selesai: selesai) : e,
    ];

    if (remote) {
      final serverId = _serverId(id);
      if (serverId == null) return false;
      try {
        await _api.setReportDone(serverId, done: selesai);
      } on ApiException catch (e) {
        writeError = e.message;
        return false;
      }
      _all = updated;
      notifyListeners();
      return true;
    }

    _all = updated;
    notifyListeners();
    if (await _persist()) return true;
    writeError = 'Perubahan tidak dapat disimpan di perangkat.';
    _all = previous;
    notifyListeners();
    return false;
  }

  // Admin: menghapus laporan.
  Future<bool> remove(String id) async {
    writeError = null;
    final previous = _all;
    final updated = previous.where((e) => e.id != id).toList();

    if (remote) {
      final serverId = _serverId(id);
      if (serverId == null) return false;
      try {
        await _api.deleteReport(serverId);
      } on ApiException catch (e) {
        // 404 = sudah terhapus (mis. oleh admin lain): daftar tetap tanpa item itu.
        if (e.statusCode != 404) {
          writeError = e.message;
          return false;
        }
      }
      _all = updated;
      notifyListeners();
      return true;
    }

    _all = updated;
    notifyListeners();
    if (await _persist()) return true;
    writeError = 'Perubahan tidak dapat disimpan di perangkat.';
    _all = previous;
    notifyListeners();
    return false;
  }

  // Dipanggil saat keluar: laporan akun sebelumnya tidak boleh terlihat oleh
  // akun berikutnya di perangkat yang sama.
  void reset() {
    _generation++;
    if (remote) _all = [];
    loading = false;
    error = null;
    writeError = null;
    notifyListeners();
  }

  static int? _serverId(String id) => int.tryParse(id.replaceFirst('api-', ''));

  Future<bool> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _prefsKey,
        jsonEncode(_all.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }
}
