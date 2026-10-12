// Waktu relatif dalam bahasa Indonesia, mis. "4 jam lalu".
String waktuRelatif(DateTime waktu, {DateTime? sekarang}) {
  final selisih = (sekarang ?? DateTime.now()).difference(waktu);

  if (selisih.isNegative || selisih.inMinutes < 1) return 'baru saja';
  if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
  if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
  if (selisih.inDays < 7) return '${selisih.inDays} hari lalu';
  if (selisih.inDays < 30) return '${selisih.inDays ~/ 7} minggu lalu';
  if (selisih.inDays < 365) return '${selisih.inDays ~/ 30} bulan lalu';
  return '${selisih.inDays ~/ 365} tahun lalu';
}
