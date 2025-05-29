import 'package:flutter/material.dart';
import 'dart:math' as math;

class CelebrationWidgets {
  static Widget buildAnimatedStarFill({
    required int starsEarned,
    required AnimationController controller,
    required Animation<double> starFillAnimation,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        // Calculate delay for each star
        double delay = index * 0.3; // 300ms delay between each star
        double startTime = delay;
        double endTime = delay + 0.4; // 400ms fill duration per star
        
        bool shouldFill = index < starsEarned;
        
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            double progress = 0.0;
            if (shouldFill && controller.value >= startTime) {
              double localProgress = (controller.value - startTime) / (endTime - startTime);
              progress = math.min(1.0, math.max(0.0, localProgress));
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: buildSingleAnimatedStar(progress, index < starsEarned),
            );
          },
        );
      }),
    );
  }

  static Widget buildSingleAnimatedStar(double fillProgress, bool shouldFill) {
    return Transform.scale(
      scale: 1.0 + (fillProgress * 0.3), // Scale up slightly during fill
      child: Stack(
        children: [
          // Empty star background
          Icon(
            Icons.star_border,
            size: 40,
            color: Colors.grey.shade400,
          ),
          // Filled star with clip
          ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: fillProgress,
              child: Icon(
                Icons.star,
                size: 40,
                color: Colors.amber.shade600,
              ),
            ),
          ),
          // Glow effect when filling
          if (fillProgress > 0 && fillProgress < 1)
            Positioned.fill(
              child: Icon(
                Icons.star,
                size: 40,
                color: Colors.amber.shade300.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildStarAnimation({
    required bool showAnimation,
    required Animation<double> scaleAnimation,
    required AnimationController controller,
  }) {
    if (!showAnimation) return const SizedBox.shrink();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Center(
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBouncingStar(0, controller),
                  const SizedBox(width: 20),
                  _buildBouncingStar(1, controller),
                  const SizedBox(width: 20),
                  _buildBouncingStar(2, controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildBouncingStar(int index, AnimationController controller) {
    return Transform.rotate(
      angle: (controller.value * 2 * math.pi) + (index * 0.5),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.amber.shade400,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.star,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
  static Widget buildCelebrationMessage({
    required bool showAnimation,
    required double screenHeight,
  }) {
    if (!showAnimation) return const SizedBox.shrink();

    return Positioned(
      top: screenHeight * 0.3,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber.shade300,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Text(
            '🎉 Amazing Laugh! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
        ),
      ),
    );
  }
}
