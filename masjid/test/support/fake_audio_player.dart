import 'package:masjid/services/quran_audio.dart';

// Pemutar audio tiruan untuk pengujian: mencatat panggilan tanpa memakai plugin.
class FakeAudioPlayer extends QuranAudioPlayer {
  QuranAudioStatus _status = QuranAudioStatus.idle;
  String? lastUrl;
  int playCalls = 0;
  int pauseCalls = 0;

  @override
  QuranAudioStatus get status => _status;

  @override
  Duration get position => Duration.zero;

  @override
  Duration get duration => const Duration(minutes: 1);

  @override
  String? get errorMessage => null;

  @override
  Future<void> play(String url) async {
    playCalls++;
    lastUrl = url;
    _status = QuranAudioStatus.playing;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _status = QuranAudioStatus.paused;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {}
}
