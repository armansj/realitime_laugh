import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

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
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        // Create new user document
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'username': '', // Will be set later by user
          'totalScore': 0,
          'userLevel': 1,
          'gamesPlayed': 0,
          'threeStarGames': 0,
          'totalLaughTime': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last login time
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating/updating user document: $e');
      rethrow;
    }
  }

  // Update username
  Future<void> updateUsername(String username) async {
    try {
      final user = currentUser;
      if (user != null) {
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
  }

  // Stream user data from Firestore
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
}
