import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/api_models.dart';
import 'package:masjid/data/api/murobi_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EdukasiType { artikel, video }

// Kategori materi (tab di halaman Edukasi).
const List<String> edukasiKategori = [
  'Rekomendasi',
  'Anak-anak',
  'Remaja',
  'Orang Tua',
];

// Satu materi pembelajaran: artikel (teks) atau video (tautan YouTube).
class EdukasiItem {
  const EdukasiItem({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.tipe,
    required this.penulis,
    required this.createdAt,
    this.isi = '',
    this.videoUrl,
    this.coverAsset,
    this.coverBytes,
    this.coverUrl,
    this.fileUrl,
  });

  final String id;
  final String judul;
  final String kategori;
  final EdukasiType tipe;
  final String penulis;
  final DateTime createdAt;

  // Isi artikel, atau deskripsi singkat untuk video.
  final String isi;

  // Tautan video (hanya untuk tipe video).
  final String? videoUrl;

  // Gambar sampul: dari aset aplikasi (data bawaan), unggahan admin, atau
  // alamat gambar di server.
  final String? coverAsset;
  final Uint8List? coverBytes;
  final String? coverUrl;

  // Berkas lampiran artikel dari server yang bukan gambar (mis. PDF).
  final String? fileUrl;

  bool get isVideo => tipe == EdukasiType.video;

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'kategori': kategori,
        'tipe': tipe.name,
        'penulis': penulis,
        'createdAt': createdAt.toIso8601String(),
        'isi': isi,
        if (videoUrl != null) 'videoUrl': videoUrl,
        if (coverAsset != null) 'coverAsset': coverAsset,
        if (coverBytes != null) 'cover': base64Encode(coverBytes!),
      };

  factory EdukasiItem.fromJson(Map<String, dynamic> json) => EdukasiItem(
        id: json['id'] as String,
        judul: json['judul'] as String,
        kategori: json['kategori'] as String,
        tipe: EdukasiType.values.firstWhere(
          (e) => e.name == json['tipe'],
          orElse: () => EdukasiType.artikel,
        ),
        penulis: json['penulis'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isi: (json['isi'] as String?) ?? '',
        videoUrl: json['videoUrl'] as String?,
        coverAsset: json['coverAsset'] as String?,
        coverBytes: json['cover'] == null
            ? null
            : base64Decode(json['cover'] as String),
      );
}

// Daftar materi Edukasi. Tanpa server disimpan di perangkat (shared_preferences).
// Dengan server, materi dimuat dari API (buku dan video). Pada kedua mode admin
// dapat menambah, mengubah, dan menghapus (dengan server lewat API, hanya untuk
// akun admin).
class EdukasiStore extends ChangeNotifier {
  EdukasiStore({DateTime Function()? clock, MurobiApi? api, bool? remote})
      : _clock = clock ?? DateTime.now,
        _api = api ?? MurobiApi.instance,
        remote = remote ?? ApiConfig.enabled {
    _items = this.remote ? [] : _seed(_clock());
  }

  static final EdukasiStore instance = EdukasiStore();

  static const String _prefsKey = 'edukasi_v1';

  // Batas jumlah materi agar penyimpanan perangkat tidak penuh.
  static const int maxItems = 40;

  // Jumlah materi terbaru pada tab Rekomendasi saat memakai server.
  static const int maxRekomendasi = 5;

  // Kategori dari server: 0 anak-anak, 1 remaja, 2 orang tua.
  static const List<String> _kategoriServer = [
    'Anak-anak',
    'Remaja',
    'Orang Tua',
  ];

  final DateTime Function() _clock;
  final MurobiApi _api;

  // True jika data berasal dari server.
  final bool remote;

  late List<EdukasiItem> _items;
  Future<void>? _loading;
  bool _mutated = false;

  // Khusus server: sedang memuat dan pesan kegagalan terakhir memuat.
  bool loading = false;
  String? error;

  // Pesan kegagalan terakhir menambah/mengubah/menghapus (null jika berhasil).
  String? writeError;

  // Pilihan kategori pada form: dengan server hanya tiga kategori yang dikenal
  // server (Rekomendasi diturunkan dari materi terbaru, bukan kategori sendiri).
  List<String> get kategoriChoices =>
      remote ? _kategoriServer : edukasiKategori;

  List<EdukasiItem> get items => List.unmodifiable(_items);

  bool get canAddMore => remote || _items.length < maxItems;

