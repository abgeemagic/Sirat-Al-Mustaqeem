import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:molvi/Firebase/auth_service.dart';
import 'package:molvi/Features/bookmark_service.dart';
import 'package:molvi/Features/hadith_bookmark_service.dart';

class BookmarkSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _bookmarksCollection = 'bookmarks';
  static const String _quranBookmarks = 'quran_bookmarks';
  static const String _hadithBookmarks = 'hadith_bookmarks';
  static ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);
  static ValueNotifier<String> syncStatus = ValueNotifier<String>('');

  static bool get _isFirebaseAvailable {
    try {
      return AuthService.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  static Future<void> syncQuranBookmarks(List<Bookmark> bookmarks) async {
    if (!_isFirebaseAvailable) return;
    try {
      isSyncing.value = true;
      syncStatus.value = 'Syncing Quran bookmarks...';
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return;
      final collectionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_bookmarksCollection)
          .doc(_quranBookmarks)
          .collection('items');
      final existingDocs = await collectionRef.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }
      for (int i = 0; i < bookmarks.length; i++) {
        await collectionRef.doc('bookmark_$i').set({
          ...bookmarks[i].toJson(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      syncStatus.value = 'Quran bookmarks synced ✓';
      await Future.delayed(const Duration(seconds: 2));
      syncStatus.value = '';
    } catch (e) {
      syncStatus.value = 'Quran sync failed';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
    } finally {
      isSyncing.value = false;
    }
  }

  static Future<void> syncHadithBookmarks(
      List<HadithBookmark> bookmarks) async {
    if (!_isFirebaseAvailable) return;
    try {
      isSyncing.value = true;
      syncStatus.value = 'Syncing Hadith bookmarks...';
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return;
      final collectionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_bookmarksCollection)
          .doc(_hadithBookmarks)
          .collection('items');
      final existingDocs = await collectionRef.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }
      for (int i = 0; i < bookmarks.length; i++) {
        await collectionRef.doc('bookmark_$i').set({
          ...bookmarks[i].toJson(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      syncStatus.value = 'Hadith bookmarks synced ✓';
      await Future.delayed(const Duration(seconds: 2));
      syncStatus.value = '';
    } catch (e) {
      syncStatus.value = 'Hadith sync failed';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
    } finally {
      isSyncing.value = false;
    }
  }

  static Future<List<Bookmark>?> loadQuranBookmarks() async {
    if (!_isFirebaseAvailable) return null;
    try {
      isSyncing.value = true;
      syncStatus.value = 'Loading Quran bookmarks...';
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return null;
      final collectionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_bookmarksCollection)
          .doc(_quranBookmarks)
          .collection('items');
      final snapshot = await collectionRef.orderBy('createdAt').get();
      if (snapshot.docs.isNotEmpty) {
        final bookmarks =
            snapshot.docs.map((doc) => Bookmark.fromJson(doc.data())).toList();
        syncStatus.value = 'Quran bookmarks loaded ✓';
        await Future.delayed(const Duration(seconds: 1));
        syncStatus.value = '';
        return bookmarks;
      }
      syncStatus.value = '';
      return null;
    } catch (e) {
      syncStatus.value = 'Failed to load Quran bookmarks';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
      return null;
    } finally {
      isSyncing.value = false;
    }
  }

  static Future<List<HadithBookmark>?> loadHadithBookmarks() async {
    if (!_isFirebaseAvailable) return null;
    try {
      isSyncing.value = true;
      syncStatus.value = 'Loading Hadith bookmarks...';
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return null;
      final collectionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_bookmarksCollection)
          .doc(_hadithBookmarks)
          .collection('items');
      final snapshot = await collectionRef.orderBy('createdAt').get();
      if (snapshot.docs.isNotEmpty) {
        final bookmarks = snapshot.docs
            .map((doc) => HadithBookmark.fromJson(doc.data()))
            .toList();
        syncStatus.value = 'Hadith bookmarks loaded ✓';
        await Future.delayed(const Duration(seconds: 1));
        syncStatus.value = '';
        return bookmarks;
      }
      syncStatus.value = '';
      return null;
    } catch (e) {
      syncStatus.value = 'Failed to load Hadith bookmarks';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
      return null;
    } finally {
      isSyncing.value = false;
    }
  }

  static Future<void> syncAfterSignIn() async {
    if (!_isFirebaseAvailable) return;
    try {
      final cloudQuranBookmarks = await loadQuranBookmarks();
      final cloudHadithBookmarks = await loadHadithBookmarks();
      if (cloudQuranBookmarks != null) {
        await BookmarkService.restoreFromCloud(cloudQuranBookmarks);
        syncStatus.value = 'Quran bookmarks restored from cloud ✓';
        await Future.delayed(const Duration(seconds: 2));
      } else {
        await syncQuranBookmarks(BookmarkService.bookmarks);
      }
      if (cloudHadithBookmarks != null) {
        await HadithBookmarkService.restoreFromCloud(cloudHadithBookmarks);
        syncStatus.value = 'Hadith bookmarks restored from cloud ✓';
        await Future.delayed(const Duration(seconds: 2));
      } else {
        await syncHadithBookmarks(HadithBookmarkService.bookmarks);
      }
      syncStatus.value = 'All bookmarks synced ✓';
      await Future.delayed(const Duration(seconds: 2));
      syncStatus.value = '';
    } catch (e) {
      syncStatus.value = 'Bookmark sync error occurred';
      await Future.delayed(const Duration(seconds: 3));
      syncStatus.value = '';
    }
  }

  static void clearSyncStatus() {
    isSyncing.value = false;
    syncStatus.value = '';
  }
}
