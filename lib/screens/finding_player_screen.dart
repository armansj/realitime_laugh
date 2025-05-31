import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../utils/app_theme.dart';
import '../services/audio_service.dart';
import 'laugh_detector_page_simple.dart';
import '../l10n/app_localizations.dart';

class FindingPlayerScreen extends StatefulWidget {
  const FindingPlayerScreen({super.key});

  @override
  State<FindingPlayerScreen> createState() => _FindingPlayerScreenState();
}

class _FindingPlayerScreenState extends State<FindingPlayerScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _dotController;
  
  late Animation<double> _radarAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _dotAnimation;
  
  Timer? _findingTimer;
  int _dots = 0;
  String _statusText = "Searching for players";
  bool _playerFound = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startFindingProcess();
  }
  
  void _initializeAnimations() {
    // Radar rotation animation
    _radarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _radarAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _radarController,
      curve: Curves.linear,
    ));
    
    // Pulse animation for radar waves
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));
    
    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Dot animation for loading text
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _dotAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_dotController);
    
    // Start animations
    _radarController.repeat();
    _pulseController.repeat();
    _fadeController.forward();
    
    // Animate dots
    _animateDots();
  }
  
  void _animateDots() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || _playerFound) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _dots = (_dots + 1) % 4;
      });
    });
  }
    void _startFindingProcess() async {
    // Start crowd laugh sound effect immediately
    AudioService.instance.playCrowdLaugh();
    
    // Simulate finding process with faster timing to match crowd laugh duration
    _findingTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Change status text during finding process
      setState(() {
        switch (timer.tick) {
          case 1:
            _statusText = "Scanning nearby players";
            break;
          case 2:
            _statusText = "Detecting laugh patterns";
            _playerFound = true; // Show emojis earlier
            break;
          case 3:
            _statusText = "Players found! Get ready to laugh";
            break;
        }
      });
      
      // After about 3 seconds (when crowd laugh finishes), navigate to the game
      if (timer.tick >= 3) {
        timer.cancel();
        // Small delay to let the last message show
        Timer(const Duration(milliseconds: 500), () {
          _navigateToGame();
        });
      }
    });
  }
  
  void _navigateToGame() async {
    // Wait a moment to show "Player found" message
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const LaughDetectorPageSimple();
          },
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var slideAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));
            
            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _findingTimer?.cancel();
    _radarController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryYellow.withOpacity(0.8),
              AppTheme.secondaryYellow.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,                  child: Text(
                    l10n.findingPlayers,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Radar Animation
              _buildRadarAnimation(),
              
              const SizedBox(height: 40),
              
              // Status Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      _statusText + "." * _dots,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _playerFound ? Colors.green.shade700 : Colors.brown.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_playerFound)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Ready to start!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRadarAnimation() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar Background Circles
          _buildRadarCircles(),
          
          // Radar Sweep
          AnimatedBuilder(
            animation: _radarAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: RadarSweepPainter(
                  angle: _radarAnimation.value,
                  isPlayerFound: _playerFound,
                ),
              );
            },
          ),
          
          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          
          // Player dots (when found)
          if (_playerFound) ..._buildPlayerDots(),
        ],
      ),
    );
  }
  
  Widget _buildRadarCircles() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer circles with pulse effect
            for (int i = 1; i <= 3; i++)
              Container(
                width: 280.0 * (i / 3) * (0.8 + 0.2 * _pulseAnimation.value),
                height: 280.0 * (i / 3) * (0.8 + 0.2 * _pulseAnimation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3 - (i * 0.05)),
                    width: 2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  List<Widget> _buildPlayerDots() {
    return [
      // Player dot 1
      Positioned(
        top: 80,
        right: 120,
        child: _buildPlayerDot("😄", Colors.blue),
      ),
      // Player dot 2
      Positioned(
        bottom: 100,
        left: 90,
        child: _buildPlayerDot("😂", Colors.green),
      ),
      // Player dot 3
      Positioned(
        top: 120,
        left: 60,
        child: _buildPlayerDot("🤣", Colors.purple),
      ),
    ];
  }
  
  Widget _buildPlayerDot(String emoji, Color color) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RadarSweepPainter extends CustomPainter {
  final double angle;
  final bool isPlayerFound;
  
  RadarSweepPainter({required this.angle, this.isPlayerFound = false});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create radar sweep gradient
    final sweepGradient = SweepGradient(
      startAngle: angle,
      endAngle: angle + 1.0,
      colors: [
        Colors.transparent,
        isPlayerFound ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        isPlayerFound ? Colors.green.withOpacity(0.6) : Colors.orange.withOpacity(0.6),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    // Draw the sweep
    canvas.drawCircle(center, radius, sweepPaint);
    
    // Draw sweep line
    final lineEnd = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
    
    final linePaint = Paint()
      ..color = isPlayerFound ? Colors.green.shade400 : Colors.orange.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(center, lineEnd, linePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
