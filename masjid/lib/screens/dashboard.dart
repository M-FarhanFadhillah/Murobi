import 'package:flutter/material.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/screens/dashboard/edukasi_pages.dart';
import 'package:masjid/screens/dashboard/home_pages.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/ui/quran_tab.dart';

// Fitur di luar cakupan skripsi (Ziswaf, Qurban, Laporan) tidak ditampilkan di
// navigasi. File-nya tetap ada agar bisa dikembangkan lagi nanti.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const int _profileIndex = 3;

  static const List<AppNavItem> _navItems = [
    AppNavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    AppNavItem(
      label: 'Edukasi',
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
    ),
    AppNavItem(
      label: "Al-Qur'an",
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
    ),
    AppNavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeWidget(onOpenProfile: () => _onItemTapped(_profileIndex)),
      const EdukasiWidget(),
      const QuranTab(),
      const ProfilePages(),
    ];

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              // IndexedStack menjaga state tiap tab (mis. posisi gulir).
              child: IndexedStack(index: _selectedIndex, children: pages),
            ),
            AppBottomNav(
              items: _navItems,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}
