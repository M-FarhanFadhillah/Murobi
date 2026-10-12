// Awal setiap juz Al-Qur'an (mushaf standar, 30 juz): nomor juz, nomor surah,
// dan nomor ayat pertamanya. Sudah dicocokkan dengan api.alquran.cloud
// (jumlah ayat seluruh juz = 6.236).
class QuranJuzStart {
  const QuranJuzStart(this.juz, this.surat, this.ayat);

  final int juz;
  final int surat;
  final int ayat;
}

const List<QuranJuzStart> quranJuzStart = [
  QuranJuzStart(1, 1, 1),
  QuranJuzStart(2, 2, 142),
  QuranJuzStart(3, 2, 253),
  QuranJuzStart(4, 3, 93),
  QuranJuzStart(5, 4, 24),
  QuranJuzStart(6, 4, 148),
  QuranJuzStart(7, 5, 82),
  QuranJuzStart(8, 6, 111),
  QuranJuzStart(9, 7, 88),
  QuranJuzStart(10, 8, 41),
  QuranJuzStart(11, 9, 93),
  QuranJuzStart(12, 11, 6),
  QuranJuzStart(13, 12, 53),
  QuranJuzStart(14, 15, 1),
  QuranJuzStart(15, 17, 1),
  QuranJuzStart(16, 18, 75),
  QuranJuzStart(17, 21, 1),
  QuranJuzStart(18, 23, 1),
  QuranJuzStart(19, 25, 21),
  QuranJuzStart(20, 27, 56),
  QuranJuzStart(21, 29, 46),
  QuranJuzStart(22, 33, 31),
  QuranJuzStart(23, 36, 28),
  QuranJuzStart(24, 39, 32),
  QuranJuzStart(25, 41, 47),
  QuranJuzStart(26, 46, 1),
  QuranJuzStart(27, 51, 31),
  QuranJuzStart(28, 58, 1),
  QuranJuzStart(29, 67, 1),
  QuranJuzStart(30, 78, 1),
];
