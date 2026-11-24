import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// AssetBundle tanpa data Al-Qur'an bawaan: ApiService lalu memakai jalur
// internet (MockClient) dan salinan tersimpan, seperti sebelum teks Al-Qur'an
// disertakan di aplikasi. Dipakai tes yang memakai data surah tiruan.
class NoBundledQuran extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future<ByteData>.error(FlutterError('Tanpa data bawaan: $key'));
}

final NoBundledQuran noBundledQuran = NoBundledQuran();
