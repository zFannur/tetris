import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/app_const.dart';

import '../../domain/entities/cell.dart';

enum TetrisEvent {
  moveLeft,
  moveRight,
  rotate,
  drop,
  restart,
  hardDrop,
  endGame,
  pause,
  resume
}

class TetrisState {
  final List<List<Cell>> board;
  final Tetromino currentTetromino;
  final Tetromino nextTetromino;
  final int linesCleared;
  final bool isGameOver;

  TetrisState(this.board,
      {Tetromino? currentTetromino,
      Tetromino? nextTetromino,
      this.linesCleared = 0,
      this.isGameOver = false})
      : currentTetromino = currentTetromino ?? Tetromino.random(),
        nextTetromino = nextTetromino ?? Tetromino.random();
}

class TetrisBloc extends Bloc<TetrisEvent, TetrisState> {
  List<List<Cell>> board = List.generate(AppConst.gridHeight,
      (_) => List.generate(AppConst.gridWidth, (_) => Cell()));
  late Tetromino currentTetromino;
  late Tetromino nextTetromino;
  Color currentColor = Colors.blue;
  int difficultyLevel = 1; // Уровень сложности, 1 - самый низкий
  Timer? _timer;

  TetrisBloc()
      : super(
          TetrisState(
            List.generate(
              AppConst.gridHeight,
              (_) => List.generate(AppConst.gridWidth, (_) => Cell()),
            ),
          ),
        ) {
    on<TetrisEvent>((event, emit) {
      switch (event) {
        case TetrisEvent.moveLeft:
          _move(-1, 0, emit); // Перемещение влево
          break;
        case TetrisEvent.moveRight:
          _move(1, 0, emit); // Перемещение вправо
          break;
        case TetrisEvent.rotate:
          _rotate(emit); // Вращение фигуры
          break;
        case TetrisEvent.drop:
          _drop(emit); // Ускоренное падение
        case TetrisEvent.hardDrop:
          _hardDrop(emit);
          break;
        case TetrisEvent.restart:
          startGame(emit); // Обработка события перезапуска игры
          break;
        case TetrisEvent.pause:
          _timer?.cancel(); // Обработка события паузы
          break;
        case TetrisEvent.resume:
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            add(TetrisEvent.drop); // Автоматическое падение фигуры
          });
          break;
        case TetrisEvent.endGame:
          _timer?.cancel(); // Остановка таймера
          break;
        default:
          startGame(emit); // Начало новой игры
          break;
      }
    });
  }

  void updateDifficulty(int level) {
    _setupTimer(level: level);
  }

  void _setupTimer({int level = 1}) {
    difficultyLevel = level;

    const baseSpeed = Duration(seconds: 1); // Базовая скорость падения фигур
    int speedAdjustment =
        difficultyLevel * 100; // Ускорение на каждом уровне сложности
    Duration interval =
        Duration(milliseconds: baseSpeed.inMilliseconds - speedAdjustment);

    _timer?.cancel(); // Отменяем предыдущий таймер, если он был
    _timer = Timer.periodic(interval, (timer) {
      add(TetrisEvent.drop); // Автоматическое падение фигуры
    });
  }

  void startGame(Emitter<TetrisState> emit) {
    currentTetromino = _generateNewTetromino(); // Генерация текущего тетромино
    nextTetromino = _generateNewTetromino(); // Генерация следующего тетромино
    board = List.generate(AppConst.gridHeight,
        (_) => List.generate(AppConst.gridWidth, (_) => Cell()));
    _setupTimer(); // Настройка таймера с учетом сложности
    emit(TetrisState(
      board,
      currentTetromino: currentTetromino,
      nextTetromino: nextTetromino,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel(); // Убедимся, что таймер отменен при закрытии BLoC
    return super.close();
  }

  void _move(int dx, int dy, Emitter<TetrisState> emit) {
    clearTetrominoFromBoard(currentTetromino);  // Очищаем текущую позицию фигуры на доске
    currentTetromino.move(dx, dy);  // Перемещаем фигуру

    if (_checkCollision(currentTetromino)) {
      currentTetromino.move(-dx, -dy);  // Если после перемещения возникло столкновение, возвращаем фигуру на исходную позицию
      placeTetrominoOnBoard(currentTetromino);  // Помещаем фигуру обратно на доску
    } else {
      placeTetrominoOnBoard(currentTetromino);  // Если столкновения нет, оставляем фигуру на новом месте
    }

    // Отправляем обновленное состояние игры, включая информацию о доске, текущей и следующей фигуре
    emit(TetrisState(
        board,
        currentTetromino: currentTetromino,
        nextTetromino: nextTetromino,
        linesCleared: 0,
        isGameOver: false
    ));
  }

  void clearTetrominoFromBoard(Tetromino tetromino) {
    for (var cell in tetromino.shape) {
      int x = tetromino.position.x + cell.x;
      int y = tetromino.position.y + cell.y;
      if (x >= 0 &&
          x < AppConst.gridWidth &&
          y >= 0 &&
          y < AppConst.gridHeight) {
        board[y][x] = Cell(filled: false); // Очистка позиции
      }
    }
  }

  void placeTetrominoOnBoard(Tetromino tetromino) {
    for (var cell in tetromino.shape) {
      int x = tetromino.position.x + cell.x;
      int y = tetromino.position.y + cell.y;
      if (x >= 0 &&
          x < AppConst.gridWidth &&
          y >= 0 &&
          y < AppConst.gridHeight) {
        board[y][x] = Cell(
            filled: true,
            color: tetromino.color); // Закрепление фигуры на новой позиции
      }
    }
  }

  void _rotate(Emitter<TetrisState> emit) {
    if (currentTetromino.type == TetrominoType.O) return; // Кубик не вращаем.

    clearTetrominoFromBoard(currentTetromino);
    currentTetromino.rotate(); // Вращаем тетромино.

    int shiftX = 0; // Определяем переменную для отслеживания сдвига

    // Пробуем подвинуть тетромино в пределы поля.
    while (currentTetromino.position.x < 0) {
      shiftX++;
      currentTetromino.move(1, 0); // Сдвигаем вправо.
    }
    while (currentTetromino.position.x + currentTetromino.width > AppConst.gridWidth) {
      shiftX--;
      currentTetromino.move(-1, 0); // Сдвигаем влево.
    }

    // Проверяем столкновения после вращения и сдвига.
    if (_checkCollision(currentTetromino)) {
      // Если есть столкновение, отменяем вращение и сдвиг.
      for (int i = 0; i < 3; i++) {
        currentTetromino.rotate(); // Возвращаем тетромино в исходное положение.
      }
      currentTetromino.move(-shiftX, 0); // Возвращаем в исходное положение по горизонтали.
    }

    placeTetrominoOnBoard(currentTetromino); // Помещаем тетромино обратно на доску.
    emit(TetrisState(
        List<List<Cell>>.from(board),
        currentTetromino: currentTetromino,
        nextTetromino: nextTetromino, // Обновляем состояние с учетом следующей фигуры
        linesCleared: 0,
        isGameOver: false
    ));
  }

  void _drop(Emitter<TetrisState> emit) {
    clearTetrominoFromBoard(currentTetromino);
    currentTetromino.move(0, 1);
    bool collision = _checkCollision(currentTetromino);

    if (collision) {
      currentTetromino.move(
          0, -1); // Отменяем последний ход, т.к. произошло столкновение
      placeTetrominoOnBoard(currentTetromino); // Закрепляем фигуру на доске
      int linesCleared = _clearLines(); // Очищаем заполненные линии

      // Обновляем состояние, используя старую следующую фигуру как текущую
      currentTetromino = nextTetromino;
      nextTetromino =
          _generateNewTetromino(); // Генерируем новую следующую фигуру

      // Проверяем, приведет ли появление новой текущей фигуры к немедленному столкновению
      bool gameOver = _checkCollision(currentTetromino);
      emit(TetrisState(
        board,
        currentTetromino: currentTetromino,
        nextTetromino: nextTetromino,
        linesCleared: linesCleared,
        isGameOver: gameOver,
      ));

      if (gameOver) {
        _handleGameOver();
      }
    } else {
      placeTetrominoOnBoard(currentTetromino); // Фигура свободно падает дальше
      emit(TetrisState(
        board,
        currentTetromino: currentTetromino,
        nextTetromino: nextTetromino,
        linesCleared: 0,
        isGameOver: false,
      ));
    }
  }

  void _hardDrop(Emitter<TetrisState> emit) {
    bool collisionDetected = false;
    int linesCleared = 0;
    clearTetrominoFromBoard(currentTetromino);  // Очистить текущие позиции перед перемещением

    while (true) {
      currentTetromino.move(0, 1);  // Перемещаем фигуру вниз
      if (_checkCollision(currentTetromino)) {
        currentTetromino.move(0, -1);  // Возвращаем фигуру на шаг назад при столкновении
        collisionDetected = true;
        break;
      }
    }

    placeTetrominoOnBoard(currentTetromino);  // Закрепляем фигуру после завершения перемещения

    if (collisionDetected) {
      linesCleared = _clearLines();  // Очищаем полные линии
      // Сохраняем следующую фигуру перед генерацией новой, чтобы отобразить её в UI
      Tetromino previousNextTetromino = nextTetromino;
      currentTetromino = previousNextTetromino;  // Следующая фигура становится текущей
      nextTetromino = _generateNewTetromino();  // Генерация новой следующей фигуры

      if (_checkCollision(currentTetromino)) {
        _handleGameOver();  // Обрабатываем конец игры, если новая фигура не помещается
        emit(TetrisState(board, currentTetromino: currentTetromino, nextTetromino: nextTetromino,
            linesCleared: linesCleared, isGameOver: true));  // Состояние конца игры
      } else {
        emit(TetrisState(board, currentTetromino: currentTetromino, nextTetromino: nextTetromino,
            linesCleared: linesCleared, isGameOver: false));  // Обычное состояние игры
      }
    }
    //else {
      // emit(TetrisState(board, currentTetromino: currentTetromino, nextTetromino: nextTetromino,
      //     linesCleared: linesCleared, isGameOver: false));  // Обычное состояние игры
    //}
  }

  void _handleGameOver() {
    _timer?.cancel(); // Остановить таймер
  }

  Tetromino _generateNewTetromino() {
    var types = TetrominoType.values;
    return Tetromino(types[Random().nextInt(types.length)], const Point(5, 0),
        Colors.accents[Random().nextInt(Colors.accents.length)]);
  }

  bool _checkCollision(Tetromino tetromino) {
    for (var cell in tetromino.shape) {
      int x = tetromino.position.x + cell.x;
      int y = tetromino.position.y + cell.y;
      // Проверка границ игрового поля
      if (x < 0 || x >= AppConst.gridWidth || y >= AppConst.gridHeight) {
        return true;
      }
      // Проверка, что клетка в пределах доски и заполнена
      if (y >= 0 && board[y][x].filled) {
        return true;
      }
    }
    return false;
  }

  int _clearLines() {
    int width = board[0].length; // Ширина доски (количество столбцов)
    int height = board.length; // Высота доски (количество строк)
    List<List<Cell>> newBoard = []; // Создание новой доски

    // Собираем все не полностью заполненные линии
    for (var row in board) {
      if (row.any((cell) => !cell.filled)) {
        // Если линия не полностью заполнена
        newBoard.add(List<Cell>.from(row)); // Добавляем её в новую доску
      }
    }

    // Вычисляем, сколько линий было удалено
    int linesCleared = height - newBoard.length;

    // Добавляем нужное количество пустых линий в начало новой доски
    for (int i = 0; i < linesCleared; i++) {
      newBoard.insert(0, List.generate(width, (_) => Cell(filled: false)));
    }

    // Обновляем доску
    board = newBoard;

    // Опционально: логирование или обновление счёта
    return linesCleared;
  }
}

enum TetrominoType { I, O, T, S, Z, J, L }

class Tetromino {
  List<Point<int>> shape;
  Point<int> position;
  TetrominoType type;
  Color color;

  Tetromino(this.type, this.position, this.color) : shape = _getShape(type);

  // Статический метод для создания "пустого" тетромино
  static Tetromino random() {
    var types = TetrominoType.values;
    return Tetromino(types[Random().nextInt(types.length)], const Point(5, 0),
        Colors.accents[Random().nextInt(Colors.accents.length)]);
  }

  static List<Point<int>> _getShape(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return const [
          Point(0, 1),
          Point(0, 2),
          Point(0, 3),
          Point(0, 0)
        ]; // Палка
      case TetrominoType.O:
        return const [
          Point(0, 0),
          Point(1, 0),
          Point(0, 1),
          Point(1, 1)
        ]; // Квадрат
      case TetrominoType.T:
        return const [
          Point(1, 0),
          Point(0, 1),
          Point(1, 1),
          Point(2, 1)
        ]; // Т-образная
      case TetrominoType.S:
        return const [
          Point(1, 0),
          Point(2, 0),
          Point(0, 1),
          Point(1, 1)
        ]; // S-образная
      case TetrominoType.Z:
        return const [
          Point(0, 0),
          Point(1, 0),
          Point(1, 1),
          Point(2, 1)
        ]; // Z-образная
      case TetrominoType.J:
        return const [
          Point(0, 0),
          Point(0, 1),
          Point(1, 1),
          Point(2, 1)
        ]; // J-образная
      case TetrominoType.L:
        return const [
          Point(2, 0),
          Point(0, 1),
          Point(1, 1),
          Point(2, 1)
        ]; // L-образная
      default:
        return [];
    }
  }

  void move(int dx, int dy) {
    position = Point(position.x + dx, position.y + dy);
  }

  void rotate() {
    // Простая ротация на 90 градусов по часовой стрелке
    shape = shape.map((p) => Point(-p.y, p.x)).toList();
  }

  int get width {
    int maxX = shape.fold(
        0, (previousValue, element) => max(previousValue, element.x));
    return maxX + 1; // +1 потому что индексация начинается с 0
  }
}
