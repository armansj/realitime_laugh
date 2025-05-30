import 'package:flutter/material.dart';
import '../models/firebase_score_manager.dart';
import '../models/auth_service.dart';
import '../utils/app_theme.dart';

class ScoreWidget extends StatefulWidget {
  final bool showDetailed;
  final VoidCallback? onScoreUpdate; // Add callback for score updates
  
  const ScoreWidget({
    super.key,
    this.showDetailed = false,
    this.onScoreUpdate,
  });

  @override
  ScoreWidgetState createState() => ScoreWidgetState();
}

class ScoreWidgetState extends State<ScoreWidget> {
  FirebaseScoreManager? _scoreManager;
  AuthService? _authService;
  int _totalScore = 0;
  int _userLevel = 1;
  double _progressToNextLevel = 0.0;
  int _gamesPlayed = 0;
  int _threeStarGames = 0;
  int _userMoney = 0;

  @override
  void initState() {
    super.initState();
    _loadScoreData();
  }
  // Add method to refresh score data
  Future<void> refreshScoreData() async {
    await _loadScoreData();
  }

  Future<void> _loadScoreData() async {
    _scoreManager = FirebaseScoreManager();
    _authService = AuthService();
    
    // Load score data
    final scores = await _scoreManager!.getCurrentScores();
    
    // Load user data including money
    final userData = await _authService!.getUserData();
    
    setState(() {
      _totalScore = scores['totalScore'];
      _userLevel = scores['userLevel'];
      _progressToNextLevel = scores['currentLevelProgress'];
      _gamesPlayed = scores['gamesPlayed'];
      _threeStarGames = scores['threeStarGames'];
      _userMoney = userData?['money'] ?? 0;
    });
    
    // Call the callback if provided
    widget.onScoreUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_scoreManager == null) {
      return const SizedBox.shrink();
    }

    if (widget.showDetailed) {
      return _buildDetailedScoreCard();
    } else {
      return _buildCompactScoreDisplay();
    }
  }

  Widget _buildCompactScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade100.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            'Lv.$_userLevel',
            style: TextStyle(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.monetization_on,
            color: Colors.amber.shade700,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$_userMoney',
            style: TextStyle(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Player Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Level and Score
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Level',
                  '$_userLevel',
                  Icons.stars,
                  Colors.purple.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Score',
                  '$_totalScore',
                  Icons.monetization_on,
                  Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress to next level
          if (_userLevel < 10) ...[
            Text(
              'Progress to Level ${_userLevel + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade700,
              ),
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
                  value: _progressToNextLevel,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(_progressToNextLevel * 100).toInt()}% complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown.shade600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Games stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Games',
                  '$_gamesPlayed',
                  Icons.games,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '3-Stars',
                  '$_threeStarGames',
                  Icons.star,
                  Colors.orange.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.brown.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class GameScoreDisplay extends StatelessWidget {
  final int gameScore;
  final int starsEarned;
  final int completionTime;
  final bool speedBonus;
  
  const GameScoreDisplay({
    super.key,
    required this.gameScore,
    required this.starsEarned,
    required this.completionTime,
    this.speedBonus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber.shade700,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '+$gameScore Points!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Score breakdown
          _buildScoreRow('Stars Earned', '$starsEarned × 50', starsEarned * 50),
          if (starsEarned == 3)
            _buildScoreRow('3-Star Bonus', '', 100),
          if (speedBonus)
            _buildScoreRow('Speed Bonus', '< 10 sec', 200),
          _buildScoreRow('Time Bonus', '${completionTime}s', completionTime * 5),
          
          const Divider(color: Colors.amber),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Score:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              Text(
                '+$gameScore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String detail, int points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown.shade700,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($detail)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '+$points',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
