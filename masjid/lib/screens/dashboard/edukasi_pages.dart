import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/common/waktu.dart';
import 'package:masjid/screens/dashboard/edukasi_detail_page.dart';
import 'package:masjid/screens/dashboard/edukasi_form_page.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/edukasi_store.dart';
import 'package:masjid/widget/edukasi_thumb.dart';

// Halaman Edukasi: materi pembelajaran Islam (artikel dan video) untuk
// anak-anak, remaja, dan orang tua. Semua pengguna dapat membaca dan menonton;
// admin juga dapat menambah materi (tombol Tambah) dan menghapusnya dengan
// menggeser kartu ke kanan.
class EdukasiWidget extends StatefulWidget {
  const EdukasiWidget({super.key, this.store});

  // Dapat diganti saat pengujian; bawaannya EdukasiStore.instance.
  final EdukasiStore? store;

  @override
  State<EdukasiWidget> createState() => _EdukasiWidgetState();
}

class _EdukasiWidgetState extends State<EdukasiWidget> {
  late final EdukasiStore _store = widget.store ?? EdukasiStore.instance;
  int _selected = 0;

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

  Future<void> _addItem() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EdukasiFormPage(
          store: _store,
          initialKategori: edukasiKategori[_selected],
        ),
      ),
    );
    if (saved != true) return;
    if (!mounted) return;
    _snack('Materi berhasil disimpan.');
  }

  Future<bool> _confirmDelete(EdukasiItem item) async {
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
    return confirmed ?? false;
  }

  void _openDetail(EdukasiItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EdukasiDetailPage(itemId: item.id, store: _store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = AuthSession.canManageContent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: _addItem,
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah materi'),
            )
          : null,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Edukasi Muslim',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primaryDark,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Artikel dan video belajar Islam untuk semua usia',
                  style: TextStyle(fontSize: 13, color: AppPalette.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: edukasiKategori.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => _CategoryChip(
                    label: edukasiKategori[index],
                    selected: index == _selected,
                    onTap: () => setState(() => _selected = index),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListenableBuilder(
                  listenable: _store,
                  builder: (context, _) {
                    final items =
                        _store.byKategori(edukasiKategori[_selected]);
                    if (_store.loading && _store.items.isEmpty) {
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
                            EdgeInsets.fromLTRB(16, 8, 16, admin ? 96 : 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    );
  }

  Widget _buildItem(EdukasiItem item, bool admin) {
    final card = _EdukasiCard(item: item, onTap: () => _openDetail(item));
    if (!admin) return card;

    // Geser ke kanan memperlihatkan latar merah berikon tempat sampah.
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
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 32),
      ),
      confirmDismiss: (_) => _confirmDelete(item),
      onDismissed: (_) async {
        final removed = await _store.remove(item.id);
        if (!mounted) return;
        _snack(removed
            ? 'Materi dihapus.'
            : (_store.writeError ?? 'Materi tidak dapat dihapus.'));
      },
      child: card,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? AppPalette.softShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppPalette.textMuted,
          ),
        ),
      ),
    );
  }
}

class _EdukasiCard extends StatelessWidget {
  const _EdukasiCard({required this.item, required this.onTap});

  final EdukasiItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Hero(
              tag: 'edukasi-${item.id}',
              child: EdukasiThumb(item: item, width: 96, height: 96),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primaryDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 9,
                        backgroundColor: AppPalette.primary,
                        child: Icon(Icons.person, size: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${item.penulis} • ${waktuRelatif(item.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppPalette.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.isVideo) ...[
                    const SizedBox(height: 6),
                    const _VideoBadge(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppPalette.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, size: 13, color: AppPalette.primary),
          SizedBox(width: 4),
          Text(
            'Video',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
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
              Icons.menu_book_outlined,
              size: 56,
              color: AppPalette.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada materi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPalette.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              admin
                  ? 'Ketuk Tambah materi untuk menambahkan artikel atau video.'
                  : 'Materi pada kategori ini akan tampil di sini.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
