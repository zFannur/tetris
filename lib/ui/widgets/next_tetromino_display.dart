import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/ui/bloc/tetris_bloc.dart';

class NextTetrominoDisplay extends StatelessWidget {
  const NextTetrominoDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TetrisBloc, TetrisState>(
      builder: (context, state) {
        final size = MediaQuery.of(context).size.width / 4;

        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: TetrominoPainter(
              tetromino: state.nextTetromino,
            ), // Уверены, что nextTetromino не null
          ),
        );
      },
    );
  }
}

class TetrominoPainter extends CustomPainter {
  final Tetromino tetromino;

  TetrominoPainter({required this.tetromino});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = tetromino.color
      ..style = PaintingStyle.fill;

    double blockWidth = size.width / 5; // Обновлено с учетом ширины доски
    double blockHeight = blockWidth;

    for (var point in tetromino.shape) {
      double x = point.x * blockWidth; // Убрано сложение с tetromino.position.x
      double y = point.y * blockHeight; // Убрано сложение с tetromino.position.y

      if (x < size.width && y < size.height) { // Добавлена проверка на выход за границы
        canvas.drawRect(Rect.fromLTWH(x, y, blockWidth, blockHeight), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
