import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/common/image_source_sheet.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/kegiatan_store.dart';
import 'package:masjid/widget/kegiatan_image.dart';

// Halaman Kegiatan Masjid (sesuai Figma). Semua pengguna dapat melihat daftar
// poster. Admin juga dapat mengunggah poster baru (tombol Unggah) dan
// menghapusnya dengan menggeser kartu ke kanan.
class KegiatanMasjidPage extends StatefulWidget {
  const KegiatanMasjidPage({super.key, this.store});

  // Dapat diganti saat pengujian; bawaannya KegiatanStore.instance.
  final KegiatanStore? store;

  @override
  State<KegiatanMasjidPage> createState() => _KegiatanMasjidPageState();
}

class _KegiatanMasjidPageState extends State<KegiatanMasjidPage> {
  // Rasio poster bawaan (2031 x 1056).
  static const double _posterRatio = 1.92;

  late final KegiatanStore _store = widget.store ?? KegiatanStore.instance;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _upload() async {
    if (!_store.canUploadMore) {
      _snack(
        'Batas ${KegiatanStore.maxUploads} poster unggahan tercapai. '
        'Hapus poster lama terlebih dahulu.',
      );
      return;
    }

    final source = await showImageSourceSheet(
      context,
      title: 'Unggah poster kegiatan',
    );
    if (source == null) return;
    if (!mounted) return;

    final Uint8List bytes;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1400,
        imageQuality: 75,
      );
      if (picked == null) return;
      bytes = await picked.readAsBytes();
    } catch (_) {
      if (!mounted) return;
      _snack('Gambar tidak dapat diambil. Periksa izin kamera atau galeri.');
      return;
    }
    if (!mounted) return;

    final judul = await showDialog<String>(
      context: context,
      builder: (_) => KegiatanUploadDialog(imageBytes: bytes),
    );
    if (judul == null) return;
    if (!mounted) return;

    setState(() => _uploading = true);
    final saved = await _store.add(judul, bytes);
    if (!mounted) return;
    setState(() => _uploading = false);
    _snack(
      saved
          ? 'Kegiatan berhasil diunggah.'
          : (_store.writeError ??
              'Penyimpanan perangkat penuh. Hapus poster lama lalu coba lagi.'),
    );
  }

  Future<bool> _confirmDelete(Kegiatan item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus kegiatan?'),
        content: Text('"${item.judul}" akan dihapus dari daftar kegiatan.'),
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
    return confirmed ?? false;
  }

  void _openViewer(Kegiatan item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KegiatanViewer(kegiatan: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = AuthSession.canManageContent;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (admin) _buildAdminHint(),
              Expanded(
                child: ListenableBuilder(
                  listenable: _store,
                  builder: (context, _) {
                    final items = _store.items;
                    if (_store.loading && items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (items.isEmpty) {
                      return _EmptyState(
                        admin: admin,
                        error: _store.error,
                        onRetry: _store.refresh,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _store.refresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            EdgeInsets.fromLTRB(16, 8, 16, admin ? 96 : 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) =>
                            _buildItem(items[index], admin),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: _uploading ? null : _upload,
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              icon: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(_uploading ? 'Mengunggah...' : 'Unggah'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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
          const Expanded(
            child: Text(
              'Kegiatan Masjid',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryDark,
              ),
            ),
          ),
          // Penyeimbang lebar tombol kembali agar judul tepat di tengah.
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAdminHint() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 18,
            color: AppPalette.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode admin: geser poster ke kanan untuk menghapus. '
              'Poster baru ditambahkan ke masjid yang dipilih di Beranda.',
              style: TextStyle(fontSize: 12, color: AppPalette.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Kegiatan item, bool admin) {
    final card = InkWell(
      onTap: () => _openViewer(item),
      borderRadius: BorderRadius.circular(20),
      child: AppCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: _posterRatio,
                child: KegiatanImage(kegiatan: item),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primaryDark,
                ),
              ),
            ),
            if (item.deskripsi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  item.deskripsi,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppPalette.textMuted,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 2),
          ],
        ),
      ),
    );

    if (!admin) return card;

    // Geser ke kanan memperlihatkan latar merah berikon tempat sampah (Figma).
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 28),
        decoration: BoxDecoration(
          color: AppPalette.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 36),
      ),
      confirmDismiss: (_) => _confirmDelete(item),
      onDismissed: (_) async {
        final removed = await _store.remove(item.id);
        if (!mounted) return;
        _snack(removed
            ? 'Kegiatan dihapus.'
            : (_store.writeError ?? 'Kegiatan tidak dapat dihapus.'));
      },
      child: card,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.admin, this.error, this.onRetry});

  final bool admin;

  // Pesan kegagalan memuat dari server (null jika tidak ada).
  final String? error;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: AppPalette.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppPalette.textMuted),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 56,
              color: AppPalette.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada kegiatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPalette.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              admin
                  ? 'Ketuk Unggah untuk menambahkan poster kegiatan.'
                  : 'Poster kegiatan masjid akan tampil di sini.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog untuk mengisi judul poster yang akan diunggah. Mengembalikan judul
// (sudah dirapikan), atau null jika dibatalkan.
class KegiatanUploadDialog extends StatefulWidget {
  const KegiatanUploadDialog({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<KegiatanUploadDialog> createState() => _KegiatanUploadDialogState();
}

class _KegiatanUploadDialogState extends State<KegiatanUploadDialog> {
  final TextEditingController _controller = TextEditingController();

  bool get _valid => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_valid) Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Unggah kegiatan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.92,
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFFE3EEE6),
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Judul kegiatan',
                helperText:
                    'Poster lanskap (rasio sekitar 2:1) tampil paling pas.',
                helperMaxLines: 2,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppPalette.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _valid ? _submit : null,
          style: FilledButton.styleFrom(backgroundColor: AppPalette.primary),
          child: const Text('Unggah'),
        ),
      ],
    );
  }
}

// Tampilan penuh poster: dapat dicubit untuk memperbesar.
class KegiatanViewer extends StatelessWidget {
  const KegiatanViewer({super.key, required this.kegiatan});

  final Kegiatan kegiatan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          kegiatan.judul,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: KegiatanImage(
            kegiatan: kegiatan,
            fit: BoxFit.contain,
            cacheWidth: 2000,
          ),
        ),
      ),
    );
  }
}
