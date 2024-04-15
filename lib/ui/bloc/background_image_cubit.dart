import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BackgroundImage {
  game,
  game1,
  game2,
  game3,
  game4,
  game5,
  game6,
  game7,
  game8,
}

class BackgroundImageCubit extends Cubit<BackgroundImage> {
  SharedPreferences? _prefs;

  BackgroundImageCubit() : super(BackgroundImage.game) {
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    _prefs = await SharedPreferences.getInstance();
    final String backgroundImageString = _prefs!.getString('backgroundImage') ?? 'game';
    emit(BackgroundImage.values.firstWhere(
          (element) => element.toString() == 'BackgroundImage.$backgroundImageString',
      orElse: () => BackgroundImage.game,
    ));
  }

  void changeBackground(BackgroundImage image) {
    _prefs?.setString('backgroundImage', image.toString().split('.').last);
    emit(image);
  }

  String getImagePath(BackgroundImage backgroundImage) {
    switch (backgroundImage) {
      case BackgroundImage.game:
        return 'assets/images/backgroundGame.jpg';
      case BackgroundImage.game1:
        return 'assets/images/backgroundGame1.jpg';
      case BackgroundImage.game2:
        return 'assets/images/backgroundGame2.jpg';
      case BackgroundImage.game3:
        return 'assets/images/backgroundGame3.jpg';
      case BackgroundImage.game4:
        return 'assets/images/backgroundGame4.jpg';
      case BackgroundImage.game5:
        return 'assets/images/backgroundGame5.jpg';
      case BackgroundImage.game6:
        return 'assets/images/backgroundGame6.jpg';
      case BackgroundImage.game7:
        return 'assets/images/backgroundGame7.jpg';
      case BackgroundImage.game8:
        return 'assets/images/backgroundGame8.jpg';
      default:
        return 'assets/images/backgroundGame.jpg';  // По умолчанию
    }
  }
}