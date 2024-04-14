import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Кубит для управления состоянием аудио плеера
class AudioCubit extends Cubit<AudioPlayerState> {
  late AudioPlayer _audioPlayer;
  StreamSubscription? _playerSubscription;

  AudioCubit() : super(AudioPlayerState.initial) {
    _audioPlayer = AudioPlayer();
    _init();
  }

  void _init() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _audioPlayer.setSource(AssetSource('audio/background_music.mp3'));
      await _audioPlayer.resume();
    });

    _playerSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          emit(AudioPlayerState.playing);
          break;
        case PlayerState.paused:
          emit(AudioPlayerState.paused);
          break;
        case PlayerState.stopped:
          emit(AudioPlayerState.stopped);
          break;
        case PlayerState.completed:
          emit(AudioPlayerState.completed);
          break;
        default:
          emit(AudioPlayerState.stopped);
          break;
      }
    });
  }

  Future<void> play() async {
    await _audioPlayer.resume();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  @override
  Future<void> close() {
    _playerSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}

// Enum для состояния аудио плеера
enum AudioPlayerState { initial, playing, paused, stopped, completed }
