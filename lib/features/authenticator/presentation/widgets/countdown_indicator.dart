import 'package:flutter/material.dart';

class CountdownIndicator extends StatelessWidget {
  const CountdownIndicator({
    super.key,
    required this.progress,
    this.isUrgent = false,
  });

  final double progress;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isUrgent ? colorScheme.error : colorScheme.primary;

    return Semantics(
      label: isUrgent ? 'Code expiring soon' : 'Code timer',
      value: '${(progress.clamp(0.0, 1.0) * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 200),
          tween: ColorTween(end: color),
          builder: (context, animatedColor, _) {
            return LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: animatedColor ?? color,
            );
          },
        ),
      ),
    );
  }
}
