import 'package:flutter/material.dart';

class PredictionChip extends StatelessWidget {
  final String prediction;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const PredictionChip({required this.prediction, required this.textTheme, required this.colorScheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        prediction,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer.withAlpha(25),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
