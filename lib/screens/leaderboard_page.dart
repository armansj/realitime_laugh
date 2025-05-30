import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for demonstration
  final List<LeaderboardEntry> _globalLeaderboard = [
    LeaderboardEntry(rank: 1, username: 'LaughMaster', score: 15420, avatar: '😂'),
    LeaderboardEntry(rank: 2, username: 'GiggleQueen', score: 14890, avatar: '😄'),
    LeaderboardEntry(rank: 3, username: 'ChuckleChamp', score: 14205, avatar: '😆'),
    LeaderboardEntry(rank: 4, username: 'ComedyKing', score: 13950, avatar: '🤣'),
    LeaderboardEntry(rank: 5, username: 'HahaHero', score: 13720, avatar: '😁'),
    LeaderboardEntry(rank: 6, username: 'JokeStar', score: 13420, avatar: '😊'),
    LeaderboardEntry(rank: 7, username: 'FunnyBone', score: 13100, avatar: '😸'),
    LeaderboardEntry(rank: 8, username: 'SmileMaker', score: 12890, avatar: '😃'),
    LeaderboardEntry(rank: 9, username: 'LolLord', score: 12650, avatar: '🙂'),
    LeaderboardEntry(rank: 10, username: 'GrinGuru', score: 12400, avatar: '😋'),
  ];
  
  final List<LeaderboardEntry> _weeklyLeaderboard = [
    LeaderboardEntry(rank: 1, username: 'WeekWarrior', score: 2850, avatar: '🏆'),
    LeaderboardEntry(rank: 2, username: 'DailyLaugher', score: 2640, avatar: '⭐'),
    LeaderboardEntry(rank: 3, username: 'QuickSmile', score: 2420, avatar: '🎯'),
    LeaderboardEntry(rank: 4, username: 'FastFunny', score: 2280, avatar: '🚀'),
    LeaderboardEntry(rank: 5, username: 'SpeedGiggle', score: 2150, avatar: '⚡'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Time'),
            Tab(text: 'This Week'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.accentOrange.withOpacity(0.1),
              AppTheme.primaryYellow.withOpacity(0.1),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLeaderboardList(_globalLeaderboard),
            _buildLeaderboardList(_weeklyLeaderboard),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    return Column(
      children: [
        // Top 3 podium
        if (entries.length >= 3) _buildPodium(entries.take(3).toList()),
        
        // Rest of the list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length > 3 ? entries.length - 3 : 0,
            itemBuilder: (context, index) {
              return _buildLeaderboardTile(entries[index + 3]);
            },
          ),
        ),
      ],
    );
  }
  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 250,
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _buildPodiumPlace(topThree[1], 2, 120)),
          // 1st place
          Expanded(child: _buildPodiumPlace(topThree[0], 1, 140)),
          // 3rd place
          Expanded(child: _buildPodiumPlace(topThree[2], 3, 100)),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int place, double height) {
    Color podiumColor;
    IconData crownIcon;
    
    switch (place) {
      case 1:
        podiumColor = Colors.amber;
        crownIcon = Icons.workspace_premium;
        break;
      case 2:
        podiumColor = Colors.grey[400]!;
        crownIcon = Icons.military_tech;
        break;
      case 3:
        podiumColor = Colors.brown[400]!;
        crownIcon = Icons.emoji_events;
        break;
      default:
        podiumColor = Colors.grey;
        crownIcon = Icons.star;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [        // Avatar and crown
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: podiumColor.withOpacity(0.2),
                border: Border.all(color: podiumColor, width: 2),
              ),
              child: Center(
                child: Text(
                  entry.avatar,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            Icon(
              crownIcon,
              color: podiumColor,
              size: 16,
            ),
          ],
        ),
          const SizedBox(height: 4),
        // Username
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            entry.username,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Score
        Text(
          '${entry.score}',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 4),
        
        // Podium base
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                podiumColor.withOpacity(0.8),
                podiumColor,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: podiumColor.withOpacity(0.6), width: 1),
          ),          child: Center(
            child: Text(
              '#$place',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryYellow.withOpacity(0.2),
            border: Border.all(color: AppTheme.accentOrange, width: 1),
          ),
          child: Center(
            child: Text(
              entry.avatar,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentOrange.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.score}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String username;
  final int score;
  final String avatar;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.score,
    required this.avatar,
  });
}
