import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/common/image_source_sheet.dart';
import 'package:masjid/common/youtube_link.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/edukasi_store.dart';
import 'package:masjid/widget/edukasi_thumb.dart';

// Formulir tambah/ubah materi Edukasi (khusus admin). Mengembalikan true
// lewat Navigator.pop jika materi berhasil disimpan.
class EdukasiFormPage extends StatefulWidget {
  const EdukasiFormPage({
    super.key,
    this.existing,
    this.store,
    this.initialKategori,
    this.pickCover,
  });

  // Materi yang diubah; null berarti menambah materi baru.
  final EdukasiItem? existing;

  // Dapat diganti saat pengujian; bawaannya EdukasiStore.instance.
  final EdukasiStore? store;

  final String? initialKategori;

  // Dapat diganti saat pengujian; bawaannya memilih dari galeri/kamera.
  final Future<Uint8List?> Function()? pickCover;

  @override
  State<EdukasiFormPage> createState() => _EdukasiFormPageState();
}

class _EdukasiFormPageState extends State<EdukasiFormPage> {
  late final EdukasiStore _store = widget.store ?? EdukasiStore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;
  late final TextEditingController _videoController;

  late EdukasiType _tipe;
  late String _kategori;
  Uint8List? _coverBytes;
  String? _coverAsset;
  String? _coverUrl;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  // Server tidak mengizinkan mengubah jenis materi yang sudah ada.
  bool get _typeLocked => _editing && _store.remote;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _judulController = TextEditingController(text: existing?.judul ?? '');
    _isiController = TextEditingController(text: existing?.isi ?? '');
    _videoController = TextEditingController(text: existing?.videoUrl ?? '');
    _tipe = existing?.tipe ?? EdukasiType.artikel;
    final choices = _store.kategoriChoices;
    _kategori = choices.contains(existing?.kategori)
        ? existing!.kategori
        : (choices.contains(widget.initialKategori)
            ? widget.initialKategori!
            : choices.first);
    _coverBytes = existing?.coverBytes;
    _coverAsset = existing?.coverAsset;
    _coverUrl = existing?.coverUrl;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Uint8List?> _pickFromDevice() async {
    final source = await showImageSourceSheet(
      context,
      title: 'Pilih gambar sampul',
    );
    if (source == null) return null;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 900,
      imageQuality: 70,
    );
    return picked?.readAsBytes();
  }

  Future<void> _chooseCover() async {
    try {
      final bytes = await (widget.pickCover ?? _pickFromDevice)();
      if (bytes == null) return;
      if (!mounted) return;
      setState(() {
        _coverBytes = bytes;
        _coverAsset = null;
      });
    } catch (_) {
      if (!mounted) return;
      _snack('Gambar tidak dapat diambil. Periksa izin kamera atau galeri.');
    }
  }

  void _removeCover() {
    setState(() {
      _coverBytes = null;
      _coverAsset = null;
    });
  }

  String? _validateJudul(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Judul wajib diisi';
    if (text.length < 5) return 'Judul minimal 5 karakter';
    return null;
  }

  String? _validateIsi(String? value) {
    if (_tipe == EdukasiType.video) return null;
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Isi artikel wajib diisi';
    if (text.length < 20) return 'Isi artikel minimal 20 karakter';
    return null;
  }

  String? _validateVideo(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Tautan video wajib diisi';
    // Tautan lama yang tidak diubah tetap diterima.
    if (text == widget.existing?.videoUrl) return null;
    if (youtubeVideoId(text) == null) {
      return 'Masukkan tautan video YouTube yang valid, mis. https://youtu.be/xxxxxxxxxxx';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final existing = widget.existing;
    final isVideo = _tipe == EdukasiType.video;
    final item = EdukasiItem(
      id: existing?.id ?? _store.newId(),
      judul: _judulController.text.trim(),
      kategori: _kategori,
      tipe: _tipe,
      penulis: existing?.penulis ?? AuthSession.current?.roleLabel ?? 'Admin Masjid',
      createdAt: existing?.createdAt ?? DateTime.now(),
      isi: _isiController.text.trim(),
      videoUrl: isVideo ? _videoController.text.trim() : null,
      coverAsset: isVideo ? null : _coverAsset,
      coverBytes: isVideo ? null : _coverBytes,
    );

    final saved =
        _editing ? await _store.update(item) : await _store.add(item);
    if (!mounted) return;
    setState(() => _saving = false);

    if (saved) {
      Navigator.pop(context, true);
    } else {
      _snack(
        _store.writeError ??
            'Materi tidak dapat disimpan. Penyimpanan perangkat penuh atau '
                'jumlah materi sudah mencapai ${EdukasiStore.maxItems}.',
      );
    }
  }

  // Materi sementara untuk pratinjau gambar sampul.
  EdukasiItem _previewItem() {
    return EdukasiItem(
      id: 'preview',
      judul: '',
      kategori: _kategori,
      tipe: _tipe,
      penulis: '',
      createdAt: DateTime.now(),
      videoUrl: _videoController.text.trim(),
      coverAsset: _tipe == EdukasiType.video ? null : _coverAsset,
      coverBytes: _tipe == EdukasiType.video ? null : _coverBytes,
      coverUrl: _tipe == EdukasiType.video || _coverBytes != null
          ? null
          : _coverUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _tipe == EdukasiType.video;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jenis materi',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppPalette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              _TypeChip(
                                label: 'Artikel',
                                icon: Icons.article_outlined,
                                selected: !isVideo,
                                onTap: _typeLocked
                                    ? null
                                    : () => setState(
                                          () => _tipe = EdukasiType.artikel,
                                        ),
                              ),
                              _TypeChip(
                                label: 'Video',
                                icon: Icons.play_circle_outline,
                                selected: isVideo,
                                onTap: _typeLocked
                                    ? null
                                    : () => setState(
                                          () => _tipe = EdukasiType.video,
                                        ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _kategori,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                            ),
                            items: [
                              for (final kategori in _store.kategoriChoices)
                                DropdownMenuItem(
                                  value: kategori,
                                  child: Text(kategori),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _kategori = value ?? _kategori),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _judulController,
                            maxLength: 90,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: _validateJudul,
                            decoration: const InputDecoration(
                              labelText: 'Judul',
                            ),
                          ),
                          if (isVideo) ...[
                            TextFormField(
                              controller: _videoController,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() {}),
                              validator: _validateVideo,
                              decoration: const InputDecoration(
                                labelText: 'Tautan video YouTube',
                                hintText: 'https://youtu.be/...',
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (youtubeVideoId(_videoController.text) != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: EdukasiThumb(
                                  item: _previewItem(),
                                  width: 160,
                                  height: 90,
                                ),
                              ),
                          ],
                          TextFormField(
                            controller: _isiController,
                            minLines: isVideo ? 2 : 5,
                            maxLines: 12,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            validator: _validateIsi,
                            decoration: InputDecoration(
                              labelText:
                                  isVideo ? 'Deskripsi (opsional)' : 'Isi artikel',
                              alignLabelWithHint: true,
                            ),
                          ),
                          if (!isVideo) ...[
                            const SizedBox(height: 16),
                            _buildCoverPicker(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          Expanded(
            child: Text(
              _editing ? 'Ubah Materi' : 'Tambah Materi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
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

  Widget _buildCoverPicker() {
    final canRemove = _coverBytes != null || _coverAsset != null;
    final hasCover = canRemove || _coverUrl != null;

    return Row(
      children: [
        if (hasCover) ...[
          EdukasiThumb(item: _previewItem(), width: 80, height: 80),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _chooseCover,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(hasCover ? 'Ganti gambar' : 'Pilih gambar sampul'),
              ),
              if (canRemove)
                TextButton(
                  onPressed: _removeCover,
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: AppPalette.danger),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? Colors.white : AppPalette.textMuted,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppPalette.textMuted,
      ),
      selected: selected,
      selectedColor: AppPalette.primary,
      backgroundColor: Colors.white,
      showCheckmark: false,
      onSelected: onTap == null ? null : (_) => onTap!(),
    );
  }
}
