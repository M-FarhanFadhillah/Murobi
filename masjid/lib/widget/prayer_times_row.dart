import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/services/api_prayer_service.dart';

// Baris jadwal sholat di beranda (Subuh, Dzuhur, Ashar, Maghrib, Isya').
// Waktu sholat berikutnya diberi sorotan.
class PrayerTimesRow extends StatefulWidget {
  const PrayerTimesRow({super.key});

  @override
  State<PrayerTimesRow> createState() => _PrayerTimesRowState();
}

class _PrayerTimesRowState extends State<PrayerTimesRow> {
  late Future<PrayerTimes> _future = ApiPrayerService().fetchToday();

  void _reload() {
    setState(() => _future = ApiPrayerService().fetchToday());
  }

  int _minutes(String clock) {
    final parts = clock.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Indeks sholat berikutnya; setelah Isya kembali ke Subuh.
  int _nextIndex(List<_Prayer> prayers) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (var i = 0; i < prayers.length; i++) {
      if (_minutes(prayers[i].time) > nowMinutes) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrayerTimes>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppCard(
            child: SizedBox(
              height: 76,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return AppCard(
            child: SizedBox(
              height: 76,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Jadwal sholat belum tersedia'),
                  IconButton(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Muat ulang',
                  ),
                ],
              ),
            ),
          );
        }

        final times = snapshot.data!;
        final prayers = [
          _Prayer('Subuh', times.subuh, Icons.wb_twilight_rounded,
              const [Color(0xFF9CC9FF), Color(0xFFD8E9FF)]),
          _Prayer('Dzuhur', times.dzuhur, Icons.wb_sunny_rounded,
              const [Color(0xFFFFD66B), Color(0xFFFFF0B8)]),
          _Prayer('Ashar', times.ashar, Icons.wb_sunny_outlined,
              const [Color(0xFFFFB86B), Color(0xFFFFE0B8)]),
          _Prayer('Maghrib', times.maghrib, Icons.wb_twilight_rounded,
              const [Color(0xFFFF8E72), Color(0xFFFFCDBF)]),
          _Prayer("Isya'", times.isya, Icons.nightlight_round,
              const [Color(0xFF6F86E8), Color(0xFFB9C6FF)]),
        ];
        final next = _nextIndex(prayers);

        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Row(
            children: [
              for (var i = 0; i < prayers.length; i++)
                Expanded(
                  child: _PrayerTile(
                    prayer: prayers[i],
                    highlighted: i == next,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Prayer {
  const _Prayer(this.name, this.time, this.icon, this.colors);

  final String name;
  final String time;
  final IconData icon;
  final List<Color> colors;
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({required this.prayer, required this.highlighted});

  final _Prayer prayer;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: prayer.colors,
            ),
            borderRadius: BorderRadius.circular(16),
            border: highlighted
                ? Border.all(color: AppPalette.primary, width: 2.5)
                : null,
          ),
          child: Icon(prayer.icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          prayer.time,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: highlighted ? AppPalette.primary : AppPalette.textDark,
          ),
        ),
        Text(
          prayer.name,
          style: TextStyle(
            fontSize: 11,
            color: highlighted ? AppPalette.primary : AppPalette.textMuted,
          ),
        ),
      ],
    );
  }
}
