import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:molvi/Firebase/auth_service.dart';

class ReadingProgressService {
  // Removed _progressKey, no longer needed

  static Future<Map<String, int>> getProgress() async {
    // Removed prefs, no longer needed
    final user = AuthService.currentUser;
    if (user != null) {
      // Get from Firestore only
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .doc('quran')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'surah': data['surah'] ?? 1,
          'ayah': data['ayah'] ?? 1,
        };
      }
    }
    // If not signed in or no data, return default
    return {'surah': 1, 'ayah': 1};
  }

  static Future<void> saveProgress(int surah, int ayah) async {
    // Removed prefs, no longer needed
    final user = AuthService.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .doc('quran')
          .set({
        'surah': surah,
        'ayah': ayah,
        'updatedAt': FieldValue.serverTimestamp()
      });
    }
    // Removed SharedPreferences saving
  }
}
