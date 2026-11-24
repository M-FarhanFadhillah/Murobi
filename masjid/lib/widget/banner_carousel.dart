import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Carousel banner kegiatan di beranda, berpindah otomatis tiap 4 detik.
// [images] berisi jalur aset ("assets/...") atau alamat gambar ("http...").
// Tinggi banner mengikuti lebar layar dengan proporsi gambar banner, sehingga
// gambar tidak tampak tertarik atau terpotong di layar sempit maupun lebar.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.images});

  final List<String> images;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const double _viewportFraction = 0.9;

  // Proporsi gambar banner (lebar : tinggi), mis. 1719x894 dan 2031x1056.
  static const double _imageAspectRatio = 1.92;

  // Jarak di sekeliling tiap banner (lihat Padding di itemBuilder).
  static const double _gap = 6;

  final PageController _controller =
      PageController(viewportFraction: _viewportFraction);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || widget.images.length < 2) return;
      _page = (_page + 1) % widget.images.length;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFE3EEE6),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppPalette.textMuted,
          size: 36,
        ),
      ),
    );
  }

  Widget _image(String source) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
      );
    }
    return Image.asset(
      source,
      fit: BoxFit.cover,
      cacheWidth: 900,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final imageWidth =
                constraints.maxWidth * _viewportFraction - _gap * 2;
            return SizedBox(
              height: imageWidth / _imageAspectRatio + _gap * 2,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (index) => _page = index,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(_gap),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppPalette.softShadow,
                    ),
                    child: _image(widget.images[index]),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _controller,
          count: widget.images.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 7,
            dotWidth: 7,
            expansionFactor: 3,
            activeDotColor: AppPalette.primary,
            dotColor: Colors.black26,
          ),
        ),
      ],
    );
  }
}
