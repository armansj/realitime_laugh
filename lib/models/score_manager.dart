import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _scoreKey = 'laugh_detector_score';
  static const String _gamesPlayedKey = 'games_played';
  static const String _threeStarGamesKey = 'three_star_games';
  static const String _totalLaughTimeKey = 'total_laugh_time';
  
  // Score values for different achievements
  static const int scorePerStar = 50;
  static const int bonusThreeStars = 100; // Bonus for getting 3 stars
  static const int bonusSpeedCompletion = 200; // Bonus for completing under 10 seconds
  static const int scorePerSecondLaughing = 5; // Score for sustained laughing

  static ScoreManager? _instance;
  late SharedPreferences _prefs;
  
  ScoreManager._();
  
  static Future<ScoreManager> getInstance() async {
    _instance ??= ScoreManager._();
    _instance!._prefs = await SharedPreferences.getInstance();
    return _instance!;
  }

  // Get current total score
  int getTotalScore() {
    return _prefs.getInt(_scoreKey) ?? 0;
  }

  // Get games played
  int getGamesPlayed() {
    return _prefs.getInt(_gamesPlayedKey) ?? 0;
  }

  // Get three star games
  int getThreeStarGames() {
    return _prefs.getInt(_threeStarGamesKey) ?? 0;
  }

  // Get total laugh time
  int getTotalLaughTime() {
    return _prefs.getInt(_totalLaughTimeKey) ?? 0;
  }

  // Calculate score for a completed game
  int calculateGameScore({
    required int starsEarned,
    required int completionTimeSeconds,
    required int laughDurationSeconds,
  }) {
    int gameScore = 0;
    
    // Base score for stars
    gameScore += starsEarned * scorePerStar;
    
    // Bonus for three stars
    if (starsEarned == 3) {
      gameScore += bonusThreeStars;
    }
    
    // Speed bonus for completing under 10 seconds
    if (completionTimeSeconds <= 10 && starsEarned == 3) {
      gameScore += bonusSpeedCompletion;
    }
    
    // Score for sustained laughing
    gameScore += laughDurationSeconds * scorePerSecondLaughing;
    
    return gameScore;
  }

  // Add score from a completed game
  Future<int> addGameScore({
    required int starsEarned,
    required int completionTimeSeconds,
    required int laughDurationSeconds,
  }) async {
    int gameScore = calculateGameScore(
      starsEarned: starsEarned,
      completionTimeSeconds: completionTimeSeconds,
      laughDurationSeconds: laughDurationSeconds,
    );
    
    // Update totals
    int currentScore = getTotalScore();
    int currentGamesPlayed = getGamesPlayed();
    int currentThreeStarGames = getThreeStarGames();
    int currentLaughTime = getTotalLaughTime();
    
    await _prefs.setInt(_scoreKey, currentScore + gameScore);
    await _prefs.setInt(_gamesPlayedKey, currentGamesPlayed + 1);
    
    if (starsEarned == 3) {
      await _prefs.setInt(_threeStarGamesKey, currentThreeStarGames + 1);
    }
    
    await _prefs.setInt(_totalLaughTimeKey, currentLaughTime + laughDurationSeconds);
    
    return gameScore;
  }

  // Get user level based on score
  int getUserLevel() {
    int score = getTotalScore();
    if (score < 500) return 1;
    if (score < 1500) return 2;
    if (score < 3000) return 3;
    if (score < 5000) return 4;
    if (score < 8000) return 5;
    if (score < 12000) return 6;
    if (score < 18000) return 7;
    if (score < 25000) return 8;
    if (score < 35000) return 9;
    return 10; // Max level
  }

  // Get score needed for next level
  int getScoreForNextLevel() {
    int currentLevel = getUserLevel();
    switch (currentLevel) {
      case 1: return 500;
      case 2: return 1500;
      case 3: return 3000;
      case 4: return 5000;
      case 5: return 8000;
      case 6: return 12000;
      case 7: return 18000;
      case 8: return 25000;
      case 9: return 35000;
      default: return 35000; // Max level reached
    }
  }

  // Get progress to next level (0.0 to 1.0)
  double getProgressToNextLevel() {
    int currentLevel = getUserLevel();
    if (currentLevel >= 10) return 1.0; // Max level
    
    int currentScore = getTotalScore();
    int currentLevelMinScore = currentLevel == 1 ? 0 : getScoreForLevel(currentLevel);
    int nextLevelScore = getScoreForNextLevel();
    
    return (currentScore - currentLevelMinScore) / (nextLevelScore - currentLevelMinScore);
  }

  // Get minimum score for a specific level
  int getScoreForLevel(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 500;
      case 3: return 1500;
      case 4: return 3000;
      case 5: return 5000;
      case 6: return 8000;
      case 7: return 12000;
      case 8: return 18000;
      case 9: return 25000;
      case 10: return 35000;
      default: return 0;
    }
  }

  // Reset all scores (for testing)
  Future<void> resetAllScores() async {
    await _prefs.remove(_scoreKey);
    await _prefs.remove(_gamesPlayedKey);
    await _prefs.remove(_threeStarGamesKey);
    await _prefs.remove(_totalLaughTimeKey);
  }

  // Get achievements status
  Map<String, bool> getAchievements() {
    int gamesPlayed = getGamesPlayed();
    int threeStarGames = getThreeStarGames();
    int totalScore = getTotalScore();
    int level = getUserLevel();
    
    return {
      'first_game': gamesPlayed >= 1,
      'ten_games': gamesPlayed >= 10,
      'fifty_games': gamesPlayed >= 50,
      'first_three_stars': threeStarGames >= 1,
      'ten_three_stars': threeStarGames >= 10,
      'score_1000': totalScore >= 1000,
      'score_5000': totalScore >= 5000,
      'score_10000': totalScore >= 10000,
      'level_5': level >= 5,
      'level_10': level >= 10,
    };
  }
}
