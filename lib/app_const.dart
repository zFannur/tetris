import 'package:flutter/material.dart';

class AppConst {
  AppConst._();

  static const gridHeight = 14;
  static const gridWidth = 10;

  static const colors = [
    Color(0xFF0000FF),
    Color(0xFFFF0000),
    Color(0xFF00FF00),
    Color(0xFFFFFF00),
    Color(0xFFFFA500),
    Color(0xFF800080),
    Color(0xFF00FFFF),
  ];
}

class AppRoutes {
  AppRoutes._();

  static const main = '/main';
  static const tetris = '/tetris';
}

class AppTextStyle {
  AppTextStyle._();

  static const TextStyle largeText = TextStyle(
    fontFamily: 'Arcade',
    // Используем кастомный шрифт
    fontWeight: FontWeight.bold,
    fontSize: 100,
    letterSpacing: 5,
    color: Colors.white,
    shadows: [
      Shadow(
        // Тень для дополнительного выделения
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        // Ещё одна тень для эффекта глубины
        offset: Offset(-4.0, -4.0),
        blurRadius: 3.0,
        color: Color.fromARGB(125, 0, 255, 0),
      ),
    ],
  );

  static const TextStyle mediumText = TextStyle(
    fontFamily: 'Arcade',
    // Используем кастомный шрифт
    fontWeight: FontWeight.bold,
    fontSize: 40,
    letterSpacing: 2,
    color: Colors.white,
    shadows: [
      Shadow(
        // Тень для дополнительного выделения
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        // Ещё одна тень для эффекта глубины
        offset: Offset(-2.0, -2.0),
        blurRadius: 3.0,
        color: Color.fromARGB(125, 0, 255, 0),
      ),
    ],
  );

  static const TextStyle smallText = TextStyle(
    fontFamily: 'Arcade',
    // Используем кастомный шрифт
    fontWeight: FontWeight.bold,
    fontSize: 30,
    letterSpacing: 2,
    color: Colors.white,
    shadows: [
      Shadow(
        // Тень для дополнительного выделения
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        // Ещё одна тень для эффекта глубины
        offset: Offset(-2.0, -2.0),
        blurRadius: 3.0,
        color: Color.fromARGB(125, 0, 255, 0),
      ),
    ],
  );
}
