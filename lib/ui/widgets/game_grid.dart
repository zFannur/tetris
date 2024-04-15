import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/app_const.dart';
import 'package:tetris/domain/entities/cell.dart';
import 'package:tetris/ui/bloc/score_cubit.dart';
import 'package:tetris/ui/bloc/tetris_bloc.dart';

import 'custom_elevation_button.dart';


class TetrisGrid extends StatelessWidget {
  const TetrisGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<ScoreCubit, int>(
          listener: (context, score) {
            final level = context.read<TetrisBloc>().difficultyLevel;

            if (level != (1 + score ~/ 1000)) {
              context.read<TetrisBloc>().updateDifficulty(level + 1);
            }
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
                child: GridView.count(
                  crossAxisCount: AppConst.gridWidth,  // Обычно это 10
                  mainAxisSpacing: 1.5,
                  crossAxisSpacing: 1.5,
                  childAspectRatio: 1,  // Одно и то же соотношение сторон для всех устройств
                  physics: const NeverScrollableScrollPhysics(),  // Отключает скроллинг
                  children: List.generate(AppConst.gridHeight * AppConst.gridWidth, (index) {
                    int x = index % AppConst.gridWidth;
                    int y = index ~/ AppConst.gridWidth;
                    Cell cell = boardWithTetromino[y][x];  // Извлекаем клетку
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: cell.filled ? cell.color : Colors.white.withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(
                            color: cell.filled
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          )
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cell.filled ? cell.color : cell.color.withOpacity(0.3),
                            Colors.white.withOpacity(0.5),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
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

  Future<void> _handleGameOver(BuildContext context, int score) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
}