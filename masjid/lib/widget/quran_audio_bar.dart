import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/services/quran_audio.dart';

// Format durasi: mm:ss, atau h:mm:ss jika lebih dari satu jam.
String formatAudioDuration(Duration value) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = value.inHours;
  final minutes = value.inMinutes.remainder(60);
  final seconds = value.inSeconds.remainder(60);
  return hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '${two(minutes)}:${two(seconds)}';
}

// Nama qari dari alamat audio, mis. ".../audio-full/Misyari-Rasyid-Al-Afasi/001.mp3".
String? qariFromAudioUrl(String url) {
  final match = RegExp(r'audio-full/([^/]+)/').firstMatch(url);
  if (match == null) return null;
  return match
      .group(1)!
      .replaceAll('-', ' ')
      .replaceAllMapped(RegExp(r'\bAl (?=[A-Z])'), (_) => 'Al-');
}

// Bilah pemutar bacaan surah di bagian bawah halaman ayat: tombol putar/jeda,
// penggeser posisi, dan durasi.
class QuranAudioBar extends StatefulWidget {
  const QuranAudioBar({
    super.key,
    required this.player,
    required this.url,
    required this.title,
  });

  final QuranAudioPlayer player;
  final String url;
  final String title;

  @override
  State<QuranAudioBar> createState() => _QuranAudioBarState();
}

class _QuranAudioBarState extends State<QuranAudioBar> {
  // Posisi sementara saat penggeser sedang diseret (milidetik).
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final qari = qariFromAudioUrl(widget.url);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppPalette.softShadow,
          ),
          child: ListenableBuilder(
            listenable: widget.player,
            builder: (context, _) {
              final player = widget.player;
              final status = player.status;
              final total = player.duration.inMilliseconds.toDouble();
              final current =
                  _dragMs ?? player.position.inMilliseconds.toDouble();
              final value =
                  total <= 0 ? 0.0 : current.clamp(0.0, total).toDouble();

              return Row(
                children: [
                  _PlayButton(
                    status: status,
                    onPressed: () => status == QuranAudioStatus.playing
                        ? player.pause()
                        : player.play(widget.url),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qari == null
                              ? widget.title
                              : '${widget.title} • $qari',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primaryDark,
                          ),
                        ),
                        if (status == QuranAudioStatus.error)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              player.errorMessage ??
                                  'Audio tidak dapat diputar.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppPalette.danger,
                              ),
                            ),
                          )
                        else ...[
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: AppPalette.primary,
                              thumbColor: AppPalette.primary,
                              inactiveTrackColor:
                                  AppPalette.primary.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: value,
                              max: total > 0 ? total : 1,
                              onChanged: total > 0
                                  ? (v) => setState(() => _dragMs = v)
                                  : null,
                              onChangeEnd: (v) async {
                                await player
                                    .seek(Duration(milliseconds: v.round()));
                                if (mounted) setState(() => _dragMs = null);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatAudioDuration(
                                  Duration(milliseconds: value.round()),
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppPalette.textMuted,
                                ),
                              ),
                              Text(
                                formatAudioDuration(player.duration),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppPalette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.status, required this.onPressed});

  final QuranAudioStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loading = status == QuranAudioStatus.loading;
    final playing = status == QuranAudioStatus.playing;

    return Material(
      color: AppPalette.primary,
      shape: const CircleBorder(),
      child: InkWell(
        // Saat memuat, ketukan diabaikan agar tidak memulai pemuatan ganda.
        onTap: loading ? null : onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ),
      ),
    );
  }
}
