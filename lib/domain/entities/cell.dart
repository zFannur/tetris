import 'package:flutter/material.dart';

class Cell {
  bool filled;
  Color color;

  Cell({this.filled = false, this.color = Colors.transparent});

  Cell copyWith({bool? filled, Color? color}) {
    return Cell(
      filled: filled ?? this.filled,
      color: color ?? this.color,
    );
  }
}