import 'package:flutter/material.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/screens/dashboard/edukasi_pages.dart';
import 'package:masjid/screens/dashboard/empty_tab.dart';
import 'package:masjid/screens/dashboard/home_pages.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/ui/quran_tab.dart';

// Halaman utama dengan navigasi bawah: Beranda, Edukasi, Al-Qur'an, ZISWAF, dan
// Keuangan. Bisa dipakai tanpa akun. ZISWAF dan Keuangan sengaja masih kosong
// (berkas detail_ziswaf_pages.dart dan keuangan_pages.dart tetap ada untuk
// dikembangkan nanti). Profil tidak ada di navigasi: dibuka lewat foto profil
// di pojok kanan atas Beranda; tamu masuk/daftar dari sana.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
      label: 'ZISWAF',
      icon: Icons.volunteer_activism_outlined,
      activeIcon: Icons.volunteer_activism_rounded,
    ),
    AppNavItem(
      label: 'Keuangan',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
  ];

  // Profil berada setelah halaman-halaman navigasi, jadi tidak ada tombol yang
  // tersorot saat Profil terbuka.
  static final int _profileIndex = _navItems.length;

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
      const EmptyTab(name: 'ziswaf'),
      const EmptyTab(name: 'keuangan'),
      const ProfilePages(),
    ];

    // Navigasi melayang di atas konten: extendBody membuat halaman memanjang
    // sampai bawah layar (terlihat di sekitar kapsul navigasi) dan menaikkan
    // padding bawah MediaQuery setinggi navigasi, yang dipakai halaman tab
    // sebagai ruang akhir gulir.
    return Scaffold(
      extendBody: true,
      body: AppBackground(
        // Aplikasi bisa dipakai tanpa akun. Saat pengguna masuk atau keluar
        // (dari Profil), semua halaman dibangun ulang supaya tampilan yang
        // bergantung pada akun (menu admin, Profil) langsung menyesuaikan; tab
        // yang sedang dibuka tetap sama.
        child: ValueListenableBuilder<UserAccount?>(
          valueListenable: AuthSession.changes,
          builder: (context, account, _) => KeyedSubtree(
            key: ValueKey('${account?.id}:${account?.role.name}'),
            // IndexedStack menjaga state tiap tab (mis. posisi gulir).
            child: IndexedStack(index: _selectedIndex, children: pages),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
