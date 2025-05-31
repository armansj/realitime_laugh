import 'package:flutter/material.dart';
import '../models/auth_service.dart';
import '../models/firebase_score_manager.dart';
import '../utils/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseScoreManager _scoreManager = FirebaseScoreManager();
  
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _scoreData;
  List<Map<String, dynamic>> _gameHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();
      final scoreData = await _scoreManager.getCurrentScores();
      final gameHistory = await _scoreManager.getGameHistory(limit: 10);

      setState(() {
        _userData = userData;
        _scoreData = scoreData;
        _gameHistory = gameHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          // AuthWrapper will handle navigation back to login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryYellow,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Profile Picture
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryYellow,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(                              child: StreamBuilder<String>(
                                stream: _authService.getUserEmojiProfileStream(),
                                builder: (context, emojiSnapshot) {
                                  final emojiProfile = emojiSnapshot.data ?? '😂';
                                  
                                  return Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryYellow.withOpacity(0.2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emojiProfile,
                                        style: const TextStyle(fontSize: 36),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // User Details
                            Text(
                              _userData?['username'] ?? 'No username',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              user?.displayName ?? 'No display name',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            
                            Text(
                              user?.email ?? 'No email',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Card
                    const Text(
                      'Your Stats 📊',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _scoreData != null
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem(
                                        'Level',
                                        '${_scoreData!['userLevel']}',
                                        Icons.star,
                                      ),
                                      _buildStatItem(
                                        'Total Score',
                                        '${_scoreData!['totalScore']}',
                                        Icons.score,
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem(
                                        'Games Played',
                                        '${_scoreData!['gamesPlayed']}',
                                        Icons.videogame_asset,
                                      ),
                                      _buildStatItem(
                                        '3-Star Games',
                                        '${_scoreData!['threeStarGames']}',
                                        Icons.emoji_events,
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                    _buildStatItem(
                                    'Total Laugh Time',
                                    '${_scoreData!['totalLaughTime']}s',
                                    Icons.timer,
                                    isFullWidth: true,
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Challenge Statistics Section
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Challenge Statistics',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildStatItem(
                                              'Challenges Completed',
                                              '${_scoreData!['challengesCompleted'] ?? 0}',
                                              Icons.emoji_events,
                                            ),
                                            _buildStatItem(
                                              'Don\'t Laugh Wins',
                                              '${_scoreData!['dontLaughWins'] ?? 0}',
                                              Icons.psychology,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildStatItem(
                                              'Challenge Score',
                                              '${_scoreData!['challengeScore'] ?? 0}',
                                              Icons.military_tech,
                                            ),
                                            _buildStatItem(
                                              'Best Streak',
                                              '${_scoreData!['bestDontLaughStreak'] ?? 0}',
                                              Icons.trending_up,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: Text('No stats available')),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Games
                    const Text(
                      'Recent Games 🎮',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _gameHistory.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('No games played yet'),
                              ),
                            ),
                          )
                        : Column(
                            children: _gameHistory.map((game) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryYellow,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${game['starsEarned'] ?? 0}⭐',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text('${game['gameScore'] ?? 0} points'),
                                  subtitle: Text(
                                    'Completed in ${game['completionTimeSeconds'] ?? 0}s • '
                                    'Laughed for ${game['laughDurationSeconds'] ?? 0}s',
                                  ),
                                  trailing: game['playedAt'] != null
                                      ? Text(
                                          _formatDate(game['playedAt']),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {bool isFullWidth = false}) {
    return Expanded(
      flex: isFullWidth ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.accentOrange,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return '';
      
      DateTime date;
      if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp.toString().contains('Timestamp')) {
        // Firebase Timestamp
        date = timestamp.toDate();
      } else {
        return 'Recent';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recent';
    }
  }
}
