import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/app_const.dart';
import 'package:tetris/domain/services/platform_services.dart';
import 'package:tetris/ui/bloc/score_cubit.dart';
import 'package:tetris/ui/bloc/tetris_bloc.dart';
import 'package:tetris/ui/widgets/custom_elevation_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backgroundMain.jpg"),
            // Указание на ваше изображение
            fit: BoxFit.cover, // Покрывает весь контейнер, сохраняя пропорции
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                // Добавляем отступ снизу
                child: DefaultTextStyle(
                  style: theme.textTheme.titleLarge ?? AppTextStyle.largeText,
                  child: const Text(
                    'Tetris',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CustomElevatedButton(
                      text: "New Game",
                      onPressed: () async {
                        final scoreCubit = context.read<ScoreCubit>();
                        final tetrisBloc = context.read<TetrisBloc>();
                        final navigator = Navigator.of(context);
                        await scoreCubit
                            .resetScore(); // Сброс счёта при начале игры
                        tetrisBloc.add(TetrisEvent.restart);
                        navigator.pushNamed(AppRoutes.tetris);
                      },
                    ),
                    CustomElevatedButton(
                      text: "Score",
                      onPressed: () async {
                        // Логика для показа счёта
                        await context.read<ScoreCubit>().loadHighScore();
                        _showScoreDialog(context);
                      },
                    ),
                    CustomElevatedButton(
                      text: "Exit",
                      onPressed: () => _handleAppExit(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAppExit(BuildContext context) {
    if (Platform.isIOS) {
      _showIOSExitDialog(context); // Показываем диалог для iOS
    } else if (Platform.isAndroid) {
      _showExitConfirmationDialog(context);
    } else if (Platform.isWindows) {
      PlatformService.exitApp();
    }
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: Text(
            'Do you really want to exit the app?',
            style: theme.textTheme.titleSmall,
          ),
          actions: [
            TextButton(
              child: Text('No', style: theme.textTheme.titleMedium),
              onPressed: () => Navigator.of(context).pop(), // Закрывает диалог
            ),
            TextButton(
              child: Text('Yes', style: theme.textTheme.titleMedium),
              onPressed: () {
                Navigator.of(context).pop(); // Закрывает диалог
                if (Navigator.canPop(context)) {
                  Navigator.of(context)
                      .pop(); // Возвращаемся назад, если есть маршруты в стеке
                } else {
                  SystemNavigator.pop(); // Выход из приложения на Android
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showIOSExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('Exit App'),
          content: Text(
            'Press the Home button to exit the app.',
            style: theme.textTheme.titleSmall,
          ),
          actions: [
            TextButton(
              child: Text('OK', style: theme.textTheme.titleMedium),
              onPressed: () => Navigator.of(context).pop(), // Закрываем диалог
            ),
          ],
        );
      },
    );
  }

  void _showScoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text("Current Score"),
          content: BlocBuilder<ScoreCubit, int>(
            builder: (context, score) {
              return Text(
                "Your score is: $score",
                style: theme.textTheme.titleSmall,
              );
            },
          ),
          // Отображение счета
          actions: [
            TextButton(
              onPressed: () {
                context.read<ScoreCubit>().clearHighScore(); // Очистка счета
              },
              child: Text('Clear', style: theme.textTheme.titleMedium),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрытие диалогового окна
              },
              child: Text('OK', style: theme.textTheme.titleMedium),
            ),
          ],
        );
      },
    );
  }
}