  EdukasiItem? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  // Materi pada satu kategori, yang terbaru di atas. Dengan server,
  // "Rekomendasi" berisi materi terbaru dari semua kategori.
  List<EdukasiItem> byKategori(String kategori) {
    final list = _items
        .where((e) => remote && kategori == 'Rekomendasi'
            ? true
            : e.kategori == kategori)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (remote && kategori == 'Rekomendasi' && list.length > maxRekomendasi) {
      return list.sublist(0, maxRekomendasi);
    }
    return list;
  }

  String newId() => _clock().microsecondsSinceEpoch.toString();

  // Memuat data (dari penyimpanan, atau server). Aman dipanggil berkali-kali.
  Future<void> load() => _loading ??= remote ? _fetch() : _load();

  // Memuat ulang dari server (tarik untuk menyegarkan). Tanpa server: tidak
  // melakukan apa pun.
  Future<void> refresh() {
    if (!remote) return Future.value();
    return _loading = _fetch();
  }

  Future<void> _fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([_api.books(), _api.videos()]);
      _items = [...results[0], ...results[1]].map(_fromApi).toList();
    } on ApiException catch (e) {
      error = e.message;
    }
    loading = false;
    notifyListeners();
  }

  static bool _isImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    return const ['.png', '.jpg', '.jpeg', '.webp', '.gif']
        .any(path.endsWith);
  }

  static EdukasiItem _fromApi(ApiEdukasi e) {
    final url = e.contentUrl;
    final isImage = url != null && _isImageUrl(url);
    return EdukasiItem(
      id: 'api-${e.id}',
      judul: e.judul,
      kategori: e.kategori >= 0 && e.kategori < _kategoriServer.length
          ? _kategoriServer[e.kategori]
          : 'Rekomendasi',
      tipe: e.isVideo ? EdukasiType.video : EdukasiType.artikel,
      penulis: 'Admin Masjid',
      createdAt: e.createdAt,
      isi: e.deskripsi,
      videoUrl: e.isVideo ? url : null,
      coverUrl: !e.isVideo && isImage ? url : null,
      fileUrl: !e.isVideo && !isImage ? url : null,
    );
  }

  Future<void> _load() async {
    var firstRun = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) {
        firstRun = true;
      } else if (!_mutated) {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => EdukasiItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: pakai data bawaan.
      if (!_mutated) _items = _seed(_clock());
    }
    notifyListeners();

    // Simpan data bawaan sekali agar waktu "x jam lalu" terus berjalan, bukan
    // diulang dari awal setiap aplikasi dibuka.
    if (firstRun && !_mutated) await _persist();
  }

  // Menambah materi. Mengembalikan false jika sudah penuh atau gagal disimpan.
  Future<bool> add(EdukasiItem item) async {
    writeError = null;
    if (remote) return _addRemote(item);
    await load();
    if (!canAddMore) return false;

    final previous = _items;
    _mutated = true;
    _items = [item, ...previous];
    notifyListeners();

    final saved = await _persist();
    if (!saved) {
      _items = previous;
      notifyListeners();
    }
    return saved;
  }

  // Mengganti materi dengan id yang sama. False jika id tidak ada atau gagal disimpan.
  Future<bool> update(EdukasiItem item) async {
    writeError = null;
    if (remote) return _updateRemote(item);
    await load();
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index < 0) return false;

    final previous = _items;
    _mutated = true;
    _items = [...previous]..[index] = item;
    notifyListeners();

    final saved = await _persist();
    if (!saved) {
      _items = previous;
      notifyListeners();
    }
    return saved;
  }

  // Menghapus materi. Daftar berubah seketika (tanpa await) karena Dismissible
  // mensyaratkan item sudah hilang saat onDismissed selesai. Pada mode server
  // daftar dikembalikan bila penghapusan di server gagal. Hasilnya true jika
  // berhasil.
  Future<bool> remove(String id) {
    writeError = null;
    final previous = _items;
    _mutated = true;
    _items = _items.where((e) => e.id != id).toList();
    notifyListeners();
    if (!remote) return _persist();
    return _removeRemote(id, previous);
  }

  int _kategoriIndex(String kategori) {
    final index = _kategoriServer.indexOf(kategori);
    return index < 0 ? 0 : index;
  }

  // Server mewajibkan deskripsi; video tanpa deskripsi memakai judulnya.
  String _deskripsiFor(EdukasiItem item) =>
      item.isi.trim().isEmpty ? item.judul : item.isi;

  Future<bool> _addRemote(EdukasiItem item) async {
    try {
      final created = await _api.createEdukasi(
        isVideo: item.isVideo,
        judul: item.judul,
        kategori: _kategoriIndex(item.kategori),
        deskripsi: _deskripsiFor(item),
        cover: item.isVideo ? null : item.coverBytes,
        videoUrl: item.isVideo ? item.videoUrl : null,
      );
      _items = [_fromApi(created), ..._items];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      writeError = e.message;
      return false;
    }
  }

  // Hanya bagian yang berubah yang dikirim: gambar sampul baru (bytes) dan
  // tautan video yang berbeda dari yang tersimpan.
  Future<bool> _updateRemote(EdukasiItem item) async {
    final current = byId(item.id);
    final serverId = int.tryParse(item.id.replaceFirst('api-', ''));
    if (current == null || serverId == null) {
      writeError = 'Materi tidak ditemukan.';
      return false;
    }
    try {
      final updated = await _api.updateEdukasi(
        serverId,
        isVideo: current.isVideo,
        judul: item.judul,
        kategori: _kategoriIndex(item.kategori),
        deskripsi: _deskripsiFor(item),
        cover: current.isVideo ? null : item.coverBytes,
        videoUrl: current.isVideo && item.videoUrl != current.videoUrl
            ? item.videoUrl
            : null,
      );
      final index = _items.indexWhere((e) => e.id == item.id);
      if (index >= 0) {
        _items = [..._items]..[index] = _fromApi(updated);
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      writeError = e.message;
      return false;
    }
  }

  Future<bool> _removeRemote(String id, List<EdukasiItem> previous) async {
    final serverId = int.tryParse(id.replaceFirst('api-', ''));
    if (serverId == null) return true;
    try {
      await _api.deleteEdukasi(serverId);
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

  // Data bawaan. Video berisi tautan hasil pencarian YouTube sebagai contoh;
  // admin dapat menggantinya dengan video pilihan masjid.
  static List<EdukasiItem> _seed(DateTime now) {
    EdukasiItem artikel({
      required String id,
      required String judul,
      required String kategori,
      required Duration lalu,
      required String isi,
      String penulis = 'Admin Masjid',
      String cover = 'assets/images/anak.png',
    }) {
      return EdukasiItem(
        id: id,
        judul: judul,
        kategori: kategori,
        tipe: EdukasiType.artikel,
        penulis: penulis,
        createdAt: now.subtract(lalu),
        isi: isi,
        coverAsset: cover,
      );
    }

    EdukasiItem video({
      required String id,
      required String judul,
      required String kategori,
      required Duration lalu,
      required String pencarian,
    }) {
      return EdukasiItem(
        id: id,
        judul: judul,
        kategori: kategori,
        tipe: EdukasiType.video,
        penulis: 'Admin Masjid',
        createdAt: now.subtract(lalu),
        isi: 'Kumpulan video pembelajaran di YouTube. Admin masjid dapat '
            'menggantinya dengan video pilihan.',
        videoUrl: Uri.https(
          'www.youtube.com',
          '/results',
          {'search_query': pencarian},
        ).toString(),
      );
    }

    const rekomendasi = 'assets/images/rekomendasi.png';

    return [
      artikel(
        id: 'seed-rekomendasi-1',
        judul: "11 Kampus Ini Tawarkan Beasiswa Hafidz Al-Qur'an",
        kategori: 'Rekomendasi',
        lalu: const Duration(hours: 4),
        penulis: 'Bella',
        cover: rekomendasi,
        isi: "Sejumlah perguruan tinggi membuka jalur beasiswa bagi penghafal "
            "Al-Qur'an. Pantau pengumuman resmi kampus untuk mengetahui "
            'persyaratan dan jadwal pendaftarannya.',
      ),
      artikel(
        id: 'seed-rekomendasi-2',
        judul: "Keutamaan Membaca Al-Qur'an Setiap Hari",
        kategori: 'Rekomendasi',
        lalu: const Duration(days: 1),
        cover: rekomendasi,
        isi: "Membaca Al-Qur'an secara rutin, meski hanya beberapa ayat setiap "
            "hari, melatih kelancaran bacaan dan menjaga kedekatan dengan "
            "Al-Qur'an. Mulailah dari target kecil yang konsisten.",
      ),
      artikel(
        id: 'seed-rekomendasi-3',
        judul: 'Adab Masuk dan Keluar Masjid',
        kategori: 'Rekomendasi',
        lalu: const Duration(days: 2),
        cover: rekomendasi,
        isi: 'Saat masuk masjid, dianjurkan mendahulukan kaki kanan dan membaca '
            'doa masuk masjid. Saat keluar, dahulukan kaki kiri dan baca doa '
            'keluar masjid.',
      ),
      artikel(
        id: 'seed-anak-1',
        judul: 'Mengenal Rukun Islam untuk Anak',
        kategori: 'Anak-anak',
        lalu: const Duration(hours: 3),
        isi: 'Rukun Islam ada lima: syahadat, sholat lima waktu, zakat, puasa '
            'di bulan Ramadhan, dan haji bagi yang mampu. Ajak anak '
            'menyebutkannya berurutan setiap hari.',
      ),
      artikel(
        id: 'seed-anak-2',
        judul: 'Belajar Wudhu Langkah demi Langkah',
        kategori: 'Anak-anak',
        lalu: const Duration(days: 1),
        isi: 'Wudhu diawali niat dan basmalah, lalu membasuh telapak tangan, '
            'berkumur, membasuh wajah, kedua tangan hingga siku, mengusap '
            'kepala, dan membasuh kedua kaki.',
      ),
      artikel(
        id: 'seed-anak-3',
        judul: 'Doa Sehari-hari yang Mudah Dihafal',
        kategori: 'Anak-anak',
        lalu: const Duration(days: 3),
        isi: 'Mulailah dari doa sebelum makan, doa sesudah makan, dan doa '
            'sebelum tidur. Ulangi bersama orang tua setiap hari agar anak '
            'mudah menghafalnya.',
      ),
      video(
        id: 'seed-anak-video',
        judul: 'Video: Belajar Wudhu untuk Anak',
        kategori: 'Anak-anak',
        lalu: const Duration(hours: 8),
        pencarian: 'belajar wudhu untuk anak',
      ),
      artikel(
        id: 'seed-remaja-1',
        judul: 'Menjaga Sholat Lima Waktu di Tengah Kesibukan',
        kategori: 'Remaja',
        lalu: const Duration(hours: 5),
        isi: 'Atur pengingat waktu sholat, siapkan perlengkapan sholat di tas, '
            'dan manfaatkan jadwal sholat di aplikasi MUROBI agar tidak '
            'terlewat.',
      ),
      artikel(
        id: 'seed-remaja-2',
        judul: 'Tips Konsisten Mengaji Setiap Hari',
        kategori: 'Remaja',
        lalu: const Duration(days: 2),
        isi: 'Tetapkan waktu khusus, misalnya setelah Subuh atau Maghrib, dan '
            'mulai dari target yang ringan. Konsistensi lebih penting daripada '
            'jumlah halaman.',
      ),
      artikel(
        id: 'seed-remaja-3',
        judul: 'Memilih Pergaulan yang Baik',
        kategori: 'Remaja',
        lalu: const Duration(days: 4),
        isi: 'Lingkungan pertemanan memengaruhi kebiasaan. Bergabunglah dengan '
            'kegiatan remaja masjid untuk mendapat teman yang saling '
            'mengingatkan dalam kebaikan.',
      ),
      video(
        id: 'seed-remaja-video',
        judul: 'Video: Kajian Remaja Muslim',
        kategori: 'Remaja',
        lalu: const Duration(hours: 9),
        pencarian: 'kajian remaja muslim',
      ),
      artikel(
        id: 'seed-ortu-1',
        judul: 'Mendidik Anak Mencintai Masjid',
        kategori: 'Orang Tua',
        lalu: const Duration(hours: 6),
        isi: 'Ajak anak ke masjid sejak kecil, kenalkan suasananya dengan '
            'menyenangkan, dan beri teladan dengan menjaga sholat berjamaah.',
      ),
      artikel(
        id: 'seed-ortu-2',
        judul: 'Membiasakan Sholat Berjamaah di Keluarga',
        kategori: 'Orang Tua',
        lalu: const Duration(days: 2),
        isi: 'Mulailah dengan satu waktu sholat berjamaah di rumah, misalnya '
            'Maghrib, lalu tambahkan secara bertahap sesuai kemampuan keluarga.',
      ),
      artikel(
        id: 'seed-ortu-3',
        judul: "Mengajarkan Al-Qur'an Sejak Dini",
        kategori: 'Orang Tua',
        lalu: const Duration(days: 5),
        isi: 'Kenalkan huruf hijaiyah dengan cara yang menyenangkan, dan '
            'dampingi anak membaca secara rutin dengan sabar.',
      ),
      video(
        id: 'seed-ortu-video',
        judul: 'Video: Parenting Islami',
        kategori: 'Orang Tua',
        lalu: const Duration(hours: 10),
        pencarian: 'parenting islami',
      ),
    ];
  }
}
