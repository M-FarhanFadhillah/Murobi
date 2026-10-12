import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid/bloc/ayat/ayat_bloc.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/cubit/surat/surat_cubit.dart';
import 'package:masjid/data/models/surat_model.dart';
import 'package:masjid/data/quran_juz.dart';
import 'package:masjid/services/quran_audio.dart';
import 'package:masjid/services/quran_reading_store.dart';
import 'package:masjid/services/quran_settings.dart';
import 'package:masjid/ui/ayat_page.dart';

enum _QuranTab { surah, juz, bookmark }

// Halaman Al-Qur'an (sesuai Figma "Al-Qur'an"): tab Surah, Juz, dan Bookmark,
// pencarian, serta kartu "Terakhir dibaca".
class SuratPage extends StatefulWidget {
  const SuratPage({
    super.key,
    this.readingStore,
    this.settings,
    this.createAudioPlayer,
  });

  // Dapat diganti saat pengujian; bawaannya memakai instance bersama.
  final QuranReadingStore? readingStore;
  final QuranSettings? settings;
  final QuranAudioPlayer Function()? createAudioPlayer;

  @override
  State<SuratPage> createState() => _SuratPageState();
}

class _SuratPageState extends State<SuratPage> {
  static const Color _headerColor = AppPalette.primaryDark;
  static const Color _nameColor = AppPalette.primary;
  static const Color _highlightColor = AppPalette.lime;

  late final QuranReadingStore _reading =
      widget.readingStore ?? QuranReadingStore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _QuranTab _tab = _QuranTab.surah;

