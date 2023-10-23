import 'package:flutter/material.dart';
import 'package:masjid/screens/dashboard/beranda_pages.dart';
import 'package:masjid/screens/dashboard/edukasi_pages.dart';
import 'package:masjid/screens/dashboard/ibadah_pages.dart';
import 'package:masjid/screens/dashboard/ziswaf_pages.dart';
import 'package:masjid/screens/dashboard/qurban_pages.dart';
import 'package:masjid/screens/dashboard/keuangan_pages.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Define the selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Handle item selection here
    });
  }

  final List<Widget> _pages = [
    BerandaPages(),
    EdukasiPages(),
    IbadahPages(),
    ZiswafPages(),
    QurbanPages(),
    KeuanganPages(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cast_for_education_rounded),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque_outlined),
            label: 'Ibadah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'Ziswaf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            label: 'Qurban',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}
