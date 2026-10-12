import 'package:flutter/foundation.dart';
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_config.dart';
import 'package:masjid/data/api/murobi_api.dart';

// Banner di carousel beranda. Tanpa server memakai gambar bawaan aplikasi;
// dengan server memakai banner aktif dari panel admin (kosong jika tidak ada
// atau server tak terjangkau, lalu carousel disembunyikan).
//
// Nilai berupa jalur aset ("assets/...") atau alamat gambar ("http...").
class BannerStore extends ChangeNotifier {
  BannerStore({MurobiApi? api, bool? remote})
      : _api = api ?? MurobiApi.instance,
        remote = remote ?? ApiConfig.enabled {
    images = this.remote ? const [] : defaults;
  }

  static final BannerStore instance = BannerStore();

  static const List<String> defaults = [
    'assets/images/infaq.png',
    'assets/images/lomba.png',
    'assets/images/donor.png',
    'assets/images/qurban.png',
  ];

  final MurobiApi _api;
  final bool remote;

  late List<String> images;
  Future<void>? _loading;

  Future<void> load() => _loading ??= _fetch();

  Future<void> reload() => _loading = _fetch();

  Future<void> _fetch() async {
    if (!remote) return;
    try {
      final banners = await _api.banners();
      images = [
        for (final banner in banners)
          if (banner.coverUrl != null) banner.coverUrl!,
      ];
    } on ApiException {
      images = const [];
    }
    notifyListeners();
  }
}