  @override
  void initState() {
    super.initState();
    context.read<SuratCubit>().getAllSurat();
    _reading.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _searchHint {
    switch (_tab) {
      case _QuranTab.surah:
        return 'Cari surah...';
      case _QuranTab.juz:
        return 'Cari juz...';
      case _QuranTab.bookmark:
        return 'Cari ayat yang ditandai...';
    }
  }

  bool _matches(String text) => text.toLowerCase().contains(_query);

  // Membuka halaman isi surat, opsional langsung ke ayat tertentu.
  void _openAyat(BuildContext context, SuratModel surat, {int ayat = 1}) {
    // AyatBloc dari provider di QuranTab diteruskan ke route isi surat.
    final ayatBloc = context.read<AyatBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: ayatBloc,
          child: AyatPage(
            surat: surat,
            initialAyat: ayat,
            settings: widget.settings,
            readingStore: widget.readingStore,
            createAudioPlayer: widget.createAudioPlayer,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _headerColor,
      body: Column(
        children: [
          Container(
            color: _headerColor,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              0,
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF7D2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: _headerColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _query = value.trim().toLowerCase()),
                          decoration: InputDecoration(
                            hintText: _searchHint,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TabItem(
                      label: 'Surah',
                      selected: _tab == _QuranTab.surah,
                      onTap: () => setState(() => _tab = _QuranTab.surah),
                    ),
                    _TabItem(
                      label: 'Juz',
                      selected: _tab == _QuranTab.juz,
                      onTap: () => setState(() => _tab = _QuranTab.juz),
                    ),
                    _TabItem(
                      label: 'Bookmark',
                      selected: _tab == _QuranTab.bookmark,
                      onTap: () => setState(() => _tab = _QuranTab.bookmark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: ColoredBox(
                color: Colors.white,
                child: BlocBuilder<SuratCubit, SuratState>(
                  builder: (context, state) {
                    if (state is SuratLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SuratLoaded) {
                      return ListenableBuilder(
                        listenable: _reading,
                        builder: (context, _) =>
                            _buildTab(context, state.listSurat),
                      );
                    }
                    if (state is SuratError) return _buildError(state.message);
                    return const Center(child: Text('Tidak ada data.'));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, List<SuratModel> all) {
    switch (_tab) {
      case _QuranTab.surah:
        return _buildSurahList(context, all);
      case _QuranTab.juz:
        return _buildJuzList(context, all);
      case _QuranTab.bookmark:
        return _buildBookmarkList(context, all);
    }
  }

  SuratModel? _suratByNomor(List<SuratModel> all, int nomor) {
    for (final surat in all) {
      if (surat.nomor == nomor) return surat;
    }
    return null;
  }

  // ---- Tab Surah -----------------------------------------------------------

  Widget _buildSurahList(BuildContext context, List<SuratModel> all) {
    final items = all
        .where((s) =>
            _query.isEmpty ||
            _matches(s.namaLatin) ||
            _matches(s.arti) ||
            '${s.nomor}' == _query)
        .toList();

    final lastRead = _reading.lastRead;
    final lastReadSurat =
        lastRead == null ? null : _suratByNomor(all, lastRead.suratNomor);
    final showLastRead = _query.isEmpty && lastRead != null && lastReadSurat != null;

    if (items.isEmpty) {
      return const Center(child: Text('Surah tidak ditemukan.'));
    }

    return ListView.builder(
      itemCount: items.length + (showLastRead ? 1 : 0),
      itemBuilder: (context, index) {
        if (showLastRead && index == 0) {
          return _LastReadCard(
            lastRead: lastRead,
            onTap: () => _openAyat(
              context,
              lastReadSurat,
              ayat: lastRead.ayatNomor,
            ),
          );
        }
        final surat = items[index - (showLastRead ? 1 : 0)];
        return Column(
          children: [
            _buildSuratItem(context, surat),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildSuratItem(BuildContext context, SuratModel surat) {
    final tempat =
        surat.tempatTurun == TempatTurun.MEKAH ? 'MEKKAH' : 'MADINAH';

    return InkWell(
      onTap: () => _openAyat(context, surat),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _NumberBadge(number: surat.nomor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surat.namaLatin,
                    style: const TextStyle(
                      color: _nameColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '(${surat.arti.toUpperCase()}) • $tempat • ${surat.jumlahAyat} AYAT',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              surat.nama,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: _nameColor,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Tab Juz -------------------------------------------------------------

  Widget _buildJuzList(BuildContext context, List<SuratModel> all) {
    final entries = quranJuzStart.where((juz) {
      if (_query.isEmpty) return true;
      final surat = _suratByNomor(all, juz.surat);
      return '${juz.juz}' == _query ||
          _matches('juz ${juz.juz}') ||
          (surat != null && _matches(surat.namaLatin));
    }).toList();

    if (entries.isEmpty) {
      return const Center(child: Text('Juz tidak ditemukan.'));
    }

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final juz = entries[index];
        final surat = _suratByNomor(all, juz.surat);

        return InkWell(
          onTap: surat == null
              ? null
              : () => _openAyat(context, surat, ayat: juz.ayat),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _NumberBadge(number: juz.juz),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juz ${juz.juz}',
                        style: const TextStyle(
                          color: _nameColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        surat == null
                            ? 'Surah ${juz.surat}, ayat ${juz.ayat}'
                            : 'Mulai dari ${surat.namaLatin} ayat ${juz.ayat}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Tab Bookmark --------------------------------------------------------

  Widget _buildBookmarkList(BuildContext context, List<SuratModel> all) {
    final bookmarks = _reading.bookmarks.where((b) {
      if (_query.isEmpty) return true;
      return _matches(b.suratNama) ||
          _matches(b.terjemahan) ||
          '${b.ayatNomor}' == _query;
    }).toList();

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bookmark_border_rounded,
                size: 56,
                color: AppPalette.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                _reading.bookmarks.isEmpty
                    ? 'Belum ada ayat yang ditandai'
                    : 'Tanda ayat tidak ditemukan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primaryDark,
                ),
              ),
              if (_reading.bookmarks.isEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  'Ketuk ikon tanda di samping nomor ayat untuk menyimpannya di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppPalette.textMuted),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        final surat = _suratByNomor(all, bookmark.suratNomor);

        return InkWell(
          onTap: surat == null
              ? null
              : () => _openAyat(context, surat, ayat: bookmark.ayatNomor),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded, color: _nameColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bookmark.suratNama} • Ayat ${bookmark.ayatNomor}',
                        style: const TextStyle(
                          color: _nameColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (bookmark.terjemahan.isNotEmpty)
                        Text(
                          bookmark.terjemahan,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _reading.removeBookmark(
                    bookmark.suratNomor,
                    bookmark.ayatNomor,
                  ),
                  tooltip: 'Hapus tanda',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppPalette.danger,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppPalette.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<SuratCubit>().getAllSurat(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 44),
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// Kartu "Terakhir dibaca" di bagian atas daftar surah (sesuai Figma).
class _LastReadCard extends StatelessWidget {
  const _LastReadCard({required this.lastRead, required this.onTap});

  final QuranLastRead lastRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppPalette.heroGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppPalette.softShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Terakhir dibaca',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      lastRead.suratNama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ayat No: ${lastRead.ayatNomor}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.auto_stories_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.primary, width: 2),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: AppPalette.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? _SuratPageState._highlightColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? _SuratPageState._highlightColor
                  : Colors.white70,
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
