import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_service.dart';
import 'emoji_profile_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  final EmojiProfileService _emojiProfileService = EmojiProfileService();
  // Get current user
  User? get currentUser => _auth.currentUser;
  // Get location service
  LocationService get locationService => _locationService;
  
  // Get emoji profile service
  EmojiProfileService get emojiProfileService => _emojiProfileService;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      
      // Check if user is already signed in
      await _googleSignIn.signOut(); // Force fresh sign-in
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('User cancelled the sign-in');
        return null;
      }

      print('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('Access token: ${googleAuth.accessToken != null ? "✓" : "✗"}');
      print('ID token: ${googleAuth.idToken != null ? "✓" : "✗"}');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase...');
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase sign-in successful: ${userCredential.user?.email}');
        // Create or update user document in Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      print('Error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error - Code: ${e.code}, Message: ${e.message}');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      // Get user location with permission request
      final locationData = await requestLocationPermissionAndGetLocation();
        if (!docSnapshot.exists) {        // Create new user document
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'username': '', // Will be set later by user
          'totalScore': 0,
          'userLevel': 1,          'gamesPlayed': 0,
          'threeStarGames': 0,
          'totalLaughTime': 0,
          'stars': 5, // Starting stars for shop purchases
          'money': 50,  // Starting money
          'countryCode': locationData['countryCode'],
          'countryName': locationData['countryName'],
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last login time and location (in case user moved)
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'countryCode': locationData['countryCode'],
          'countryName': locationData['countryName'],
        });
      }
    } catch (e) {
      print('Error creating/updating user document: $e');
      rethrow;
    }  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final user = currentUser;
      
      // Query for any user with this username
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .get();
      
      // If no documents found, username is available
      if (querySnapshot.docs.isEmpty) {
        return true;
      }
      
      // If documents found, check if it belongs to current user (for updates)
      if (user != null) {
        final currentUserDoc = querySnapshot.docs.firstWhere(
          (doc) => doc.id == user.uid,
          orElse: () => throw StateError('Not found'),
        );
        // If the only document is the current user's, username is available for update
        return querySnapshot.docs.length == 1 && currentUserDoc.id == user.uid;
      }
      
      // Username is taken by someone else
      return false;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  // Update username
  Future<void> updateUsername(String username) async {
    try {
      final user = currentUser;
      if (user != null) {
        // First ensure user document exists with all required fields
        await _ensureUserDocumentExists(user);
        
        // Check if username is available
        final isAvailable = await isUsernameAvailable(username);
        if (!isAvailable) {
          throw Exception('Username is already taken');
        }
        
        // Then update the username
        await _firestore.collection('users').doc(user.uid).update({
          'username': username,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating username: $e');
      rethrow;
    }
  }
  // Update user location
  Future<void> updateUserLocation(Map<String, dynamic> locationData) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists with all required fields
        await _ensureUserDocumentExists(user);
        
        // Update the location data
        await _firestore.collection('users').doc(user.uid).update({
          'countryCode': locationData['countryCode'],
          'countryName': locationData['countryName'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating user location: $e');
      rethrow;
    }  }
  
  // Force refresh GPS location and update user document
  Future<Map<String, String?>> forceRefreshUserLocation() async {
    try {
      print('Forcing GPS location refresh...');
      
      // Clear cache and force fresh GPS detection
      final location = await _locationService.forceRefreshLocation();
      
      // Update user document with fresh location
      if (currentUser != null && location['countryCode'] != null) {
        await updateUserLocation(location);
      }
      
      return location;
    } catch (e) {
      print('Error forcing GPS location refresh: $e');
      rethrow;
    }
  }
  
  // Update emoji profile
  Future<void> updateEmojiProfile(String emoji) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists with all required fields
        await _ensureUserDocumentExists(user);
        
        // Convert emoji to unicode for Firestore storage
        final unicodeEmoji = _emojiProfileService.emojiToUnicode(emoji);
        
        // Update the emoji profile in Firestore (as unicode)
        await _firestore.collection('users').doc(user.uid).update({
          'emojiProfile': unicodeEmoji,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Store original emoji locally for immediate display
        await _emojiProfileService.setEmojiProfile(emoji);
      }
    } catch (e) {
      print('Error updating emoji profile: $e');
      rethrow;
    }
  }

  // Ensure user document exists with all required fields
  Future<void> _ensureUserDocumentExists(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
        // Get user location
        final locationData = await _locationService.getUserLocation();
        
        // Convert default emoji to unicode for Firestore storage
        final defaultEmojiUnicode = _emojiProfileService.emojiToUnicode('😂');
          // Create user document with all required fields
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'username': '', // Will be set by updateUsername
          'emojiProfile': defaultEmojiUnicode, // Default emoji profile as unicode          'totalScore': 0,
          'userLevel': 1,
          'gamesPlayed': 0,
          'threeStarGames': 0,
          'totalLaughTime': 0,
          'challengesCompleted': 0, // Challenge tracking
          'dontLaughWins': 0, // Don't Laugh Challenge wins
          'challengeScore': 0, // Total score from challenges
          'bestDontLaughStreak': 0, // Best streak in Don't Laugh Challenge
          'stars': 5, // Starting stars for shop purchases
          'money': 50,  // Starting money
          'purchasedItems': [], // List of purchased shop items
          'activeCameraFilter': null, // Currently active camera filter
          'countryCode': locationData['countryCode'],
          'countryName': locationData['countryName'],
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error ensuring user document exists: $e');
      rethrow;
    }
  }
  // Update user score data
  Future<void> updateUserScore({
    required int totalScore,
    required int userLevel,
    required int gamesPlayed,
    required int threeStarGames,
    required int totalLaughTime,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
        
        await _firestore.collection('users').doc(user.uid).update({
          'totalScore': totalScore,
          'userLevel': userLevel,
          'gamesPlayed': gamesPlayed,
          'threeStarGames': threeStarGames,
          'totalLaughTime': totalLaughTime,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating user score: $e');
      rethrow;
    }
  }

  // Update challenge-specific data
  Future<void> updateChallengeData({
    required int challengesCompleted,
    required int dontLaughWins,
    required int challengeScore,
    required int bestDontLaughStreak,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
        
        await _firestore.collection('users').doc(user.uid).update({
          'challengesCompleted': challengesCompleted,
          'dontLaughWins': dontLaughWins,
          'challengeScore': challengeScore,
          'bestDontLaughStreak': bestDontLaughStreak,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating challenge data: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }  // Stream user data from Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>?> getUserDataStream() {
    final user = currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    return Stream.value(null);
  }

  // Save game result to history
  Future<void> saveGameResult({
    required int starsEarned,
    required int gameScore,
    required int completionTimeSeconds,
    required int laughDurationSeconds,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('gameHistory')
            .add({
          'starsEarned': starsEarned,
          'gameScore': gameScore,
          'completionTimeSeconds': completionTimeSeconds,
          'laughDurationSeconds': laughDurationSeconds,
          'playedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving game result: $e');
      rethrow;
    }
  }

  // Get user's game history
  Future<List<Map<String, dynamic>>> getGameHistory({int limit = 20}) async {
    try {
      final user = currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('gameHistory')
            .orderBy('playedAt', descending: true)
            .limit(limit)
            .get();
        
        return querySnapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting game history: $e');
      rethrow;
    }
  }
  // Update user stars and money
  Future<void> updateStarsAndMoney({
    required int stars,
    required int money,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
        
        await _firestore.collection('users').doc(user.uid).update({
          'stars': stars,
          'money': money,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating stars and money: $e');
      rethrow;
    }
  }  // Add stars (e.g., from completing games)
  Future<void> addStars(int starsToAdd) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
        
        await _firestore.collection('users').doc(user.uid).update({
          'stars': FieldValue.increment(starsToAdd),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding stars: $e');
      rethrow;
    }
  }
  // Add money (e.g., from daily rewards)
  Future<void> addMoney(int moneyToAdd) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
        
        await _firestore.collection('users').doc(user.uid).update({
          'money': FieldValue.increment(moneyToAdd),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {      print('Error adding money: $e');
      rethrow;
    }
  }  // Spend stars (e.g., for shop purchases)
  Future<bool> spendStars(int starsToSpend) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
          // Get current user data to check if they have enough stars
        final userData = await getUserData();
        final currentStars = userData?['stars'] ?? 5;
        
        if (currentStars < starsToSpend) {
          return false; // Not enough stars
        }
        
        // Deduct stars from user account
        await _firestore.collection('users').doc(user.uid).update({
          'stars': FieldValue.increment(-starsToSpend),
          'updatedAt': FieldValue.serverTimestamp(),
        });
          return true; // Purchase successful
      }
      return false;
    } catch (e) {
      print('Error spending stars: $e');
      rethrow;
    }
  }

  // Purchase stars with money
  Future<bool> purchaseStars(int starsToBuy, int moneyToSpend) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
        
        // Get current user data to check if they have enough money
        final userData = await getUserData();
        final currentMoney = userData?['money'] ?? 50;
        
        if (currentMoney < moneyToSpend) {
          return false; // Not enough money
        }
        
        // Execute the purchase transaction
        await _firestore.collection('users').doc(user.uid).update({
          'money': FieldValue.increment(-moneyToSpend),
          'stars': FieldValue.increment(starsToBuy),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return true; // Purchase successful
      }
      return false;
    } catch (e) {
      print('Error purchasing stars: $e');
      rethrow;
    }
  }

  // Reset user stats (for debugging/admin purposes)
  Future<void> resetUserStats() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Ensure user document exists
        await _ensureUserDocumentExists(user);
          await _firestore.collection('users').doc(user.uid).update({
          'totalScore': 0,
          'userLevel': 1,
          'gamesPlayed': 0,
          'threeStarGames': 0,
          'totalLaughTime': 0,
          'challengesCompleted': 0, // Reset challenge data
          'dontLaughWins': 0,
          'challengeScore': 0,
          'bestDontLaughStreak': 0,
          'stars': 5, // Reset to starting amount
          'money': 50,  // Reset to starting amount
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error resetting user stats: $e');
      rethrow;
    }
  }

  // Get user's emoji profile (converts from unicode if needed)
  Future<String> getUserEmojiProfile() async {
    try {
      final user = currentUser;
      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        final userData = docSnapshot.data();
        
        if (userData != null && userData['emojiProfile'] != null) {
          final storedEmoji = userData['emojiProfile'] as String;
          // Convert from unicode if needed, otherwise return as is
          return _emojiProfileService.unicodeToEmoji(storedEmoji);
        }
      }
      
      // Fallback to local storage or default
      return await _emojiProfileService.getEmojiProfile();
    } catch (e) {
      print('Error getting user emoji profile: $e');
      // Fallback to local storage or default
      return await _emojiProfileService.getEmojiProfile();
    }
  }

  // Stream user's emoji profile (converts from unicode if needed)
  Stream<String> getUserEmojiProfileStream() {
    return getUserDataStream().asyncMap((docSnapshot) async {
      final userData = docSnapshot?.data();
      
      if (userData != null && userData['emojiProfile'] != null) {
        final storedEmoji = userData['emojiProfile'] as String;
        // Convert from unicode if needed, otherwise return as is
        return _emojiProfileService.unicodeToEmoji(storedEmoji);
      }
      
      // Fallback to local storage or default
      return await _emojiProfileService.getEmojiProfile();
    });
  }

  // Proactively request location permission and get fresh location
  Future<Map<String, String?>> requestLocationPermissionAndGetLocation() async {
    try {
      print('Requesting location permission and getting fresh location...');
      
      // Force a fresh location request which will ask for permissions if needed
      final location = await _locationService.forceRefreshLocation();
      
      print('Location obtained: ${location['countryName']} (${location['countryCode']})');
      return location;
    } catch (e) {
      print('Error requesting location permission: $e');
      // Return default location if permission is denied or GPS fails
      return {
        'countryCode': 'us',
        'countryName': 'United States',
      };
    }
  }

  // Purchase item methods
  Future<bool> purchaseItem(String itemId, int price) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Check if user has enough stars
      final userData = await getUserData();
      final currentStars = userData?['stars'] ?? 0;
      
      if (currentStars < price) {
        return false; // Not enough stars
      }

      // Get current purchased items
      final purchasedItems = List<String>.from(userData?['purchasedItems'] ?? []);
      
      // Check if already purchased
      if (purchasedItems.contains(itemId)) {
        return false; // Already owned
      }

      // Add item and deduct stars
      purchasedItems.add(itemId);
      
      await _firestore.collection('users').doc(user.uid).update({
        'purchasedItems': purchasedItems,
        'stars': FieldValue.increment(-price),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }

  // Check if user owns an item
  Future<bool> ownsItem(String itemId) async {
    try {
      final userData = await getUserData();
      final purchasedItems = List<String>.from(userData?['purchasedItems'] ?? []);
      return purchasedItems.contains(itemId);
    } catch (e) {
      print('Error checking item ownership: $e');
      return false;
    }
  }

  // Get all purchased items
  Future<List<String>> getPurchasedItems() async {
    try {
      final userData = await getUserData();
      return List<String>.from(userData?['purchasedItems'] ?? []);
    } catch (e) {
      print('Error getting purchased items: $e');
      return [];
    }
  }

  // Set active profile emoji
  Future<void> setActiveProfileEmoji(String emoji) async {
    try {
      final user = currentUser;
      if (user != null) {
        final emojiUnicode = _emojiProfileService.emojiToUnicode(emoji);
        await _firestore.collection('users').doc(user.uid).update({
          'emojiProfile': emojiUnicode,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error setting active profile emoji: $e');
      rethrow;
    }
  }

  // Set active camera filter
  Future<void> setActiveCameraFilter(String? filterId) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'activeCameraFilter': filterId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error setting active camera filter: $e');
      rethrow;
    }
  }
}
