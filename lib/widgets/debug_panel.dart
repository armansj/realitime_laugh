import 'package:flutter/material.dart';

class DebugPanel extends StatelessWidget {
  final double mouthOpen;
  final double smileProb;
  final String laughLevel;
  final DateTime? startTime;
  final double progress;
  final bool gameCompleted;
  final int starsEarned;

  const DebugPanel({
    super.key,
    required this.mouthOpen,
    required this.smileProb,
    required this.laughLevel,
    this.startTime,
    required this.progress,
    this.gameCompleted = false,
    this.starsEarned = 0,
  });  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade400, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 4),
          _buildStatRow('Mouth Open', mouthOpen.toStringAsFixed(1), Icons.sentiment_satisfied),
          _buildStatRow('Smile Prob', '${(smileProb * 100).toStringAsFixed(0)}%', Icons.sentiment_very_satisfied),
          _buildStatRow('Laugh Level', laughLevel, _getLaughIcon(laughLevel)),
          _buildStatRow('Progress', '${(progress * 100).toStringAsFixed(0)}%', Icons.trending_up),
          if (gameCompleted)
            _buildStatRow('Stars', '$starsEarned/3', Icons.star),
        ],
      ),
    );
  }  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, color: Colors.brown.shade700, size: 14),
        const SizedBox(width: 4),
        Text(
          'Detection Stats',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.brown.shade600),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              color: Colors.brown.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: Colors.brown.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLaughIcon(String laughLevel) {
    switch (laughLevel) {
      case 'light':
        return Icons.sentiment_satisfied;
      case 'moderate':
        return Icons.sentiment_very_satisfied;
      case 'extreme':
        return Icons.sentiment_very_satisfied_outlined;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
