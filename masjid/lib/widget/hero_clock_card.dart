import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/services/masjid_store.dart';

// Kartu jam di beranda (sesuai Figma): jam dan tanggal berjalan di tengah atas,
// ornamen emas di kedua sudut, ilustrasi masjid di kiri bawah, dan pilihan
// masjid di kanan bawah.
class HeroClockCard extends StatefulWidget {
  const HeroClockCard({
    super.key,
    required this.masjids,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<MasjidInfo> masjids;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<HeroClockCard> createState() => _HeroClockCardState();
}

class _HeroClockCardState extends State<HeroClockCard> {
  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  late DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final selected = widget.masjids[widget.selectedIndex];

    return Container(
      height: 188,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppPalette.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppPalette.softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset('assets/images/left.png', width: 72),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset('assets/images/right.png', width: 72),
          ),
          // Jam dan tanggal: tepat di tengah lebar kartu. Margin kiri-kanan
          // sama besar, jadi posisinya tidak bergeser ke satu sisi.
          Positioned(
            top: 30,
            left: 56,
            right: 56,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_two(_now.hour)}:${_two(_now.minute)}:${_two(_now.second)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      // Lebar angka dibuat tetap agar jam tidak bergoyang.
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '${_now.day} ${_bulan[_now.month - 1]} ${_now.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 6,
            child: Image.asset(
              'assets/images/awan.png',
              width: 132,
              cacheWidth: 400,
            ),
          ),
          Positioned(
            left: 150,
            right: 14,
            bottom: 16,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildMasjidPicker(selected),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasjidPicker(MasjidInfo selected) {
    return PopupMenuButton<int>(
      onSelected: widget.onSelected,
      offset: const Offset(0, -8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        for (var i = 0; i < widget.masjids.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.masjids[i].nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.masjids[i].lokasi,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white38),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.nama,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    selected.lokasi,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
