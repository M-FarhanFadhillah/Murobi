import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjid/common/app_theme.dart';

// Lembar pilihan sumber gambar (sesuai Figma "Ubah foto profil"):
// Galeri foto, Ambil foto, atau Kembali. Mengembalikan null jika dibatalkan.
Future<ImageSource?> showImageSourceSheet(
  BuildContext context, {
  required String title,
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      title,
                      style: const TextStyle(color: AppPalette.textMuted),
                    ),
                  ),
                  const Divider(height: 1),
                  _SheetAction(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeri foto',
                    onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                  ),
                  const Divider(height: 1),
                  _SheetAction(
                    icon: Icons.photo_camera_outlined,
                    label: 'Ambil foto',
                    onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.link,
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

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppPalette.link, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: AppPalette.link)),
          ],
        ),
      ),
    );
  }
}
