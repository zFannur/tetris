import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/app_const.dart';
import 'package:tetris/domain/entities/cell.dart';
import 'package:tetris/ui/bloc/score_cubit.dart';
import 'package:tetris/ui/bloc/tetris_bloc.dart';
import 'package:tetris/ui/widgets/custom_button.dart';
import 'package:tetris/ui/widgets/custom_elevation_button.dart';

class TetrisSinglePlayScreen extends StatelessWidget {
  const TetrisSinglePlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backgroundGame.jpg"),
            // Указание на ваше изображение
            fit: BoxFit.cover, // Покрывает весь контейнер, сохраняя пропорции
          ),
        ),
        child: Column(
          children: [
            _buildScorePanel(context), // Показать панель счета
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocListener<ScoreCubit, int>(
                  listener: (context, score) {
                    int level = 1 + score ~/ 1000;  // Вычисляем уровень на основе текущего счёта
                    context.read<TetrisBloc>().updateDifficulty(level);
                  },
                  child: BlocConsumer<TetrisBloc, TetrisState>(
                    listener: (context, state) async {
                      if (state.linesCleared > 0) {
                        context
                            .read<ScoreCubit>()
                            .incrementScore(state.linesCleared);
                      }

                      // Предполагается, что state может иметь свойство isGameOver и score
                      if (state.isGameOver) {
                        final score = context.read<ScoreCubit>().state;
                        await _handleGameOver(context, score);
                      }
                    },
                    builder: (context, state) {
                      final grid = state
                          .board; // Получаем доску, уже состоящую из объектов Cell
                      var tetromino = context
                          .read<TetrisBloc>()
                          .currentTetromino; // Получаем текущую фигуру
                      var boardWithTetromino = List.generate(
                          AppConst.gridHeight,
                          (y) => List.generate(
                              AppConst.gridWidth,
                              (x) => grid[y][x]
                                  .copyWith())); // Создаем копию текущей доски

                      // Размещаем текущую фигуру на доске
                      for (var point in tetromino.shape) {
                        int x = tetromino.position.x + point.x;
                        int y = tetromino.position.y + point.y;
                        if (y >= 0 &&
                            y < AppConst.gridHeight &&
                            x >= 0 &&
                            x < AppConst.gridWidth) {
                          boardWithTetromino[y][x] = Cell(
                            filled: true,
                            color: tetromino.color,
                          ); // Отмечаем клетки фигуры на доске
                        }
                      }

                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: AppConst.gridWidth,
                            mainAxisSpacing: 1.5,
                          ),
                          itemCount: AppConst.gridHeight * AppConst.gridWidth,
                          // 16 * 10
                          itemBuilder: (context, index) {
                            int x = index % 10;
                            int y = index ~/ 10;
                            Cell cell =
                                boardWithTetromino[y][x]; // Извлекаем клетку
                            return Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                // Используем цвет клетки, если она заполнена
                                color: cell.filled
                                    ? cell.color
                                    : Colors.white.withOpacity(
                                        0.6,
                                      ),
                                boxShadow: cell.filled
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          offset: const Offset(0, 2),
                                          blurRadius: 2.0,
                                          spreadRadius: 0.0,
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 2),
                                          blurRadius: 2.0,
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                // Добавляем тень только для заполненных клеток
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cell.filled
                                        ? cell.color
                                        : cell.color.withOpacity(
                                            0.3,
                                          ),
                                    Colors.white.withOpacity(
                                      0.5,
                                    ),
                                  ],
                                  stops: const [0.7, 1.0],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildControlPanel(context)
          ],
        ),
      ),
    );
  }

  void _handleGameExit(BuildContext context) {
    final navigator = Navigator.of(context);
    context.read<TetrisBloc>().add(TetrisEvent.endGame);
    navigator.pushNamedAndRemoveUntil(AppRoutes.main, ModalRoute.withName('/'));
  }

  Widget _buildScorePanel(BuildContext context) {
    final theme = Theme.of(context);
    final level = context.read<ScoreCubit>().currentLevel;

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
                  color: Colors.white.withOpacity(0.6),
                ),
                child: DefaultTextStyle(
                  style: theme.textTheme.titleSmall ?? AppTextStyle.smallText,
                  child: Column(
                    children: [
                      Text("Score: $score"),
                      Text("Level: $level"),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
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
        ],
      ),
    );
  }

  Future<void> _handleGamePause(BuildContext context) async {
    await showDialog(
      context: context,
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

  Future<void> _handleGameOver(BuildContext context, int score) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text("Game Over"),
          content: Text(
            "Your score: $score",
            style: theme.textTheme.titleSmall,
          ),
          actions: [
            CustomElevatedButton(
              text: "Exit",
              onPressed: () {
                _handleGameExit(context);
              },
            ),
            CustomElevatedButton(
              text: "Restart",
              onPressed: () async {
                final scoreCubit = context.read<ScoreCubit>();
                final tetrisBloc = context.read<TetrisBloc>();

                Navigator.maybePop(context); // Закрываем диалог
                await scoreCubit.resetScore(); // Сброс счёта при начале игры
                tetrisBloc.add(TetrisEvent.restart);
              },
            ),
          ],
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
          FloatingActionButton(
            backgroundColor: Colors.white.withOpacity(0.6),
            heroTag: 'moveLeft',
            // Уникальный тег для Hero анимации
            onPressed: () =>
                context.read<TetrisBloc>().add(TetrisEvent.moveLeft),
            tooltip: 'Move Left',
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 40,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.white.withOpacity(0.6),
            heroTag: 'rotate',
            // Уникальный тег
            onPressed: () => context.read<TetrisBloc>().add(TetrisEvent.rotate),
            tooltip: 'Rotate',
            child: const Icon(
              Icons.rotate_right,
              size: 40,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.white.withOpacity(0.6),
            heroTag: 'hardDrop',
            // Уникальный тег
            onPressed: () =>
                context.read<TetrisBloc>().add(TetrisEvent.hardDrop),
            tooltip: 'Hard Drop',
            child: const Icon(
              Icons.arrow_downward,
              size: 40,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.white.withOpacity(0.6),
            heroTag: 'moveRight',
            // Уникальный тег
            onPressed: () =>
                context.read<TetrisBloc>().add(TetrisEvent.moveRight),
            tooltip: 'Move Right',
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
