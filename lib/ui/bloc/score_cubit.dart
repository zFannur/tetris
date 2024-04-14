import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreCubit extends Cubit<int> {

  ScoreCubit() : super(0);

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final highScore = prefs.getInt('highScore') ?? 0;
    emit(highScore);
  }

  void incrementScore(int linesCleared) async {
    int points = linesCleared * 100;
    int newScore = state + points;
    emit(newScore);
    await _saveHighScore(newScore);
  }

  Future<void> _saveHighScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    int highScore = prefs.getInt('highScore') ?? 0;
    if (newScore > highScore) {
      await prefs.setInt('highScore', newScore);
    }
  }

  Future<void> clearHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('highScore');
    emit(0); // Установить счёт в 0
  }

  Future<void> resetScore() async {
    emit(0); // Установить счёт в 0 при начале новой игры
  }
}