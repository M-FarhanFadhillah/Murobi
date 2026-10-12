import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum QuranAudioStatus { idle, loading, playing, paused, error }

// Pemutar bacaan surah. Dibuat sebagai antarmuka supaya tampilan dapat diuji
// tanpa plugin audio.
abstract class QuranAudioPlayer extends ChangeNotifier {
  QuranAudioStatus get status;

  Duration get position;

  Duration get duration;

  String? get errorMessage;

  // Memutar [url]. Jika url yang sama sudah dimuat, melanjutkan pemutaran.
  Future<void> play(String url);

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> stop();
}

// Implementasi dengan just_audio: audio diputar streaming dari server.
class JustAudioQuranPlayer extends QuranAudioPlayer {
  JustAudioQuranPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    _subscriptions.addAll([
      _player.playerStateStream.listen(
        _onPlayerState,
        onError: (Object error) => _fail(),
      ),
      _player.positionStream.listen((value) {
        _position = value;
        _notify();
      }),
      _player.durationStream.listen((value) {
        _duration = value ?? Duration.zero;
        _notify();
      }),
    ]);
  }

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  QuranAudioStatus _status = QuranAudioStatus.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;
  String? _loadedUrl;
  bool _disposed = false;

  @override
  QuranAudioStatus get status => _status;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  String? get errorMessage => _errorMessage;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _onPlayerState(PlayerState state) {
    final processing = state.processingState;

    if (processing == ProcessingState.completed) {
      // Selesai: kembali ke awal agar bisa diputar ulang.
      _status = QuranAudioStatus.idle;
      _position = Duration.zero;
      _player.pause();
      _player.seek(Duration.zero);
    } else if (processing == ProcessingState.loading ||
        processing == ProcessingState.buffering) {
      _status = QuranAudioStatus.loading;
    } else if (processing == ProcessingState.idle) {
      if (_status != QuranAudioStatus.error &&
          _status != QuranAudioStatus.loading) {
        _status = QuranAudioStatus.idle;
      }
    } else if (_status != QuranAudioStatus.error) {
      _status =
          state.playing ? QuranAudioStatus.playing : QuranAudioStatus.paused;
    }
    _notify();
  }

  void _fail() {
    _status = QuranAudioStatus.error;
    _errorMessage = 'Audio tidak dapat diputar. Periksa koneksi internet.';
    _loadedUrl = null;
    _notify();
  }

  @override
  Future<void> play(String url) async {
    try {
      if (_loadedUrl != url) {
        _errorMessage = null;
        _status = QuranAudioStatus.loading;
        _notify();
        await _player.setUrl(url);
        _loadedUrl = url;
      }
      // Future play() baru selesai saat pemutaran berhenti, jadi tidak ditunggu.
      unawaited(_player.play().catchError((Object error) => _fail()));
    } catch (_) {
      _fail();
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    _loadedUrl = null;
    _position = Duration.zero;
    _status = QuranAudioStatus.idle;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}
