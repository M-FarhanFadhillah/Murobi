import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/api_models.dart';
import 'package:masjid/data/api/murobi_api.dart';

class MasjidInfo {
  const MasjidInfo(this.nama, this.kecamatan, {this.id, this.alamat});

  // Masjid dari server: alamatnya satu teks bebas, bukan kecamatan terpisah.
  factory MasjidInfo.fromApi(ApiMasjid masjid) =>
      MasjidInfo(masjid.nama, '', id: masjid.id, alamat: masjid.alamat);

  final String nama;
  final String kecamatan;

  // ID di server (null untuk data bawaan aplikasi).
  final int? id;
  final String? alamat;

  String get lokasi => alamat ?? '$kecamatan, Bandar Lampung';

  String get kecamatanLabel => alamat ?? 'Kecamatan $kecamatan';
}

// Daftar masjid untuk pilihan di beranda. Tanpa server memakai daftar bawaan;
// dengan server memakai /api/masjid (daftar bawaan jika server tak terjangkau,
// tanpa ID sehingga kegiatannya tidak dapat dimuat).
class MasjidStore extends ChangeNotifier {
  MasjidStore({MurobiApi? api, bool? remote})
      : _api = api ?? MurobiApi.instance,
        remote = remote ?? ApiConfig.enabled;

  static final MasjidStore instance = MasjidStore();

  static const List<MasjidInfo> defaults = [
    MasjidInfo('Masjid As-Syifa', 'Rajabasa'),
    MasjidInfo('Masjid Ad-Duha', 'Way Halim'),
    MasjidInfo('Masjid Al-Furqon', 'Teluk'),
    MasjidInfo('Masjid Hizbullah', 'Labuhan Dalam'),
  ];

  final MurobiApi _api;
  final bool remote;

  List<MasjidInfo> masjids = defaults;
  String? error;
  Future<void>? _loading;

  // Memuat daftar masjid. Aman dipanggil berkali-kali.
  Future<void> load() => _loading ??= _fetch();

  // Memuat ulang (mis. setelah gagal karena tanpa jaringan).
  Future<void> reload() => _loading = _fetch();

  Future<void> _fetch() async {
    if (!remote) return;
    error = null;
    try {
      final list = await _api.masjids();
      if (list.isNotEmpty) masjids = list.map(MasjidInfo.fromApi).toList();
    } on ApiException catch (e) {
      error = e.message;
    }
    notifyListeners();
  }
}
