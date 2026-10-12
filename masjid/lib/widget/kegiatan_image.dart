import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/services/kegiatan_store.dart';

// Gambar poster kegiatan: dari aset aplikasi, hasil unggahan admin, atau server.
class KegiatanImage extends StatelessWidget {
  const KegiatanImage({
    super.key,
    required this.kegiatan,
    this.fit = BoxFit.cover,
    this.cacheWidth = 900,
  });

  final Kegiatan kegiatan;
  final BoxFit fit;

  // Batas lebar decode untuk gambar aset agar hemat memori.
  final int? cacheWidth;

  // Pengganti saat gambar tidak ada atau gagal dimuat: ikon dan judul kegiatan.
  Widget _error() {
    return ColoredBox(
      color: const Color(0xFFE3EEE6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_outlined,
                color: AppPalette.textMuted,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                kegiatan.judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = kegiatan.imageBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _error(),
      );
    }
    final url = kegiatan.imageUrl;
    if (url != null) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _error(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const ColoredBox(
                color: Color(0xFFE3EEE6),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
      );
    }

    final asset = kegiatan.asset;
    if (asset == null) return _error();
    return Image.asset(
      asset,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, __, ___) => _error(),
    );
  }
}
