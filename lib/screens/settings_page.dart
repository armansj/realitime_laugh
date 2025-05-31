import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/auth_service.dart';
import '../models/emoji_profile_service.dart';
import '../utils/app_theme.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  double _sensitivity = 0.5;
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 0,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [            // Profile Section
            _buildSection(
              title: l10n.profile,
              children: [
                _buildProfileTile(user),                _buildListTile(
                  icon: Icons.emoji_emotions,
                  title: l10n.changeProfileEmoji,
                  subtitle: l10n.updateYourProfileEmoji,
                  onTap: () => _changeProfileEmoji(),
                ),
                _buildListTile(
                  icon: Icons.edit,
                  title: l10n.editUsername,
                  subtitle: l10n.changeYourDisplayName,
                  onTap: () => _showEditUsernameDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),            // Game Settings
            _buildSection(
              title: l10n.gameSettings,
              children: [                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: l10n.soundEffects,
                  subtitle: l10n.enableGameSounds,
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),                _buildSwitchTile(
                  icon: Icons.vibration,
                  title: l10n.vibration,
                  subtitle: l10n.enableHapticFeedback,
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                ),                _buildSliderTile(
                  icon: Icons.mic,
                  title: l10n.laughSensitivity,
                  subtitle: l10n.adjustDetectionSensitivity,
                  value: _sensitivity,
                  onChanged: (value) {
                    setState(() {
                      _sensitivity = value;
                    });
                  },
                ),
              ],            ),
            
            const SizedBox(height: 20),
              // Language Settings
            _buildSection(
              title: l10n.language,
              children: [
                _buildLanguageSelector(),
              ],
            ),
            
            const SizedBox(height: 20),
              // Notifications
            _buildSection(
              title: l10n.notifications,
              children: [                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: l10n.pushNotifications,
                  subtitle: l10n.getGameUpdates,
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),              // App Info
            _buildSection(
              title: l10n.about,
              children: [                _buildListTile(
                  icon: Icons.info,
                  title: l10n.appVersion,
                  subtitle: '1.0.0',
                  onTap: null,
                ),
                _buildListTile(
                  icon: Icons.location_on,
                  title: l10n.testLocationDetection,
                  subtitle: l10n.debugCountryFlagDetection,
                  onTap: () => _testLocationDetection(),
                ),
                _buildListTile(
                  icon: Icons.privacy_tip,
                  title: l10n.privacyPolicy,
                  subtitle: l10n.viewOurPrivacyPolicy,
                  onTap: () => _showPrivacyPolicy(),
                ),                _buildListTile(
                  icon: Icons.description,
                  title: l10n.termsOfService,
                  subtitle: l10n.viewTermsAndConditions,
                  onTap: () => _showTermsOfService(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Account Actions
            _buildSection(
              title: 'Account',
              children: [
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: () => _showSignOutDialog(),
                  textColor: Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentOrange,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }  Widget _buildProfileTile(user) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      stream: _authService.getUserDataStream(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();
        final username = userData?['username'] ?? user?.displayName ?? 'Player';
        final countryCode = userData?['countryCode'];
        final countryName = userData?['countryName'];        return StreamBuilder<String>(
          stream: _authService.getUserEmojiProfileStream(),
          builder: (context, emojiSnapshot) {
            final emojiProfile = emojiSnapshot.data ?? '😂';
            
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentOrange, width: 2),
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    emojiProfile,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (countryCode != null) ...[
                    Text(
                      _authService.locationService.getCountryFlag(countryCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (countryName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      countryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (userData != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [                        Icon(Icons.star, size: 16, color: AppTheme.secondaryYellow),
                        const SizedBox(width: 4),                        Text(
                          '${userData['stars'] ?? 5} stars',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.monetization_on, size: 16, color: AppTheme.accentOrange),
                        const SizedBox(width: 4),
                        Text(
                          '${userData['money'] ?? 0} coins',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppTheme.accentOrange,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14),
      ),
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.accentOrange,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accentOrange,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.accentOrange,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentOrange,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(value * 100).round()}%',
          ),
        ],
      ),
    );
  }  void _changeProfileEmoji() async {
    try {
      // Get purchased emoji items
      final purchasedItems = await _authService.getPurchasedItems();
      
      // Use the emoji service to get available emojis based on purchases
      final emojiService = EmojiProfileService();
      final availableEmojis = emojiService.getAvailableEmojis(purchasedItems);
      
      // Show custom emoji selection dialog with only available emojis
      final selectedEmoji = await _showCustomEmojiSelectionDialog(context, availableEmojis);
      
      if (selectedEmoji != null && mounted) {
        // Update emoji in Firestore and local storage
        await _authService.updateEmojiProfile(selectedEmoji);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Profile emoji updated to $selectedEmoji!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        
        // Trigger UI refresh
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error updating profile emoji: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<String?> _showCustomEmojiSelectionDialog(BuildContext context, List<String> availableEmojis) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          title: const Row(
            children: [
              Text('😄'),
              SizedBox(width: 8),
              Text('Choose Your Profile'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: availableEmojis.length <= 6 ? 100 : 200,
            child: availableEmojis.isEmpty 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No emojis available!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visit the shop to purchase emoji packs',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: availableEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = availableEmojis[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(emoji);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          color: emoji == '😂' 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.blue.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (availableEmojis.isEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to shop
                  Navigator.pushNamed(context, '/shop');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                ),
                child: const Text('Visit Shop'),
              ),
          ],
        );
      },
    );
  }

  void _showEditUsernameDialog() async {
    // Get current user data to show current username
    final userData = await _authService.getUserData();
    final currentUsername = userData?['username'] ?? '';
    
    final TextEditingController controller = TextEditingController(text: currentUsername);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, dialogSetState) {
            bool isLoading = false;
              Future<void> saveUsername() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              dialogSetState(() {
                isLoading = true;
              });

              try {
                await _authService.updateUsername(controller.text.trim());
                
                // Debug: Print successful completion
                print('Username updated successfully, closing dialog');
                
                // Close dialog
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Username updated successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }              } catch (e) {
                print('Error updating username: $e');
                dialogSetState(() {
                  isLoading = false;
                });
                
                if (mounted) {
                  String errorMessage = 'Error updating username';
                  if (e.toString().contains('Username is already taken')) {
                    errorMessage = 'Username is already taken. Please choose another one.';
                  } else {
                    errorMessage = 'Error updating username: ${e.toString()}';
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text(errorMessage)),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              }
            }
              return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit, color: AppTheme.accentOrange),
                  const SizedBox(width: 8),
                  const Text('Edit Username'),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentUsername.isNotEmpty) ...[
                      Text(
                        'Current: $currentUsername',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: controller,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'New username',
                        hintText: 'Enter new username',
                        prefixIcon: Icon(Icons.person_outline, color: AppTheme.accentOrange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentOrange, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        if (value.trim().length > 20) {
                          return 'Username must be less than 20 characters';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                          return 'Only letters, numbers, and underscore allowed';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          saveUsername();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 3-20 characters\n• Letters, numbers, and underscore only',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : saveUsername,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Widget _buildLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return ListTile(
          leading: Icon(
            Icons.language,
            color: AppTheme.accentOrange,
          ),
          title: Text(
            l10n.language,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            languageService.getLanguageName(languageService.locale.languageCode),
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageSelectionDialog(languageService),
        );
      },
    );
  }
  void _showLanguageSelectionDialog(LanguageService languageService) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.language, color: AppTheme.accentOrange),
              const SizedBox(width: 8),
              Text(l10n.language),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageService.supportedLocales.map((locale) {
              final isSelected = languageService.locale.languageCode == locale.languageCode;
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.accentOrange : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.accentOrange : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                title: Text(
                  languageService.getLanguageName(locale.languageCode),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.accentOrange : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  languageService.getLanguageNameInEnglish(locale.languageCode),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                onTap: () async {
                  await languageService.setLanguage(locale);
                  Navigator.of(context).pop();
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Language changed to ${languageService.getLanguageName(locale.languageCode)}'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.accentOrange),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'This app collects minimal data necessary for functionality. '
              'We store your game scores and achievements to enhance your experience. '
              'Your data is securely stored and never shared with third parties.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms of Service'),
          content: const SingleChildScrollView(
            child: Text(
              'By using this app, you agree to use it responsibly and in accordance '
              'with all applicable laws. The app is provided as-is for entertainment purposes.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _authService.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
  // Test location detection
  Future<void> _testLocationDetection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Testing Location Detection'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Detecting location...'),
            ],
          ),
        );
      },
    );

    try {
      // Run the debug location detection
      await _authService.locationService.debugLocationDetection();
      
      // Force refresh to get fresh data
      final location = await _authService.locationService.forceRefreshLocation();
      
      // Update user document with fresh location data
      final user = _authService.currentUser;
      if (user != null && location['countryCode'] != null) {
        await _authService.updateUserLocation(location);
      }
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Detection Result'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Country: ${location['countryName'] ?? 'Unknown'}'),
                  Text('Country Code: ${location['countryCode'] ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Flag: '),
                      Text(
                        _authService.locationService.getCountryFlag(location['countryCode']),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check the debug console for detailed API response.\nLocation has been updated in your profile.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {}); // Refresh the UI
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to detect location: $e\n\nCheck your internet connection and try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );      }
    }
  }
}
