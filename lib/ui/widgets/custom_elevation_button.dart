import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Прозрачный фон
        elevation: 0, // Убрать тень
      ),
      child: Text(
        text,
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}
