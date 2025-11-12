import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:molvi/Firebase/auth_service.dart';
import 'package:molvi/Pages/settings.dart';

class UserPreferencesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _preferencesCollection = 'preferences';
  static ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);
  static ValueNotifier<String> syncStatus = ValueNotifier<String>('');

  static bool get _isFirebaseAvailable {
    try {
      return AuthService.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  static Future<void> savePreferences({
    String? themeMode,
    double? fontSize,
    double? arabicFontSize,
  }) async {
    if (!_isFirebaseAvailable) {
      return;
    }
    try {
      isSyncing.value = true;
      syncStatus.value = 'Syncing settings...';
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return;
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_preferencesCollection)
          .doc('settings');
      final data = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      if (themeMode != null) data['themeMode'] = themeMode;
      if (fontSize != null) data['fontSize'] = fontSize;
      if (arabicFontSize != null) data['arabicFontSize'] = arabicFontSize;
      await docRef.set(data, SetOptions(merge: true));
      syncStatus.value = 'Settings synced ✓';
      await Future.delayed(const Duration(seconds: 2));
      syncStatus.value = '';
    } catch (e) {
      syncStatus.value = 'Sync failed';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
      print('Error saving preferences: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  static Future<Map<String, dynamic>?> loadPreferences() async {
    if (!_isFirebaseAvailable) {
      return null;
    }
    try {
      isSyncing.value = true;
      syncStatus.value = 'Loading settings...';
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return null;
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_preferencesCollection)
          .doc('settings');
      final doc = await docRef.get();
      if (doc.exists) {
        syncStatus.value = 'Settings loaded ✓';
        await Future.delayed(const Duration(seconds: 1));
        syncStatus.value = '';
        return doc.data();
      }
      syncStatus.value = '';
      return null;
    } catch (e) {
      syncStatus.value = 'Failed to load settings';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
      print('Error loading preferences: $e');
      return null;
    } finally {
      isSyncing.value = false;
    }
  }

  static Future<void> syncAfterSignIn() async {
    if (!_isFirebaseAvailable) {
      return;
    }
    try {
      final cloudPrefs = await loadPreferences();
      if (cloudPrefs != null) {
        if (cloudPrefs['themeMode'] != null) {
          final themeMode = _parseThemeMode(cloudPrefs['themeMode']);
          if (themeMode != null) {
            await ThemeSettings.setThemeMode(themeMode);
          }
        }
        if (cloudPrefs['fontSize'] != null) {
          await FontSettings.setFontSize(cloudPrefs['fontSize'].toDouble());
        }
        if (cloudPrefs['arabicFontSize'] != null) {
          await FontSettings.setArabicFontSize(
              cloudPrefs['arabicFontSize'].toDouble());
        }
        syncStatus.value = 'Settings restored from cloud ✓';
        await Future.delayed(const Duration(seconds: 3));
        syncStatus.value = '';
      } else {
        await _uploadCurrentSettings();
      }
    } catch (e) {
      print('Error syncing after sign in: $e');
      syncStatus.value = 'Sync error occurred';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
    }
  }

  static Future<void> _uploadCurrentSettings() async {
    await savePreferences(
      themeMode: ThemeSettings.themeMode.name,
      fontSize: FontSettings.fontSize,
      arabicFontSize: FontSettings.arabicFontSize,
    );
  }

  static ThemeMode? _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static void clearSyncStatus() {
    isSyncing.value = false;
    syncStatus.value = '';
  }
}
