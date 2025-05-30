import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/face_detection_service.dart';
import '../models/firebase_score_manager.dart';
import '../models/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/debug_panel.dart';
import '../widgets/progress_bar.dart';
import '../widgets/celebration_widgets.dart';
import '../widgets/score_widget.dart';
import '../main.dart';
import 'user_profile_screen.dart';

class LaughDetectorPageSimple extends StatefulWidget {
  const LaughDetectorPageSimple({super.key});

  @override
  _LaughDetectorPageSimpleState createState() => _LaughDetectorPageSimpleState();
}

class _LaughDetectorPageSimpleState extends State<LaughDetectorPageSimple>
    with TickerProviderStateMixin {  late CameraController _cameraController;
  late FaceDetectionService _faceDetectionService;
  FirebaseScoreManager? _scoreManager;
  final AuthService _authService = AuthService(); // Add AuthService instance
  bool _isInitialized = false;
  String _initializationError = '';
  
  // Add GlobalKey for ScoreWidget
  final GlobalKey<ScoreWidgetState> _scoreWidgetKey = GlobalKey<ScoreWidgetState>();
  // Detection state - simple like your working code
  double _mouthOpen = 0.0;
  double _smileProb = 0.0;
  String _laughLevel = "none";
  double _smileProgress = 0.0;
  // Timer and animation variables
  DateTime? _progressStartTime;
  bool _showStarAnimation = false;
  bool _gameCompleted = false;
  bool _gameStarted = false; // Add this to track if game session has started
  int _starsEarned = 0;
  int _gameScore = 0;
  bool _showScoreDisplay = false;
  late AnimationController _starAnimationController;
  late AnimationController _starFillController;
  late AnimationController _progressPulseController;
  late AnimationController _timerController;
  Timer? _countdownTimer;
  int _remainingSeconds = 15;
  late Animation<double> _starScaleAnimation;
  late Animation<double> _starFillAnimation;
  late Animation<double> _progressPulseAnimation;
  late Animation<Color?> _progressColorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Use a post-frame callback to ensure the widget is properly mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeServices();
        _initializeAnimations();
        _initCamera();
      }
    });
  }  void _initializeServices() async {
    _faceDetectionService = FaceDetectionService();
    _scoreManager = FirebaseScoreManager();
    await _scoreManager!.initialize();
  }void _initializeAnimations() {
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _starFillController = AnimationController(
      duration: const Duration(milliseconds: 1800), // 1.8 seconds for 3 stars with delays
      vsync: this,
    );
    
    _progressPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _timerController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    
    _starScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _starAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _starFillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starFillController,
      curve: Curves.easeInOut,
    ));
    
    _progressPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _progressPulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressColorAnimation = ColorTween(
      begin: Colors.amber,
      end: Colors.orange,
    ).animate(_progressPulseController);
  }

  Future<void> _initCamera() async {
    try {
      // Import cameras from main.dart or get them directly
      List<CameraDescription> cameraList = cameras.isNotEmpty 
          ? cameras 
          : await availableCameras();
      
      if (cameraList.isEmpty) {
        setState(() {
          _initializationError = 'No cameras available on this device';
        });
        return;
      }
      
      // Find front camera or use first available
      CameraDescription camera;
      try {
        camera = cameraList.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front);
      } catch (e) {
        camera = cameraList.first;
      }
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      _startImageStream();
    } catch (e) {
      setState(() {
        _initializationError = 'Camera initialization failed: $e';
      });
    }
  }  void _startImageStream() {
    try {
      _cameraController.startImageStream((image) async {
        // Skip if already processing or game is completed
        if (_faceDetectionService.isDetecting || _gameCompleted) return;

        try {
          final faceResult = await _faceDetectionService.analyzeFace(image);          if (mounted && !_gameCompleted) {
            if (faceResult.isEmpty) {
              // Only update smile progress, don't reset game session
              _updateSmileProgress(0.0, 0.0, false, false);
            } else {
              // Start the game session when face is first detected
              if (!_gameStarted) {
                setState(() {
                  _gameStarted = true;
                  _progressStartTime = DateTime.now();
                });
                _startCountdownTimer();
              }
              _updateSmileProgress(faceResult.smileProb, faceResult.mouthOpen, faceResult.cheekRaised, faceResult.eyeWrinkleDetected);
            }
          }
        } catch (e) {
          // Silent error handling - print for debugging
          print('Face detection error: $e');
        }
      });
    } catch (e) {
      print('Image stream error: $e');
    }
  }// Use the exact algorithm from your working code but with more challenging thresholds
  void _updateSmileProgress(double smileProb, double mouthOpen, bool cheekRaised, bool eyeWrinkleDetected) {
    // Stop detection if game is completed
    if (_gameCompleted) {
      return;
    }

    String laughLevel = "none";
    double step = 0.0;

    // Made more challenging - higher thresholds and stricter conditions
    if ((smileProb > 0.85 && mouthOpen > 55) && cheekRaised && eyeWrinkleDetected) {
      step = 0.045; // Extreme (reduced from 0.066)
      laughLevel = "extreme";
    } else if ((smileProb > 0.75 && mouthOpen > 45) && (cheekRaised || eyeWrinkleDetected)) {
      step = 0.025; // Moderate (reduced from 0.033)
      laughLevel = "moderate";
    } else if (smileProb > 0.5 && mouthOpen > 30) {
      step = 0.012; // Light (reduced from 0.013)
      laughLevel = "light";
    }

    setState(() {
      _mouthOpen = mouthOpen;
      _smileProb = smileProb;
      _laughLevel = laughLevel;      if (step > 0 && !_gameCompleted) {
        _smileProgress += step;
        if (_smileProgress > 1.0) {
          _smileProgress = 1.0;
          _completeGame();
        }
      } else if (!_gameCompleted) {
        // Fast decay when not smiling - exactly like your code
        _smileProgress -= 0.12; // Slightly reduced decay for more challenge
        if (_smileProgress < 0.0) {
          _smileProgress = 0.0;
        }
      }
    });
  }  void _completeGame() {
    if (_gameCompleted) return;
    
    // Stop the countdown timer
    _countdownTimer?.cancel();
    
    _gameCompleted = true;
    _starsEarned = _calculateStars();

    // Calculate score but don't show it yet
    if (_progressStartTime != null && _scoreManager != null) {
      final duration = DateTime.now().difference(_progressStartTime!);
      final completionTime = duration.inSeconds.toDouble();
      final laughDuration = (15 - _remainingSeconds).clamp(0, 15).toDouble();
      
      _scoreManager!.addGameResult(
        starsEarned: _starsEarned,
        completionTime: completionTime,
        laughDuration: laughDuration,
      ).then((_) async {
        setState(() {
          _gameScore = _calculateGameScore(_starsEarned, completionTime, laughDuration);
          // Don't show score display yet - wait for reset button click
        });
        
        // Award money based on stars earned
        int moneyToAward = _calculateMoneyReward(_starsEarned);
        if (moneyToAward > 0) {
          try {
            await _authService.addMoney(moneyToAward);
            print('Awarded $moneyToAward money for $_starsEarned stars');
          } catch (e) {
            print('Error awarding money: $e');
          }
        }
        
        // Refresh the score widget in the app bar
        _scoreWidgetKey.currentState?.refreshScoreData();
      });
    }
    
    _triggerStarAnimation();
  }
  int _calculateStars() {
    if (_progressStartTime == null) return 0;
    
    final duration = DateTime.now().difference(_progressStartTime!);
    final completionTime = duration.inSeconds;
    
    if (completionTime <= 15) {
      return 3; // 3 stars for under 15 seconds
    } else if (_smileProgress >= 0.75) {
      return 2; // 2 stars for 75% or more
    } else if (_smileProgress >= 0.50) {
      return 1; // 1 star for 50% or more
    } else {
      return 0; // No stars
    }
  }

  // Calculate score based on game performance
  int _calculateGameScore(int starsEarned, double completionTime, double laughDuration) {
    int baseScore = starsEarned * 100; // 100, 200, or 300 base points
    
    // Bonus for completion time (max 50 points)
    int timeBonus = 0;
    if (completionTime <= 5) {
      timeBonus = 50;
    } else if (completionTime <= 10) {
      timeBonus = 30;
    } else if (completionTime <= 15) {
      timeBonus = 10;
    }
    
    // Bonus for laugh duration (max 50 points)
    int laughBonus = (laughDuration * 5).round().clamp(0, 50);
      return baseScore + timeBonus + laughBonus;
  }

  // Calculate money reward based on stars earned
  int _calculateMoneyReward(int starsEarned) {
    switch (starsEarned) {
      case 3:
        return 15; // 15 money for 3 stars (excellent performance)
      case 2:
        return 10; // 10 money for 2 stars (good performance)
      case 1:
        return 5;  // 5 money for 1 star (basic completion)
      default:
        return 2;  // 2 money for participation (even if no stars)
    }
  }

  void _startCountdownTimer() {
    _remainingSeconds = 15;
    _timerController.reset();
    _timerController.forward();
    
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_gameCompleted) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        if (!_gameCompleted && _smileProgress > 0) {
          // Time's up - complete with current progress
          _completeGame();
        }
      }
    });
  }  void _resetGame() {
    // If score hasn't been shown yet, show it first
    if (_gameCompleted && !_showScoreDisplay && _gameScore > 0) {
      setState(() {
        _showScoreDisplay = true;
      });
      
      // Auto-reset after showing score for 4 seconds
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          _actualResetGame();
        }
      });
      return;
    }
    
    // If score is already showing, reset immediately
    _actualResetGame();
  }
    void _actualResetGame() {
    _countdownTimer?.cancel();
    _timerController.reset();
    setState(() {
      _smileProgress = 0.0;
      _progressStartTime = null;
      _gameCompleted = false;
      _gameStarted = false; // Reset game started flag
      _showStarAnimation = false;
      _starsEarned = 0;
      _gameScore = 0;
      _showScoreDisplay = false;
      _laughLevel = "none";
      _remainingSeconds = 15;
    });
  }void _triggerStarAnimation() {
    setState(() {
      _showStarAnimation = true;
    });
    
    _starAnimationController.reset();
    _starAnimationController.forward();
    
    // Start the star filling animation
    _starFillController.reset();
    _starFillController.forward();
    
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showStarAnimation = false;
        });
      }
    });
  }  @override
  void dispose() {
    _countdownTimer?.cancel();
    _starAnimationController.dispose();
    _starFillController.dispose();
    _progressPulseController.dispose();
    _timerController.dispose();
    if (_isInitialized && _cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
    _faceDetectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always show something to prevent blank screen
    if (_initializationError.isNotEmpty) {
      return _buildErrorScreen();
    }
    
    if (!_isInitialized || !_cameraController.value.isInitialized) {
      return _buildLoadingScreen();
    }    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      appBar: _buildAppBar(),
      body: Column(        children: [
          // Countdown Timer at the top
          if (_gameStarted && !_gameCompleted)
            _buildCountdownTimer(),
          
          // Camera preview with overlays
          Expanded(
            child: Stack(
              children: [
                // Camera preview as base layer
                _buildCameraPreview(),
                  // Debug panel overlay
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: DebugPanel(
                    mouthOpen: _mouthOpen,
                    smileProb: _smileProb,
                    laughLevel: _laughLevel,
                    startTime: _progressStartTime,
                    progress: _smileProgress,
                    gameCompleted: _gameCompleted,
                    starsEarned: _starsEarned,
                  ),
                ),
                  // Progress bar at bottom
                Positioned(
                  bottom: _gameCompleted ? 120 : 60,
                  left: 16,
                  right: 16,
                  child: ProgressBar(
                    progress: _smileProgress,
                    laughLevel: _laughLevel,
                    pulseAnimation: _progressPulseAnimation,
                    colorAnimation: _progressColorAnimation,
                  ),
                ),
                  // Continue button when game is completed
                if (_gameCompleted)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5 - 30,
                    left: MediaQuery.of(context).size.width * 0.5 - 30,
                    child: _buildContinueIconButton(),
                  ),                // Star rating display with animated filling
                if (_gameCompleted)
                  Positioned(
                    bottom: _showScoreDisplay ? 200 : 140,
                    left: 16,
                    right: 16,
                    child: _buildStarRating(),
                  ),
                
                // Game score display
                if (_showScoreDisplay && _gameCompleted)
                  Positioned(
                    bottom: 60,
                    left: 16,
                    right: 16,
                    child: GameScoreDisplay(
                      gameScore: _gameScore,
                      starsEarned: _starsEarned,
                      completionTime: _progressStartTime != null 
                          ? DateTime.now().difference(_progressStartTime!).inSeconds 
                          : 0,
                      speedBonus: _starsEarned == 3 && _progressStartTime != null 
                          ? DateTime.now().difference(_progressStartTime!).inSeconds <= 10 
                          : false,
                    ),
                  ),
                
                // Star animation overlay
                if (_showStarAnimation)
                  CelebrationWidgets.buildStarAnimation(
                    showAnimation: _showStarAnimation,
                    scaleAnimation: _starScaleAnimation,
                    controller: _starAnimationController,
                  ),
                
                // Celebration message
                if (_showStarAnimation)
                  CelebrationWidgets.buildCelebrationMessage(
                    showAnimation: _showStarAnimation,
                    screenHeight: MediaQuery.of(context).size.height,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_very_satisfied,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              'Preparing Laugh Detector...',
              style: AppTheme.bodyStyle.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              'Camera Error',
              style: AppTheme.titleStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _initializationError,
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initializationError = '';
                  _isInitialized = false;
                });
                _initCamera();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.brown.shade800,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.amber.shade300,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_very_satisfied, color: Colors.brown),
          const SizedBox(width: 8),
          Text(
            'Laugh Detector',
            style: TextStyle(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),      centerTitle: true,
      actions: [
        // Profile button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.person),
          tooltip: 'Profile',
        ),
        // Score widget
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: ScoreWidget(key: _scoreWidgetKey),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraController.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.red.withOpacity(0.3),
        child: const Center(
          child: Text("Camera not initialized", style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      );
    }
    
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.shade400, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),          child: CameraPreview(_cameraController),
        ),
      ),
    );
  }
  Widget _buildContinueIconButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber.shade600, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        onPressed: _resetGame,
        icon: Icon(
          Icons.refresh,
          color: Colors.brown.shade800,
          size: 30,
        ),
      ),
    );
  }
  Widget _buildStarRating() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber.shade100.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCompletionMessage(),
            style: TextStyle(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CelebrationWidgets.buildAnimatedStarFill(
            starsEarned: _starsEarned,
            controller: _starFillController,
            starFillAnimation: _starFillAnimation,
          ),
        ],
      ),
    );
  }  String _getCompletionMessage() {
    switch (_starsEarned) {
      case 3:
        return "Amazing! Perfect laugh! 🎉";
      case 2:
        return "Great job! You reached 75%+ 😊";
      case 1:
        return "Good effort! You reached 50%+ 👍";
      default:
        return "Keep trying! You can do it! 💪";
    }
  }

  Widget _buildCountdownTimer() {
    double progress = _remainingSeconds / 15.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber.shade100.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.amber.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                color: Colors.brown.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Time for 3 Stars: ${_remainingSeconds}s',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.amber.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.3 ? Colors.green : Colors.red.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
