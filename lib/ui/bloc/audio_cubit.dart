import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioCubit extends Cubit<bool> with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  late SharedPreferences _prefs;

  AudioCubit() : super(true) {
    _init();
  }

  Future<void> _init() async {
    _audioPlayer = AudioPlayer();
    _prefs = await SharedPreferences.getInstance();
    WidgetsBinding.instance.addObserver(this); // Добавляем observer для жизненного цикла

    bool shouldPlayMusic = _prefs.getBool('shouldPlayMusic') ?? true;
    emit(shouldPlayMusic); // Устанавливаем начальное состояние воспроизведения

    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    if (shouldPlayMusic) {
      await _audioPlayer.setSource(AssetSource('audio/background_music.mp3'));
      await _audioPlayer.resume();
    }
  }

  Future<void> toggleMusicPlayback() async {
    bool currentSetting = state;
    if (currentSetting) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    await _prefs.setBool('shouldPlayMusic', !currentSetting);
    emit(!currentSetting);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed && this.state) {
      _audioPlayer.resume();
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    return super.close();
  }
}