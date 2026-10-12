import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/common/open_url.dart';
import 'package:masjid/common/waktu.dart';
import 'package:masjid/screens/dashboard/edukasi_form_page.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/edukasi_store.dart';
import 'package:masjid/widget/edukasi_thumb.dart';

// Detail materi pembelajaran. Artikel menampilkan isinya; video menampilkan
// gambar mini dan tombol "Tonton Video" yang membuka YouTube. Admin dapat
// mengubah atau menghapus materi.
class EdukasiDetailPage extends StatefulWidget {
  const EdukasiDetailPage({
    super.key,
    required this.itemId,
    this.store,
    this.openUrl,
  });

  final String itemId;

  // Dapat diganti saat pengujian; bawaannya EdukasiStore.instance.
  final EdukasiStore? store;

  // Dapat diganti saat pengujian; bawaannya membuka tautan di aplikasi lain.
  final Future<bool> Function(String url)? openUrl;

  @override
  State<EdukasiDetailPage> createState() => _EdukasiDetailPageState();
}

class _EdukasiDetailPageState extends State<EdukasiDetailPage> {
  late final EdukasiStore _store = widget.store ?? EdukasiStore.instance;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openVideo(EdukasiItem item) async {
    final url = item.videoUrl;
    if (url == null) return;

    final opened = await (widget.openUrl ?? openWebUrl)(url);
    if (opened) return;
    if (!mounted) return;
    _snack('Video tidak dapat dibuka. Pastikan ada aplikasi YouTube atau peramban.');
  }

  Future<void> _openFile(EdukasiItem item) async {
    final url = item.fileUrl;
    if (url == null) return;

    final opened = await (widget.openUrl ?? openWebUrl)(url);
    if (opened) return;
    if (!mounted) return;
    _snack('Berkas tidak dapat dibuka. Pastikan ada aplikasi pembaca berkas atau peramban.');
  }

  Future<void> _edit(EdukasiItem item) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EdukasiFormPage(store: _store, existing: item),
      ),
    );
    if (saved != true) return;
    if (!mounted) return;
    _snack('Perubahan disimpan.');
  }

  Future<void> _delete(EdukasiItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus materi?'),
        content: Text('"${item.judul}" akan dihapus dari daftar materi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppPalette.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    // Pesan ditampilkan di halaman daftar, jadi ambil messenger sebelum menutup.
    final messenger = ScaffoldMessenger.of(context);
    final removal = _store.remove(item.id);
    Navigator.pop(context);
    final removed = await removal;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(removed
            ? 'Materi dihapus.'
            : (_store.writeError ?? 'Materi tidak dapat dihapus.')),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final admin = AuthSession.canManageContent;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _store,
            builder: (context, _) {
              final item = _store.byId(widget.itemId);

              return Column(
                children: [
                  _buildHeader(item, admin),
                  Expanded(
                    child: item == null
                        ? const Center(child: Text('Materi tidak ditemukan.'))
                        : _buildContent(item),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(EdukasiItem? item, bool admin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppPalette.primaryDark,
            ),
          ),
          const Spacer(),
          if (admin && item != null) ...[
            IconButton(
              onPressed: () => _edit(item),
              tooltip: 'Ubah materi',
              icon: const Icon(
                Icons.edit_outlined,
                color: AppPalette.primaryDark,
              ),
            ),
            IconButton(
              onPressed: () => _delete(item),
              tooltip: 'Hapus materi',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppPalette.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHero(EdukasiItem item) {
    // Gambar bawaan berupa kartu utuh, jadi ditampilkan sebagai kotak foto.
    if (item.coverAsset != null) {
      return Center(
        child: Hero(
          tag: 'edukasi-${item.id}',
          child: EdukasiThumb(item: item, width: 200, height: 200),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final hero = Hero(
          tag: 'edukasi-${item.id}',
          child: EdukasiThumb(
            item: item,
            width: width,
            height: width * 9 / 16,
            largeVideoThumb: true,
          ),
        );
        if (!item.isVideo) return hero;
        return InkWell(
          onTap: () => _openVideo(item),
          borderRadius: BorderRadius.circular(width * 9 / 16 * 0.15),
          child: hero,
        );
      },
    );
  }

  Widget _buildContent(EdukasiItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(item),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Tag(label: item.kategori),
              _Tag(
                label: item.isVideo ? 'Video' : 'Artikel',
                icon: item.isVideo
                    ? Icons.play_circle_outline
                    : Icons.article_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.judul,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppPalette.primaryDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Oleh ${item.penulis} • ${waktuRelatif(item.createdAt)}',
            style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
          ),
          if (item.isVideo && item.videoUrl != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openVideo(item),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Tonton Video',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (!item.isVideo && item.fileUrl != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openFile(item),
              icon: const Icon(Icons.description_outlined),
              label: const Text(
                'Buka Berkas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (item.isi.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Text(
                item.isi,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: AppPalette.textDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppPalette.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppPalette.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}
