import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/screens/kegiatan/kegiatan_masjid_page.dart';
import 'package:masjid/services/banner_store.dart';
import 'package:masjid/services/kegiatan_store.dart';
import 'package:masjid/services/masjid_store.dart';
import 'package:masjid/services/profile_store.dart';
import 'package:masjid/widget/banner_carousel.dart';
import 'package:masjid/widget/hero_clock_card.dart';
import 'package:masjid/widget/kegiatan_image.dart';
import 'package:masjid/widget/prayer_times_row.dart';

// Beranda (sesuai Figma "beranda"): header masjid, jam, jadwal sholat,
// banner kegiatan, dan Kegiatan Masjid.
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, this.onOpenProfile});

  // Dipanggil saat foto profil di header diketuk.
  final VoidCallback? onOpenProfile;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final MasjidStore _masjidStore = MasjidStore.instance;
  final BannerStore _bannerStore = BannerStore.instance;
  final KegiatanStore _kegiatan = KegiatanStore.instance;

  int _selectedMasjid = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  // Memuat daftar masjid dan banner, lalu kegiatan masjid terpilih. Dengan
  // [reload] semuanya diminta ulang (tombol "Coba lagi").
  Future<void> _start({bool reload = false}) async {
    final banners = reload ? _bannerStore.reload() : _bannerStore.load();
    await (reload ? _masjidStore.reload() : _masjidStore.load());
    if (!mounted) return;
    _selectMasjid(_selectedMasjid.clamp(0, _masjidStore.masjids.length - 1));
    await banners;
  }

  void _selectMasjid(int index) {
    setState(() => _selectedMasjid = index);
    _kegiatan.selectMasjid(_masjidStore.masjids[index].id);
  }

  void _openKegiatan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KegiatanMasjidPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        // Padding bawah MediaQuery = tinggi navigasi yang melayang (Dashboard),
        // supaya kartu terakhir bisa digulir sampai terlihat penuh.
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        child: ListenableBuilder(
          listenable: Listenable.merge([_masjidStore, _bannerStore]),
          builder: (context, _) {
            final masjids = _masjidStore.masjids;
            final selected = _selectedMasjid.clamp(0, masjids.length - 1);
            final banners = _bannerStore.images;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(masjids[selected]),
                const SizedBox(height: 16),
                HeroClockCard(
                  masjids: masjids,
                  selectedIndex: selected,
                  onSelected: _selectMasjid,
                ),
                const SizedBox(height: 16),
                const PrayerTimesRow(),
                const SizedBox(height: 12),
                if (banners.isNotEmpty) ...[
                  BannerCarousel(
                    key: ValueKey(banners.join('|')),
                    images: banners,
                  ),
                  const SizedBox(height: 12),
                ],
                _buildKegiatan(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(MasjidInfo masjid) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppPalette.primaryDark,
          size: 28,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                masjid.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primaryDark,
                ),
              ),
              Text(
                masjid.kecamatanLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ListenableBuilder(
          listenable: ProfileStore.instance,
          builder: (context, _) {
            final photo = ProfileStore.instance.photoImage;
            return InkWell(
              onTap: widget.onOpenProfile,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE3EEE6),
                  backgroundImage: photo,
                  onBackgroundImageError: photo == null ? null : (_, __) {},
                  child: photo == null
                      ? const Icon(
                          Icons.person,
                          color: AppPalette.textMuted,
                          size: 28,
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Menampilkan poster kegiatan terbaru; "Lihat lainnya" membuka daftar lengkap.
  Widget _buildKegiatan() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Expanded: judul menyempit (elipsis) pada layar sempit atau huruf
              // besar, bukan membuat baris meluap.
              const Expanded(
                child: Text(
                  'Kegiatan Masjid',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primaryDark,
                  ),
                ),
              ),
              InkWell(
                onTap: _openKegiatan,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'Lihat lainnya',
                        style: TextStyle(fontSize: 12, color: AppPalette.link),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppPalette.link,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: _kegiatan,
            builder: (context, _) {
              final items = _kegiatan.items;
              if (items.isEmpty) {
                if (_kegiatan.loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final error = _kegiatan.error;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          error ?? 'Belum ada kegiatan.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppPalette.textMuted),
                        ),
                        if (error != null)
                          TextButton.icon(
                            onPressed: () => _start(reload: true),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba lagi'),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return InkWell(
                onTap: _openKegiatan,
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.92,
                    child: KegiatanImage(kegiatan: items.first),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
