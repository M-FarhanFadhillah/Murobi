import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/api_models.dart';
import 'package:masjid/data/api/murobi_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Satu poster kegiatan masjid. Gambar berasal dari aset aplikasi (data bawaan),
// hasil unggahan admin (imageBytes), atau server (imageUrl).
class Kegiatan {
  const Kegiatan({
    required this.id,
    required this.judul,
    this.asset,
    this.imageBytes,
    this.imageUrl,
    this.deskripsi = '',
  });

  final String id;
  final String judul;
  final String? asset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String deskripsi;

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        if (asset != null) 'asset': asset,
        if (imageBytes != null) 'image': base64Encode(imageBytes!),
      };

  factory Kegiatan.fromJson(Map<String, dynamic> json) => Kegiatan(
        id: json['id'] as String,
        judul: json['judul'] as String,
        asset: json['asset'] as String?,
        imageBytes: json['image'] == null
            ? null
            : base64Decode(json['image'] as String),
      );
}

// Daftar kegiatan masjid. Tanpa server disimpan di perangkat
// (shared_preferences). Dengan server, daftar dimuat dari API untuk masjid yang
// dipilih. Pada kedua mode admin dapat menambah dan menghapus kegiatan (dengan
// server lewat API, hanya untuk akun admin).
class KegiatanStore extends ChangeNotifier {
  KegiatanStore({MurobiApi? api, bool? remote})
      : _api = api ?? MurobiApi.instance,
        remote = remote ?? ApiConfig.enabled {
    _items = this.remote ? [] : List.of(_seed);
  }

  static final KegiatanStore instance = KegiatanStore();

  static const String _prefsKey = 'kegiatan_v1';

  // Batas jumlah poster unggahan agar penyimpanan perangkat tidak penuh.
  static const int maxUploads = 10;

  static const List<Kegiatan> _seed = [
    Kegiatan(
      id: 'seed-isra',
      judul: "Isra Mi'raj Masjid As-Syifa",
      asset: 'assets/images/isra.png',
    ),
    Kegiatan(
      id: 'seed-lomba',
      judul: 'Hari Perlombaan Jamaah As-Syifa',
      asset: 'assets/images/lomba.png',
    ),
  ];

  final MurobiApi _api;

  // True jika data berasal dari server.
  final bool remote;

  late List<Kegiatan> _items;
  Future<void>? _loading;
  bool _mutated = false;

  // Pesan kegagalan terakhir menambah/menghapus (null jika berhasil).
  String? writeError;

  // Khusus server: pesan kegagalan memuat dan masjid terpilih.
  String? error;
  bool _fetching = false;
  bool _masjidChosen = false;
  int? _masjidId;
  int? _loadedFor;
  int _generation = 0;

  // Khusus server: true selama memuat, termasuk sebelum masjid dipilih (agar
  // layar tidak sempat menampilkan "belum ada kegiatan").
  bool get loading => remote && (_fetching || (!_masjidChosen && error == null));

  List<Kegiatan> get items => List.unmodifiable(_items);

  int get uploadCount => _items.where((e) => e.imageBytes != null).length;

  bool get canUploadMore => remote || uploadCount < maxUploads;

  // Memuat data. Aman dipanggil berkali-kali. Dengan server, data baru dimuat
  // setelah masjid dipilih lewat [selectMasjid].
  Future<void> load() {
    if (remote) return _loading ?? Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      // Jika sudah ada perubahan selama memuat, jangan menimpanya.
      if (raw != null && !_mutated) {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => Kegiatan.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: pakai daftar bawaan.
      if (!_mutated) _items = List.of(_seed);
    }
    notifyListeners();
  }

  // Khusus server: memilih masjid lalu memuat kegiatannya. [id] null berarti
  // daftar masjid belum berhasil dimuat.
  Future<void> selectMasjid(int? id) {
    if (!remote) return load();
    _masjidChosen = true;
    _masjidId = id;
    if (id != _loadedFor && _items.isNotEmpty) {
      // Kegiatan masjid lain tidak boleh tampil sambil menunggu.
      _items = [];
      notifyListeners();
    }
    return _loading = _fetch();
  }

