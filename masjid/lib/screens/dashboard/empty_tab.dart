import 'package:flutter/material.dart';

// Halaman kosong untuk tab navigasi yang isinya belum dikerjakan (ZISWAF dan
// Keuangan). Latar gradien disediakan Dashboard.
class EmptyTab extends StatelessWidget {
  const EmptyTab({super.key, required this.name});

  // Nama tab; dipakai sebagai kunci agar mudah dicari saat pengujian.
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(key: ValueKey('tab-kosong-$name'));
  }
}
