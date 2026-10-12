import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid/bloc/ayat/ayat_bloc.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/data/models/surat_detail_model.dart';
import 'package:masjid/data/models/surat_model.dart';
import 'package:masjid/services/quran_audio.dart';
import 'package:masjid/services/quran_reading_store.dart';
import 'package:masjid/services/quran_settings.dart';
import 'package:masjid/widget/quran_audio_bar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// Isi surat (sesuai Figma "Surah"): ayat dalam Arab, transliterasi, dan
// terjemahan. Sesuai rancangan skripsi, tulisan dapat diperbesar (zoom in),
// bacaan surah dapat diputar sebagai suara, dan terjemahan Indonesia tersedia.
// Ayat dapat ditandai (bookmark), dan posisi bacaan terakhir diingat.
class AyatPage extends StatefulWidget {
  const AyatPage({
    super.key,
    required this.surat,
    this.initialAyat = 1,
    this.settings,
    this.readingStore,
    this.createAudioPlayer,
  });

  final SuratModel surat;

  // Ayat yang langsung ditampilkan (mis. dari tab Juz atau Bookmark).
  final int initialAyat;

  // Dapat diganti saat pengujian; bawaannya memakai instance bersama.
  final QuranSettings? settings;
  final QuranReadingStore? readingStore;

  // Dapat diganti saat pengujian; bawaannya pemutar just_audio.
  final QuranAudioPlayer Function()? createAudioPlayer;

  @override
  State<AyatPage> createState() => _AyatPageState();
}

class _AyatPageState extends State<AyatPage> {
  static const Color _headerColor = AppPalette.primaryDark;
  static const Color _highlightColor = AppPalette.lime;

  late final QuranSettings _settings =
      widget.settings ?? QuranSettings.instance;
  late final QuranReadingStore _reading =
      widget.readingStore ?? QuranReadingStore.instance;
  late final QuranAudioPlayer _audio;

  final ItemPositionsListener _positions = ItemPositionsListener.create();
  Timer? _saveTimer;
  Timer? _highlightTimer;
  int? _visibleAyat;
  int? _highlightAyat;
  bool _listShown = false;

