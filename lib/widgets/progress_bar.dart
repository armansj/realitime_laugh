import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final String laughLevel;
  final Animation<double> pulseAnimation;
  final Animation<Color?> colorAnimation;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.laughLevel,
    required this.pulseAnimation,
    required this.colorAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressLabel(),
        const SizedBox(height: 12),
        _buildAnimatedProgressBar(),
        const SizedBox(height: 8),
        _buildProgressPercentage(),
      ],
    );
  }

  Widget _buildProgressLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Laugh Progress',
        style: AppTheme.subtitleStyle,
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: laughLevel != "none" ? pulseAnimation.value : 1.0,
          child: Container(
            height: 30,
            decoration: AppTheme.progressBarDecoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.yellow.shade100,
                    color: colorAnimation.value,
                    minHeight: 24,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressPercentage() {
    return Text(
      '${(progress * 100).toStringAsFixed(0)}%',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade800,
      ),
    );
  }
}
