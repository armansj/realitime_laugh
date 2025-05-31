import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math';
import '../services/audio_service.dart';
import '../services/gif_service.dart';
import '../utils/app_theme.dart';
import '../main.dart';
import '../models/face_detection_service.dart';
import '../models/firebase_score_manager.dart';
import '../models/auth_service.dart';

class DontLaughChallengeScreen extends StatefulWidget {
  const DontLaughChallengeScreen({super.key});

  @override
  State<DontLaughChallengeScreen> createState() => _DontLaughChallengeScreenState();
}

class _DontLaughChallengeScreenState extends State<DontLaughChallengeScreen> 
    with TickerProviderStateMixin {  CameraController? _controller;
  late FaceDetectionService _faceDetectionService;
  final GifService _gifService = GifService();
  final Random _random = Random();
  final FirebaseScoreManager _scoreManager = FirebaseScoreManager();
  final AuthService _authService = AuthService();
  
  // Game state
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _currentGifIndex = 0;
  int _score = 0;
  Timer? _gameTimer;
  Timer? _gifTimer;
  int _timeRemaining = 60; // 60 seconds challenge
  int _streak = 0; // Track current streak
  DateTime? _gameStartTime; // Track game start time for duration calculation
  
  // GIF data
  List<GifData> _funnyGifs = [];
  List<int> _shuffledIndices = [];
  int _currentShuffleIndex = 0;
  bool _isLoadingGifs = false;
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _gameOverController;
  late Animation<double> _gameOverAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
    _loadFunnyGifs();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _gameOverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gameOverController, curve: Curves.elasticOut),
    );
    
    _pulseController.repeat(reverse: true);
  }
  Future<void> _initializeServices() async {
    try {
      AudioService.instance.enterGameMode();
      
      // Initialize Firebase score manager
      await _scoreManager.initialize();
      
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        
        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        
        await _controller!.initialize();
        _faceDetectionService = FaceDetectionService();
        
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }  Future<void> _loadFunnyGifs() async {
    setState(() {
      _isLoadingGifs = true;
    });
    
    try {
      // Use the main GIF service method which now uses Tenor API with fallback
      List<GifData> gifs = await _gifService.getFunnyGifs(limit: 20);
      
      setState(() {
        _funnyGifs = gifs;
        _isLoadingGifs = false;
      });
      
      print('Loaded ${_funnyGifs.length} funny GIFs for challenge');
      if (_funnyGifs.isNotEmpty) {
        print('First GIF URL: ${_funnyGifs.first.url}');
        print('Using ${gifs.first.id.contains('fallback') ? 'fallback' : 'API'} GIFs');
      }
    } catch (e) {
      print('Error loading GIFs: $e');
      // Even if there's an error, try to get fallback GIFs
      try {
        final fallbackGifs = await _gifService.fetchFunnyGifsFromTenor(query: 'funny', limit: 5);
        setState(() {
          _funnyGifs = fallbackGifs;
          _isLoadingGifs = false;
        });
      } catch (e2) {
        setState(() {
          _isLoadingGifs = false;
          _funnyGifs = []; // This will show error state in UI
        });
      }
    }
  }  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameOver = false;
      _score = 0;
      _timeRemaining = 60;
      _currentGifIndex = 0;
      _currentShuffleIndex = 0;
      _streak = 0;
      _gameStartTime = DateTime.now(); // Track when the game started
    });
    
    // Create shuffled indices for random GIF order
    _createShuffledIndices();
    
    // Start with a random GIF
    if (_shuffledIndices.isNotEmpty) {
      setState(() {
        _currentGifIndex = _shuffledIndices[0];
        _currentShuffleIndex = 1;
      });
    }
    
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endGame(won: true);
      }
    });
    
    _gifTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      if (_isGameActive && !_isGameOver) {
        _nextGif();
      }
    });
    
    _startFaceDetection();
  }
  void _nextGif() {
    setState(() {
      // If we've reached the end of our shuffled list, create a new shuffle
      if (_currentShuffleIndex >= _shuffledIndices.length) {
        _createShuffledIndices();
        _currentShuffleIndex = 0;
      }
      
      // Use the shuffled index to get a random GIF
      _currentGifIndex = _shuffledIndices[_currentShuffleIndex];
      _currentShuffleIndex++;
      _score += 10;
    });
  }

  void _createShuffledIndices() {
    // Create a list of all available GIF indices
    _shuffledIndices = List.generate(_funnyGifs.length, (index) => index);
    
    // Shuffle the indices to randomize the order
    _shuffledIndices.shuffle(_random);
    
    print('Created new shuffled GIF order: $_shuffledIndices');
  }

  void _startFaceDetection() {
    if (_controller?.value.isInitialized ?? false) {
      _controller!.startImageStream(_processImage);
    }
  }

  void _processImage(CameraImage image) async {
    if (_faceDetectionService.isDetecting || !_isGameActive || _isGameOver) {
      return;
    }
    
    try {
      final faceResult = await _faceDetectionService.analyzeFace(image);
      
      if (_isGameActive && !_isGameOver) {
        bool isLaughing = faceResult.smileProb > 0.6;
        
        if (isLaughing) {
          _stopImageStream();
          _endGame(won: false);
        }
      }
    } catch (e) {
      print('Error analyzing face: $e');
    }
  }

  void _stopImageStream() {
    try {
      _controller?.stopImageStream();
    } catch (e) {
      print('Error stopping image stream: $e');
    }
  }
  void _endGame({required bool won}) {
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });
    
    _gameTimer?.cancel();
    _gifTimer?.cancel();
    _stopImageStream();
    
    // Calculate challenge duration
    double challengeDuration = 0.0;
    if (_gameStartTime != null) {
      challengeDuration = DateTime.now().difference(_gameStartTime!).inSeconds.toDouble();
    }
    
    // Update streak based on win/loss
    if (won) {
      _streak++; // Increase streak for winning
      AudioService.instance.playCrowdLaugh();
      _score += 100;
    } else {
      _streak = 0; // Reset streak on loss
      AudioService.instance.playTimesUpVibration();
    }
    
    // Add challenge result to Firebase scoring system
    _addChallengeResult(won, challengeDuration);
    
    _gameOverController.forward();
    
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
  
  // Add challenge result to Firebase scoring system
  Future<void> _addChallengeResult(bool won, double challengeDuration) async {
    try {
      await _scoreManager.addDontLaughChallengeResult(
        won: won,
        streak: _streak,
        challengeDuration: challengeDuration,
      );
      
      // Award money and stars for completing the challenge
      if (won) {
        await _authService.addMoney(20); // 20 money for winning
        await _authService.addStars(2); // 2 stars for winning
      } else {
        await _authService.addMoney(5); // 5 money for participation
      }
      
      print('Challenge result added to scoring system: won=$won, streak=$_streak, duration=${challengeDuration}s');
    } catch (e) {
      print('Error adding challenge result: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gameOverController.dispose();
    _gameTimer?.cancel();
    _gifTimer?.cancel();
    _stopImageStream();
    _controller?.dispose();
    _faceDetectionService.dispose();
    AudioService.instance.exitGameMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller?.value.isInitialized ?? false)
            Positioned.fill(
              child: CameraPreview(_controller!),
            ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildTopUI(),
                    Spacer(),
                    if (!_isGameActive && !_isGameOver)
                      _buildStartScreen()
                    else if (_isGameActive)
                      _buildGameContent()
                    else if (_isGameOver)
                      _buildGameOverScreen(),
                    Spacer(),
                    if (_isGameActive) _buildBottomUI(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUI() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          Spacer(),
          if (_isGameActive) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Time: $_timeRemaining s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _timeRemaining <= 10 ? Colors.red : Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Don't Laugh Challenge",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Icon(
            Icons.mood,
            size: 80,
            color: AppTheme.accentOrange,
          ),
          SizedBox(height: 20),
          if (_isLoadingGifs) ...[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
            ),
            SizedBox(height: 10),
            Text(
              'Loading funny content...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ] else if (_funnyGifs.isEmpty) ...[
            Icon(
              Icons.wifi_off,
              size: 60,
              color: Colors.red[400],
            ),
            SizedBox(height: 15),
            Text(
              'Unable to load GIFs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your internet connection\nand try again later.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadFunnyGifs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Retry Loading',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),              ),
            ),
          ] else ...[
            Text(
              'Rules:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '• Try not to laugh for 60 seconds\n'
              '• Hilarious GIFs will be shown\n'
              '• Camera will detect if you laugh\n'
              '• Get points for each GIF you survive!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: ElevatedButton(
                    onPressed: _funnyGifs.isNotEmpty ? _startGame : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _funnyGifs.isNotEmpty ? 'Start Challenge' : 'Loading...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildGameContent() {
    if (_funnyGifs.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Image.network(
                  _funnyGifs[_currentGifIndex].url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 50, color: Colors.grey[600]),
                          SizedBox(height: 10),
                          Text(
                            'Failed to load GIF',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return AnimatedBuilder(
      animation: _gameOverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _gameOverAnimation.value,
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _score >= 100 ? Icons.emoji_events : Icons.sentiment_satisfied,
                  size: 80,
                  color: _score >= 100 ? AppTheme.primaryYellow : AppTheme.accentOrange,
                ),
                SizedBox(height: 20),
                Text(
                  _score >= 100 ? 'Congratulations!' : 'Good Try!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _score >= 100 
                    ? 'You completed the challenge!'
                    : 'You laughed! Better luck next time.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Final Score: $_score',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Back to Challenges',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildBottomUI() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DON\'T LAUGH!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Camera is watching for smiles...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _endGame(won: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              'Give Up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
