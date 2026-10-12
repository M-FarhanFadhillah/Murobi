// Pembaca alamat video YouTube untuk materi Edukasi.

final RegExp _videoIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');
final RegExp _hasSchemePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:');

// Alamat web (http/https) yang aman dibuka di aplikasi lain. Teks tanpa skema
// (mis. "youtube.com/watch?v=...") dianggap https. Skema lain seperti tel:,
// mailto:, javascript:, atau intent: ditolak.
Uri? safeWebUri(String url) {
  final text = url.trim();
  if (text.isEmpty) return null;

  final withScheme = text.contains('://') || _hasSchemePattern.hasMatch(text)
      ? text
      : 'https://$text';

  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

// Mengambil ID video (11 karakter) dari berbagai bentuk tautan YouTube:
// youtube.com/watch?v=ID, youtu.be/ID, youtube.com/embed/ID, /shorts/ID, /live/ID.
// Mengembalikan null jika bukan tautan video YouTube yang valid.
String? youtubeVideoId(String url) {
  final uri = safeWebUri(url);
  if (uri == null) return null;

  final host =
      uri.host.toLowerCase().replaceFirst(RegExp(r'^(www|m|music)\.'), '');

  String? id;
  if (host == 'youtu.be') {
    if (uri.pathSegments.isNotEmpty) id = uri.pathSegments.first;
  } else if (host == 'youtube.com' || host == 'youtube-nocookie.com') {
    if (uri.path == '/watch') {
      id = uri.queryParameters['v'];
    } else if (uri.pathSegments.length >= 2 &&
        const {'embed', 'shorts', 'live', 'v'}.contains(uri.pathSegments[0])) {
      id = uri.pathSegments[1];
    }
  }

  if (id != null && _videoIdPattern.hasMatch(id)) return id;
  return null;
}

// Gambar mini video. "mq" (320x180, 16:9) untuk kartu kecil, "hq" (480x360)
// untuk tampilan besar. Mengembalikan null jika bukan tautan video yang valid.
Uri? youtubeThumbnailUri(String url, {bool large = false}) {
  final id = youtubeVideoId(url);
  if (id == null) return null;
  return Uri.https(
    'img.youtube.com',
    '/vi/$id/${large ? 'hqdefault' : 'mqdefault'}.jpg',
  );
}