  @override
  void initState() {
    super.initState();
    final createAudioPlayer =
        widget.createAudioPlayer ?? () => JustAudioQuranPlayer();
    _audio = createAudioPlayer();
    _settings.load();
    _reading.load();
    _positions.itemPositions.addListener(_onPositionsChanged);
    _loadAyat();
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onPositionsChanged);
    _saveTimer?.cancel();
    _highlightTimer?.cancel();
    // Simpan posisi terakhir sebelum halaman ditutup. Ditunda ke microtask
    // karena memberi tahu pendengar saat dispose dilarang (pohon widget terkunci).
    final last = _currentLastRead();
    if (last != null) {
      final store = _reading;
      Future.microtask(() => store.setLastRead(last));
    }
    // Bacaan berhenti saat halaman ditutup.
    _audio.dispose();
    super.dispose();
  }

  void _loadAyat() {
    context.read<AyatBloc>().add(AyatGetEvent(noSurat: widget.surat.nomor));
  }

  // Dipanggil sekali saat daftar ayat pertama kali tampil.
  void _onListShown(int ayatCount) {
    if (_listShown) return;
    _listShown = true;

    final start = widget.initialAyat.clamp(1, ayatCount);
    _visibleAyat = start;
    _saveLastRead();

    // Ayat tujuan disorot sebentar agar mudah ditemukan.
    if (start > 1) {
      _highlightAyat = start;
      _highlightTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightAyat = null);
      });
      setState(() {});
    }
  }

  // Ayat paling atas yang masih terlihat dianggap posisi terakhir dibaca.
  void _onPositionsChanged() {
    final visible = _positions.itemPositions.value
        .where((position) => position.itemTrailingEdge > 0)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    if (visible.isEmpty) return;

    _visibleAyat = visible.first.index + 1;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _saveLastRead);
  }

  QuranLastRead? _currentLastRead() {
    final ayat = _visibleAyat;
    if (ayat == null) return null;
    return QuranLastRead(
      suratNomor: widget.surat.nomor,
      suratNama: widget.surat.namaLatin,
      ayatNomor: ayat,
    );
  }

  void _saveLastRead() {
    final last = _currentLastRead();
    if (last != null) _reading.setLastRead(last);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleBookmark(Ayat ayat) async {
    final result = await _reading.toggleBookmark(
      QuranBookmark(
        suratNomor: widget.surat.nomor,
        suratNama: widget.surat.namaLatin,
        ayatNomor: ayat.nomor ?? 0,
        teksArab: ayat.ar ?? '',
        terjemahan: ayat.idn ?? '',
      ),
    );
    if (!mounted) return;

    switch (result) {
      case BookmarkResult.added:
        _snack('Ayat ditandai. Lihat di tab Bookmark.');
      case BookmarkResult.removed:
        _snack('Tanda ayat dihapus.');
      case BookmarkResult.limitReached:
        _snack(
          'Batas ${QuranReadingStore.maxBookmarks} tanda tercapai. '
          'Hapus beberapa tanda lama terlebih dahulu.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final surat = widget.surat;
    final tempat =
        surat.tempatTurun == TempatTurun.MEKAH ? 'MEKKAH' : 'MADINAH';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: _headerColor,
        foregroundColor: Colors.white,
        toolbarHeight: 96,
        title: Column(
          children: [
            Text(
              surat.nama,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: _highlightColor, fontSize: 26),
            ),
            Text(
              surat.namaLatin,
              style: const TextStyle(
                color: _highlightColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '(${surat.arti.toUpperCase()}) • $tempat • ${surat.jumlahAyat} AYAT',
              style: const TextStyle(color: _highlightColor, fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: BlocBuilder<AyatBloc, AyatState>(
              builder: (context, state) {
                // AyatBloc dipakai bersama; abaikan data surat lain yang
                // masih tersisa sampai surat ini selesai dimuat.
                if (state is AyatLoaded &&
                    state.detail.nomor == widget.surat.nomor) {
                  return _buildAyatList(state.detail);
                }
                if (state is AyatError) return _buildError();
                if (state is AyatInitial) {
                  return const Center(child: Text('Tidak ada data.'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<AyatBloc, AyatState>(
        builder: (context, state) {
          final audioUrl = state is AyatLoaded &&
                  state.detail.nomor == widget.surat.nomor
              ? state.detail.audio
              : null;
          if (audioUrl == null || audioUrl.isEmpty) {
            return const SizedBox.shrink();
          }
          return QuranAudioBar(
            player: _audio,
            url: audioUrl,
            title: 'Bacaan ${surat.namaLatin}',
          );
        },
      ),
    );
  }

  // Pilihan mode layar dan pengatur ukuran huruf (zoom).
  Widget _buildControls() {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5EFD1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<QuranViewMode>(
                    value: _settings.mode,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(14),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppPalette.primaryDark,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primaryDark,
                    ),
                    items: [
                      for (final mode in QuranViewMode.values)
                        DropdownMenuItem(value: mode, child: Text(mode.label)),
                    ],
                    onChanged: (mode) {
                      if (mode != null) _settings.setMode(mode);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _ZoomControl(settings: _settings),
          ],
        ),
      ),
    );
  }

  Widget _buildAyatList(SuratDetailModel detail) {
    final ayatList = detail.ayat ?? [];
    if (ayatList.isEmpty) {
      return const Center(child: Text('Ayat tidak tersedia.'));
    }

    // Pencatatan posisi dimulai setelah frame pertama selesai.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onListShown(ayatList.length);
    });

    return ListenableBuilder(
      listenable: Listenable.merge([_settings, _reading]),
      builder: (context, _) => ScrollablePositionedList.builder(
        itemPositionsListener: _positions,
        initialScrollIndex: (widget.initialAyat - 1).clamp(
          0,
          ayatList.length - 1,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: ayatList.length,
        itemBuilder: (context, index) {
          final ayat = ayatList[index];
          return _AyatCard(
            suratNomor: widget.surat.nomor,
            ayat: ayat,
            scale: _settings.fontScale,
            mode: _settings.mode,
            bookmarked: _reading.isBookmarked(
              widget.surat.nomor,
              ayat.nomor ?? 0,
            ),
            highlighted: _highlightAyat != null && _highlightAyat == ayat.nomor,
            onBookmark: () => _toggleBookmark(ayat),
          );
        },
      ),
    );
  }

  Widget _buildError() {
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
            const Text(
              'Ayat belum dapat dimuat.\nPeriksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAyat,
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

// Pengatur ukuran huruf: [-] 100% [+]. Rentang 80% sampai 200%.
class _ZoomControl extends StatelessWidget {
  const _ZoomControl({required this.settings});

  final QuranSettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppPalette.softShadow,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: settings.canZoomOut ? settings.zoomOut : null,
            tooltip: 'Perkecil huruf',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_rounded),
            color: AppPalette.primaryDark,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${(settings.fontScale * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryDark,
              ),
            ),
          ),
          IconButton(
            onPressed: settings.canZoomIn ? settings.zoomIn : null,
            tooltip: 'Perbesar huruf',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_rounded),
            color: AppPalette.primaryDark,
          ),
        ],
      ),
    );
  }
}

class _AyatCard extends StatelessWidget {
  const _AyatCard({
    required this.suratNomor,
    required this.ayat,
    required this.scale,
    required this.mode,
    required this.bookmarked,
    required this.highlighted,
    required this.onBookmark,
  });

  // Ukuran dasar huruf (sebelum diperbesar/diperkecil).
  static const double _arabSize = 26;
  static const double _textSize = 13;

  final int suratNomor;
  final Ayat ayat;
  final double scale;
  final QuranViewMode mode;
  final bool bookmarked;
  final bool highlighted;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFFFFE9A0)
                  : const Color(0xFFE9E9E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppPalette.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${ayat.nomor}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onBookmark,
                  tooltip: bookmarked ? 'Hapus tanda ayat' : 'Tandai ayat',
                  icon: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: AppPalette.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${ayat.ar}',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: _arabSize * scale, height: 1.8),
          ),
          if (mode.showLatin) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$suratNomor:${ayat.nomor} ${ayat.tr ?? ''}',
                style: TextStyle(
                  color: AppPalette.primary,
                  fontSize: _textSize * scale,
                ),
              ),
            ),
          ],
          if (mode.showTranslation) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$suratNomor:${ayat.nomor} ${ayat.idn ?? ''}',
                style: TextStyle(fontSize: _textSize * scale),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
