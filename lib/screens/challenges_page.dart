import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'dont_laugh_challenge_screen.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startDontLaughChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DontLaughChallengeScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Challenges',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.accentOrange,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryYellow.withOpacity(0.8),
              AppTheme.accentOrange.withOpacity(0.6),
              AppTheme.primaryYellow,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Challenge',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Test your skills with different game modes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 1,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildChallengeCard(
                          title: "Don't Laugh Challenge",
                          description: "Try not to laugh while watching funny content!",
                          icon: Icons.mood,
                          color: Colors.red,
                          difficulty: "Hard",
                          onTap: _startDontLaughChallenge,
                        ),
                        _buildChallengeCard(
                          title: "Speed Laugh",
                          description: "Laugh as many times as possible in 30 seconds",
                          icon: Icons.timer,
                          color: Colors.blue,
                          difficulty: "Medium",
                          onTap: () {
                            // TODO: Implement speed laugh challenge
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Coming Soon!')),
                            );
                          },
                        ),
                        _buildChallengeCard(
                          title: "Endurance Mode",
                          description: "Keep laughing for as long as possible",
                          icon: Icons.fitness_center,
                          color: Colors.green,
                          difficulty: "Expert",
                          onTap: () {
                            // TODO: Implement endurance mode
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Coming Soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String difficulty,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black26,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
