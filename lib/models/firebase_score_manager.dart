import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class FirebaseScoreManager {
  static final FirebaseScoreManager _instance = FirebaseScoreManager._internal();
  factory FirebaseScoreManager() => _instance;
  FirebaseScoreManager._internal();

  final AuthService _authService = AuthService();
  
  // Cached values for offline support
  int _cachedTotalScore = 0;
  int _cachedUserLevel = 1;
  int _cachedGamesPlayed = 0;
  int _cachedThreeStarGames = 0;
  int _cachedTotalLaughTime = 0;
  
  // Challenge-related cached values
  int _cachedChallengesCompleted = 0;
  int _cachedDontLaughWins = 0;
  int _cachedChallengeScore = 0;
  int _cachedBestDontLaughStreak = 0;
  
  bool _isInitialized = false;

  // Initialize score manager - load from Firebase or local cache
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {      // Try to load from Firebase first
      if (_authService.currentUser != null) {
        final userData = await _authService.getUserData();
        if (userData != null) {
          _cachedTotalScore = userData['totalScore'] ?? 0;
          _cachedUserLevel = userData['userLevel'] ?? 1;
          _cachedGamesPlayed = userData['gamesPlayed'] ?? 0;
          _cachedThreeStarGames = userData['threeStarGames'] ?? 0;
          _cachedTotalLaughTime = userData['totalLaughTime'] ?? 0;
          
          // Load challenge data
          _cachedChallengesCompleted = userData['challengesCompleted'] ?? 0;
          _cachedDontLaughWins = userData['dontLaughWins'] ?? 0;
          _cachedChallengeScore = userData['challengeScore'] ?? 0;
          _cachedBestDontLaughStreak = userData['bestDontLaughStreak'] ?? 0;
          
          // Also save to local cache for offline support
          await _saveToLocalCache();
          _isInitialized = true;
          return;
        }
      }
      
      // Fallback to local cache if Firebase is not available
      await _loadFromLocalCache();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing FirebaseScoreManager: $e');
      // Fallback to local cache
      await _loadFromLocalCache();
      _isInitialized = true;
    }
  }

  // Load scores from SharedPreferences (offline fallback)
  Future<void> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedTotalScore = prefs.getInt('totalScore') ?? 0;
    _cachedUserLevel = prefs.getInt('userLevel') ?? 1;
    _cachedGamesPlayed = prefs.getInt('gamesPlayed') ?? 0;
    _cachedThreeStarGames = prefs.getInt('threeStarGames') ?? 0;
    _cachedTotalLaughTime = prefs.getInt('totalLaughTime') ?? 0;
    
    // Load challenge-related cached values
    _cachedChallengesCompleted = prefs.getInt('challengesCompleted') ?? 0;
    _cachedDontLaughWins = prefs.getInt('dontLaughWins') ?? 0;
    _cachedChallengeScore = prefs.getInt('challengeScore') ?? 0;
    _cachedBestDontLaughStreak = prefs.getInt('bestDontLaughStreak') ?? 0;
  }

  // Save scores to SharedPreferences (offline cache)
  Future<void> _saveToLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalScore', _cachedTotalScore);
    await prefs.setInt('userLevel', _cachedUserLevel);
    await prefs.setInt('gamesPlayed', _cachedGamesPlayed);
    await prefs.setInt('threeStarGames', _cachedThreeStarGames);
    await prefs.setInt('totalLaughTime', _cachedTotalLaughTime);
    
    // Save challenge-related cached values
    await prefs.setInt('challengesCompleted', _cachedChallengesCompleted);
    await prefs.setInt('dontLaughWins', _cachedDontLaughWins);
    await prefs.setInt('challengeScore', _cachedChallengeScore);
    await prefs.setInt('bestDontLaughStreak', _cachedBestDontLaughStreak);
  }

  // Add game result and sync with Firebase
  Future<void> addGameResult({
    required int starsEarned,
    required double completionTime,
    required double laughDuration,
  }) async {
    await initialize();
    
    // Calculate score based on performance
    int gameScore = _calculateGameScore(starsEarned, completionTime, laughDuration);
    
    // Update cached values
    _cachedTotalScore += gameScore;
    _cachedGamesPlayed++;
    _cachedTotalLaughTime += laughDuration.round();
    
    if (starsEarned == 3) {
      _cachedThreeStarGames++;
    }
    
    // Update level based on total score
    _cachedUserLevel = _calculateLevel(_cachedTotalScore);
    
    // Save to local cache immediately
    await _saveToLocalCache();
    
    // Try to sync with Firebase
    try {
      if (_authService.currentUser != null) {
        await _authService.updateUserScore(
          totalScore: _cachedTotalScore,
          userLevel: _cachedUserLevel,
          gamesPlayed: _cachedGamesPlayed,
          threeStarGames: _cachedThreeStarGames,
          totalLaughTime: _cachedTotalLaughTime,
        );
        
        // Also save individual game result
        await _authService.saveGameResult(
          starsEarned: starsEarned,
          gameScore: gameScore,
          completionTimeSeconds: completionTime.round(),
          laughDurationSeconds: laughDuration.round(),
        );
      }
    } catch (e) {
      print('Error syncing with Firebase: $e');
      // Continue with local cache - will sync later when online
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

  // Calculate user level based on total score
  int _calculateLevel(int totalScore) {
    // Level progression: 0-500(1), 500-1200(2), 1200-2000(3), etc.
    if (totalScore < 500) return 1;
    if (totalScore < 1200) return 2;
    if (totalScore < 2000) return 3;
    if (totalScore < 3000) return 4;
    if (totalScore < 4500) return 5;
    if (totalScore < 6500) return 6;
    if (totalScore < 9000) return 7;
    if (totalScore < 12500) return 8;
    if (totalScore < 17000) return 9;
    return 10; // Max level
  }

  // Get current scores
  Future<Map<String, dynamic>> getCurrentScores() async {
    await initialize();
    
    return {
      'totalScore': _cachedTotalScore,
      'userLevel': _cachedUserLevel,
      'gamesPlayed': _cachedGamesPlayed,
      'threeStarGames': _cachedThreeStarGames,
      'totalLaughTime': _cachedTotalLaughTime,
      'nextLevelScore': _getNextLevelScore(_cachedUserLevel),
      'currentLevelProgress': _getCurrentLevelProgress(_cachedTotalScore, _cachedUserLevel),
      // Challenge-related scores
      'challengesCompleted': _cachedChallengesCompleted,
      'dontLaughWins': _cachedDontLaughWins,
      'challengeScore': _cachedChallengeScore,
      'bestDontLaughStreak': _cachedBestDontLaughStreak,
    };
  }

  // Get score needed for next level
  int _getNextLevelScore(int currentLevel) {
    switch (currentLevel) {
      case 1: return 500;
      case 2: return 1200;
      case 3: return 2000;
      case 4: return 3000;
      case 5: return 4500;
      case 6: return 6500;
      case 7: return 9000;
      case 8: return 12500;
      case 9: return 17000;
      default: return 17000; // Max level
    }
  }

  // Get current level progress (0.0 to 1.0)
  double _getCurrentLevelProgress(int totalScore, int level) {
    int currentLevelStart = _getLevelStartScore(level);
    int nextLevelStart = _getNextLevelScore(level);
    
    if (level >= 10) return 1.0; // Max level
    
    int progress = totalScore - currentLevelStart;
    int levelRange = nextLevelStart - currentLevelStart;
    
    return (progress / levelRange).clamp(0.0, 1.0);
  }

  // Get score where current level starts
  int _getLevelStartScore(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 500;
      case 3: return 1200;
      case 4: return 2000;
      case 5: return 3000;
      case 6: return 4500;
      case 7: return 6500;
      case 8: return 9000;
      case 9: return 12500;
      case 10: return 17000;
      default: return 0;
    }
  }

  // Add Don't Laugh Challenge result
  Future<void> addDontLaughChallengeResult({
    required bool won,
    required int streak,
    required double challengeDuration,
  }) async {
    await initialize();
    
    // Update challenge-specific stats
    _cachedChallengesCompleted++;
    if (won) {
      _cachedDontLaughWins++;
    }
    
    // Update best streak if this one is better
    if (streak > _cachedBestDontLaughStreak) {
      _cachedBestDontLaughStreak = streak;
    }
    
    // Calculate challenge score
    int challengePoints = _calculateChallengeScore(won, streak, challengeDuration);
    _cachedChallengeScore += challengePoints;
    
    // Add challenge points to total score for overall progression
    _cachedTotalScore += challengePoints;
    
    // Recalculate level
    _cachedUserLevel = _calculateLevel(_cachedTotalScore);
    
    // Save to local cache
    await _saveToLocalCache();
    
    // Try to update Firebase
    try {
      if (_authService.currentUser != null) {
        await _authService.updateUserScore(
          totalScore: _cachedTotalScore,
          userLevel: _cachedUserLevel,
          gamesPlayed: _cachedGamesPlayed,
          threeStarGames: _cachedThreeStarGames,
          totalLaughTime: _cachedTotalLaughTime,
        );
        
        // Update challenge-specific data in Firebase
        await _authService.updateChallengeData(
          challengesCompleted: _cachedChallengesCompleted,
          dontLaughWins: _cachedDontLaughWins,
          challengeScore: _cachedChallengeScore,
          bestDontLaughStreak: _cachedBestDontLaughStreak,
        );
        
        print('Successfully updated challenge data in Firebase');
      }
    } catch (e) {
      print('Error updating Firebase with challenge data: $e');
    }
  }
  
  // Calculate score for challenge completion
  int _calculateChallengeScore(bool won, int streak, double challengeDuration) {
    int baseScore = won ? 200 : 50; // Base points for attempting/winning
    
    // Streak bonus (up to 100 points)
    int streakBonus = (streak * 20).clamp(0, 100);
    
    // Duration bonus for longer challenges (up to 50 points)
    int durationBonus = (challengeDuration / 10 * 10).round().clamp(0, 50);
    
    return baseScore + streakBonus + durationBonus;
  }
  
  // Add general challenge completion
  Future<void> addChallengeCompletion({
    required String challengeType,
    required bool completed,
    required int score,
  }) async {
    await initialize();
    
    _cachedChallengesCompleted++;
    _cachedChallengeScore += score;
    _cachedTotalScore += score;
    
    // Recalculate level
    _cachedUserLevel = _calculateLevel(_cachedTotalScore);
    
    // Save to local cache
    await _saveToLocalCache();
    
    // Try to update Firebase
    try {
      if (_authService.currentUser != null) {
        await _authService.updateUserScore(
          totalScore: _cachedTotalScore,
          userLevel: _cachedUserLevel,
          gamesPlayed: _cachedGamesPlayed,
          threeStarGames: _cachedThreeStarGames,
          totalLaughTime: _cachedTotalLaughTime,
        );
        
        await _authService.updateChallengeData(
          challengesCompleted: _cachedChallengesCompleted,
          dontLaughWins: _cachedDontLaughWins,
          challengeScore: _cachedChallengeScore,
          bestDontLaughStreak: _cachedBestDontLaughStreak,
        );
      }
    } catch (e) {
      print('Error updating Firebase with challenge data: $e');
    }
  }

  // Reset scores (for testing)
  Future<void> resetScores() async {
    _cachedTotalScore = 0;
    _cachedUserLevel = 1;
    _cachedGamesPlayed = 0;
    _cachedThreeStarGames = 0;
    _cachedTotalLaughTime = 0;
    
    // Reset challenge-related cached values
    _cachedChallengesCompleted = 0;
    _cachedDontLaughWins = 0;
    _cachedChallengeScore = 0;
    _cachedBestDontLaughStreak = 0;
    
    await _saveToLocalCache();
    
    // Try to reset in Firebase too
    try {
      if (_authService.currentUser != null) {
        await _authService.updateUserScore(
          totalScore: 0,
          userLevel: 1,
          gamesPlayed: 0,
          threeStarGames: 0,
          totalLaughTime: 0,
        );
      }
    } catch (e) {
      print('Error resetting Firebase scores: $e');
    }
  }

  // Sync local scores with Firebase (useful when coming back online)
  Future<void> syncWithFirebase() async {
    try {
      if (_authService.currentUser != null) {
        await _authService.updateUserScore(
          totalScore: _cachedTotalScore,
          userLevel: _cachedUserLevel,
          gamesPlayed: _cachedGamesPlayed,
          threeStarGames: _cachedThreeStarGames,
          totalLaughTime: _cachedTotalLaughTime,
        );
        print('Successfully synced scores with Firebase');
      }
    } catch (e) {
      print('Error syncing with Firebase: $e');
    }
  }

  // Get user's game history from Firebase
  Future<List<Map<String, dynamic>>> getGameHistory({int limit = 20}) async {
    try {
      if (_authService.currentUser != null) {
        return await _authService.getGameHistory(limit: limit);
      }
      return [];
    } catch (e) {
      print('Error getting game history: $e');
      return [];
    }
  }

  // Getters for easy access
  int get totalScore => _cachedTotalScore;
  int get userLevel => _cachedUserLevel;
  int get gamesPlayed => _cachedGamesPlayed;
  int get threeStarGames => _cachedThreeStarGames;
  int get totalLaughTime => _cachedTotalLaughTime;
  int get challengesCompleted => _cachedChallengesCompleted;
  int get dontLaughWins => _cachedDontLaughWins;
  int get challengeScore => _cachedChallengeScore;
  int get bestDontLaughStreak => _cachedBestDontLaughStreak;
}
