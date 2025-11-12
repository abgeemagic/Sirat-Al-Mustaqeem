import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:molvi/Firebase/user_preferences_service.dart';
import 'package:molvi/Firebase/bookmark_sync_service.dart';
import 'package:molvi/Features/bookmark_service.dart';
import 'package:molvi/Features/hadith_bookmark_service.dart';
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
      );
  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        throw Exception('Web Google Sign-In requires additional setup.\n\n'
            'Steps to fix:\n'
            '1. Go to Google Cloud Console\n'
            '2. APIs & Services → Credentials\n'
            '3. Find your Web client ID\n'
            '4. Add it to GoogleSignIn configuration\n\n'
            'For now, please test on Android/iOS device.');
      }
      final String? previousUserId = _auth.currentUser?.uid;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final String newUserId = userCredential.user?.uid ?? '';
      if (previousUserId != null && previousUserId != newUserId) {
        print(
            'Account switching detected! Previous: $previousUserId, New: $newUserId');
        BookmarkService.clearLocalBookmarks();
        HadithBookmarkService.clearLocalBookmarks();
        print('Completed force reset for account switch');
      } else {
        print('Same user signing in again: $newUserId');
      }
      await BookmarkService.reloadBookmarksForUser();
      await HadithBookmarkService.reloadBookmarksForUser();
      await UserPreferencesService.syncAfterSignIn();
      await BookmarkSyncService.syncAfterSignIn();
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  static Future<void> signOut() async {
    try {
      UserPreferencesService.clearSyncStatus();
      BookmarkSyncService.clearSyncStatus();
      BookmarkService.clearLocalBookmarks();
      HadithBookmarkService.clearLocalBookmarks();
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  } 
  static String get userDisplayName {
    final user = _auth.currentUser;
    return user?.displayName ?? 'User';
  }
  static String get userEmail {
    final user = _auth.currentUser;
    return user?.email ?? '';
  }
  static String? get userPhotoURL {
    final user = _auth.currentUser;
    return user?.photoURL;
  }
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
