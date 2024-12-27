import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        // Установим цвет Material, чтобы волна распространялась
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          // Обработчик нажатия
          borderRadius: BorderRadius.circular(16),
          // Радиус скругления для волны
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Center(child: child),
          ), // Центрируем дочерний виджет
        ),
      ),
    );
  }
}
