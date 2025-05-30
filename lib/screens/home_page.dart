import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_service.dart';
import '../utils/app_theme.dart';
import 'laugh_detector_page_simple.dart';
import 'shop_page.dart';
import 'settings_page.dart';
import 'leaderboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  // Add button animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _buttonPressController;
  late Animation<double> _buttonScaleAnimation;
  @override
  void initState() {
    super.initState();
    
    // Animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Button pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Button press animation
    _buttonPressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
    _slideController.forward();
    
    // Start pulse animation and repeat
    _pulseController.repeat(reverse: true);
    
    // Initialize location on first app load
    _initializeLocationIfNeeded();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }
  
  void _startGame() async {
    // Button press animation
    await _buttonPressController.forward();
    await _buttonPressController.reverse();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LaughDetectorPageSimple()),
    );
  }

  void _openShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopPage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _openLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
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
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
            stream: _authService.getUserDataStream(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data();
              final isLoading = snapshot.connectionState == ConnectionState.waiting;
              
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
              
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Top Section - Profile & Stats
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildProfileSection(user, userData),
                      ),
                    ),
                    
                    // Game Stats Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildStatsSection(userData),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Start Game Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildStartGameButton(),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Menu Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildMenuGrid(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }  Widget _buildProfileSection(User? user, Map<String, dynamic>? userData) {
    return GestureDetector(
      onDoubleTap: () => _refreshLocation(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [            // Profile Picture with Country Flag
            StreamBuilder<String>(
              stream: _authService.getUserEmojiProfileStream(),
              builder: (context, emojiSnapshot) {
                final countryCode = userData?['countryCode'] ?? 'us';
                final emojiProfile = emojiSnapshot.data ?? '😂';
                
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentOrange, width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Emoji profile picture
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryYellow.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            emojiProfile,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      // Country flag in bottom right corner
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: AppTheme.accentOrange, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              _getCountryFlag(countryCode),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 15),
            // User Info and Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  userData?['username'] ?? user?.displayName ?? 'Player',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${userData?['userLevel'] ?? 1}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Stars and Money display
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${userData?['stars'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.monetization_on, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${userData?['money'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Reset button for development
          Column(
            children: [
              IconButton(
                onPressed: () async {
                  await _authService.resetUserStats();
                  // StreamBuilder will automatically refresh the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stats reset successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: Icon(
                  Icons.refresh,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
                tooltip: 'Reset Stats',
              ),
              Text(
                'Reset',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      )
    );
    
  }
  Widget _buildStatsSection(Map<String, dynamic>? userData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.games,
            label: 'Games',
            value: '${userData?['gamesPlayed'] ?? 0}',
          ),
          _buildStatItem(
            icon: Icons.star,
            label: '3-Stars',
            value: '${userData?['threeStarGames'] ?? 0}',
          ),
          _buildStatItem(
            icon: Icons.timer,
            label: 'Laugh Time',
            value: '${(userData?['totalLaughTime'] ?? 0)}s',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.accentOrange,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
  Widget _buildStartGameButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _buttonScaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * _buttonScaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [AppTheme.accentOrange, AppTheme.accentOrange.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentOrange.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppTheme.accentOrange.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Start Game',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.rocket_launch,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuCard(
          icon: Icons.shopping_bag,
          title: 'Shop',
          subtitle: 'Buy upgrades',
          onTap: _openShop,
        ),
        _buildMenuCard(
          icon: Icons.leaderboard,
          title: 'Leaderboard',
          subtitle: 'View rankings',
          onTap: _openLeaderboard,
        ),
        _buildMenuCard(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Preferences',
          onTap: _openSettings,
        ),
        _buildMenuCard(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Exit game',
          onTap: () => _authService.signOut(),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.accentOrange,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),        Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get country flag emoji
  String _getCountryFlag(String? countryCode) {
    return _authService.locationService.getCountryFlag(countryCode);
  }

  // Refresh location data (clear cache and detect fresh location)
  Future<void> _refreshLocation() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Refreshing location...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear cache and get fresh location
      await _authService.locationService.debugLocationDetection();
        // Update user document with new location
      final location = await _authService.locationService.getUserLocation();
      final user = _authService.currentUser;
      if (user != null && location['countryCode'] != null) {
        await _authService.updateUserLocation(location);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Location updated: ${location['countryName'] ?? 'Unknown'}'),
                  const SizedBox(width: 8),
                  Text(
                    _authService.locationService.getCountryFlag(location['countryCode']),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to refresh location: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Initialize location permission and detection on first app load
  Future<void> _initializeLocationIfNeeded() async {
    try {
      // Add a small delay to let the UI settle
      await Future.delayed(const Duration(milliseconds: 1500));
        // Check if location has been recently fetched
      final locationService = _authService.locationService;
      
      // If we have no cached location or it's older than 24 hours, request fresh location
      if (locationService.countryCode == null || locationService.countryCode == 'us') {
        print('Initializing location detection on app startup...');
        
        // Show a subtle notification that we're detecting location
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Detecting your location...'),
                ],
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.blue,
            ),
          );
        }
        
        // Request location permission and get fresh location
        final location = await _authService.requestLocationPermissionAndGetLocation();
        
        // Update user document if location was detected successfully
        if (location['countryCode'] != null && location['countryCode'] != 'us') {
          await _authService.updateUserLocation(location);
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Location detected: ${location['countryName']}'),
                    const SizedBox(width: 8),
                    Text(
                      _authService.locationService.getCountryFlag(location['countryCode']),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error initializing location: $e');
      // Don't show error to user as this is a background process
    }
  }
}
