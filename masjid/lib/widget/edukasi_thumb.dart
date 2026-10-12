import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/youtube_link.dart';
import 'package:masjid/services/edukasi_store.dart';

// Gambar sampul materi Edukasi:
// - unggahan admin (coverBytes), atau gambar di server (coverUrl), atau
// - gambar bawaan (coverAsset; berupa kartu utuh sehingga hanya foto di sisi
//   kiri yang ditampilkan), atau
// - gambar mini video YouTube, atau
// - latar polos berikon jika tidak ada gambar.
// Materi video diberi tanda putar di tengah.
class EdukasiThumb extends StatelessWidget {
  const EdukasiThumb({
    super.key,
    required this.item,
    required this.width,
    required this.height,
    this.largeVideoThumb = false,
  });

  final EdukasiItem item;
  final double width;
  final double height;

  // Pakai gambar mini video yang lebih besar (untuk halaman detail).
  final bool largeVideoThumb;

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.heroGradient),
      child: Center(
        child: Icon(
          item.isVideo
              ? Icons.smart_display_outlined
              : Icons.article_outlined,
          color: Colors.white70,
          size: height * 0.38,
        ),
      ),
    );
  }

  Widget _image() {
    final bytes = item.coverBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final cover = item.coverUrl;
    if (cover != null) {
      return Image.network(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
      );
    }

    final asset = item.coverAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
        cacheWidth: 600,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final videoUrl = item.videoUrl;
    final thumb = item.isVideo && videoUrl != null
        ? youtubeThumbnailUri(videoUrl, large: largeVideoThumb)
        : null;
    if (thumb != null) {
      return Image.network(
        thumb.toString(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
      );
    }

    return _placeholder();
  }

  @override
  Widget build(BuildContext context) {
    final radius = (height < width ? height : width) * 0.15;
    final badge = (height < width ? height : width) * 0.36;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _image(),
            if (item.isVideo)
              Center(
                child: Container(
                  width: badge,
                  height: badge,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: badge * 0.7,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