  // Memuat ulang kegiatan masjid terpilih (tarik untuk menyegarkan).
  Future<void> refresh() {
    if (!remote || !_masjidChosen) return Future.value();
    return _loading = _fetch();
  }

  Future<void> _fetch() async {
    final generation = ++_generation;
    final masjidId = _masjidId;
    if (masjidId == null) {
      _fetching = false;
      error = 'Daftar masjid belum dapat dimuat.';
      notifyListeners();
      return;
    }

    _fetching = true;
    error = null;
    notifyListeners();

    try {
      final list = await _api.activities(masjidId: masjidId);
      if (generation != _generation) return;
      _items = [
        for (final e in list)
          Kegiatan(
            id: 'api-${e.id}',
            judul: e.nama,
            imageUrl: e.pictUrl,
            deskripsi: e.deskripsi,
          ),
      ];
      _loadedFor = masjidId;
    } on ApiException catch (e) {
      if (generation != _generation) return;
      error = e.message;
    }
    _fetching = false;
    notifyListeners();
  }

  // Menambah poster di urutan teratas. Mengembalikan false jika gagal disimpan
  // (misalnya penyimpanan penuh); daftar dikembalikan seperti semula.
  Future<bool> add(String judul, Uint8List imageBytes) async {
    writeError = null;
    if (remote) return _addRemote(judul, imageBytes);
    await load();
    final previous = _items;
    _mutated = true;
    _items = [
      Kegiatan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        judul: judul.trim(),
        imageBytes: imageBytes,
      ),
      ...previous,
    ];
    notifyListeners();

    final saved = await _persist();
    if (!saved) {
      writeError = 'Penyimpanan perangkat penuh. Hapus poster lama lalu coba lagi.';
      _items = previous;
      notifyListeners();
    }
    return saved;
  }

  // Server: kegiatan baru milik masjid yang sedang dipilih.
  Future<bool> _addRemote(String judul, Uint8List imageBytes) async {
    final masjidId = _masjidId;
    if (masjidId == null) {
      writeError = 'Pilih masjid di Beranda terlebih dahulu.';
      return false;
    }
    try {
      final created = await _api.createActivity(
        masjidId: masjidId,
        nama: judul.trim(),
        deskripsi: '',
        poster: imageBytes,
      );
      _items = [_fromApi(created), ..._items];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      writeError = e.message;
      return false;
    }
  }

  Kegiatan _fromApi(ApiActivity e) => Kegiatan(
        id: 'api-${e.id}',
        judul: e.nama,
        imageUrl: e.pictUrl,
        deskripsi: e.deskripsi,
      );

  // Menghapus poster. Perubahan daftar terjadi seketika (tanpa await) karena
  // Dismissible mensyaratkan item sudah hilang saat onDismissed selesai. Pada
  // mode server daftar dikembalikan bila penghapusan di server gagal. Hasilnya
  // true jika berhasil.
  Future<bool> remove(String id) {
    writeError = null;
    final previous = _items;
    _mutated = true;
    _items = _items.where((e) => e.id != id).toList();
    notifyListeners();
    if (!remote) return _persist();
    return _removeRemote(id, previous);
  }

  Future<bool> _removeRemote(String id, List<Kegiatan> previous) async {
    final serverId = int.tryParse(id.replaceFirst('api-', ''));
    if (serverId == null) return true;
    try {
      await _api.deleteActivity(serverId);
      return true;
    } on ApiException catch (e) {
      // 404 = sudah terhapus (mis. oleh admin lain): daftar tetap tanpa item itu.
      if (e.statusCode == 404) return true;
      writeError = e.message;
      // Beri waktu satu frame agar Dismissible yang baru dilepas benar-benar
      // keluar dari pohon widget sebelum item yang sama dipasang kembali.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      _items = previous;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _prefsKey,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }
}
