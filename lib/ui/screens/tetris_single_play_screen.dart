import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/app_const.dart';
import 'package:tetris/ui/bloc/background_image_cubit.dart';
import 'package:tetris/ui/bloc/score_cubit.dart';
import 'package:tetris/ui/bloc/tetris_bloc.dart';
import 'package:tetris/ui/widgets/custom_button.dart';
import 'package:tetris/ui/widgets/custom_elevation_button.dart';
import 'package:tetris/ui/widgets/game_grid.dart';
import 'package:tetris/ui/widgets/next_tetromino_display.dart';

class TetrisSinglePlayScreen extends StatelessWidget {
  const TetrisSinglePlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundImageCubit = context.read<BackgroundImageCubit>();
    final String imagePath = context.read<BackgroundImageCubit>().getImagePath(backgroundImageCubit.state);

    return PopScope(
      onPopInvoked: (canPop) {
        if (!canPop) {
          // Вызывается, когда пользователь пытается закрыть приложение нажатием кнопки назад
          context.read<TetrisBloc>().add(TetrisEvent.endGame);
        }
      },
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              // Указание на ваше изображение
              fit: BoxFit.cover, // Покрывает весь контейнер, сохраняя пропорции
            ),
          ),
          child: Column(
            children: [
              _buildScorePanel(context), // Показать панель счета
              const TetrisGrid(),
              _buildControlPanel(context)
            ],
          ),
        ),
      ),
    );
  }

  void _handleGameExit(BuildContext context) {
    final navigator = Navigator.of(context);
    context.read<TetrisBloc>().add(TetrisEvent.endGame);
    navigator.pushNamedAndRemoveUntil(AppRoutes.main, (Route<dynamic> route) => false,);
  }

  Widget _buildScorePanel(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Row(
        children: [
          BlocBuilder<ScoreCubit, int>(
            builder: (context, score) {
              return Container(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 2, left: 16, right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 2.0,
                      spreadRadius: 0.0,
                    )
                  ],
                  color: Colors.white.withOpacity(0.6),
                ),
                child: DefaultTextStyle(
                  style: theme.textTheme.titleSmall ?? AppTextStyle.smallText,
                  child: Column(
                    children: [
                      Text("Score: $score"),
                      Text("Level: ${(1 + score ~/ 1000).toString()}"),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          CustomButton(
            onPressed: () {
              context.read<TetrisBloc>().add(TetrisEvent.pause);
              _handleGamePause(context);
            },
            child: const Icon(
              Icons.pause,
              size: 25,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: NextTetrominoDisplay()),
        ],
      ),
    );
  }

  Future<void> _handleGamePause(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pause"),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.3, // 30% от высоты экрана
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  text: "Play",
                  onPressed: () {
                    context.read<TetrisBloc>().add(TetrisEvent.resume);
                    Navigator.maybePop(context);
                  },
                ),
                CustomElevatedButton(
                  text: "Restart",
                  onPressed: () async {
                    final scoreCubit = context.read<ScoreCubit>();
                    final tetrisBloc = context.read<TetrisBloc>();

                    Navigator.maybePop(context); // Закрываем диалог
                    await scoreCubit
                        .resetScore(); // Сброс счёта при начале игры
                    tetrisBloc.add(TetrisEvent.restart);
                  },
                ),
                CustomElevatedButton(
                  text: "Menu",
                  onPressed: () {
                    _handleGameExit(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomButton(
            onPressed: () {
              context.read<TetrisBloc>().add(TetrisEvent.moveLeft);
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 40,
              color: Colors.white,
            ),
          ),
          CustomButton(
            onPressed: () {
              context.read<TetrisBloc>().add(TetrisEvent.rotate);
            },
            child: const Icon(
              Icons.rotate_right,
              size: 40,
              color: Colors.white,
            ),
          ),
          CustomButton(
            onPressed: () {
              context.read<TetrisBloc>().add(TetrisEvent.hardDrop);
            },
            child: const Icon(
              Icons.arrow_downward,
              size: 40,
              color: Colors.white,
            ),
          ),
          CustomButton(
            onPressed: () {
              context.read<TetrisBloc>().add(TetrisEvent.moveRight);
            },
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
