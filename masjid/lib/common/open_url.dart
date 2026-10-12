import 'package:masjid/common/youtube_link.dart';
import 'package:url_launcher/url_launcher.dart';

// Membuka alamat web di aplikasi lain (YouTube/peramban). Mengembalikan false
// jika alamat tidak valid atau tidak ada aplikasi yang dapat membukanya.
Future<bool> openWebUrl(String url) async {
  final uri = safeWebUri(url);
  if (uri == null) return false;

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
