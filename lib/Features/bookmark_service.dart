import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:molvi/Firebase/bookmark_sync_service.dart';
import 'package:molvi/Firebase/auth_service.dart';
class Bookmark {
  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final String surahNameArabic;
  final String verseText;
  final String translationText;
  final DateTime createdAt;
  final String? note;
  Bookmark({
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.surahNameArabic,
    required this.verseText,
    required this.translationText,
    required this.createdAt,
    this.note,
  });
  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'surahName': surahName,
      'surahNameArabic': surahNameArabic,
      'verseText': verseText,
      'translationText': translationText,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      surahNumber: json['surahNumber'],
      verseNumber: json['verseNumber'],
      surahName: json['surahName'],
      surahNameArabic: json['surahNameArabic'],
      verseText: json['verseText'],
      translationText: json['translationText'],
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }
  String get bookmarkId => '${surahNumber}_$verseNumber';
}
class BookmarkService {
  static const String _baseBookmarksKey = 'quran_bookmarks';
  static List<Bookmark> _bookmarks = [];
  static final List<VoidCallback> _listeners = [];
  static List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  static String get _bookmarksKey {
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      return '${_baseBookmarksKey}_${currentUser.uid}';
    }
    return '${_baseBookmarksKey}_guest'; 
  }
  static Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      _bookmarks = bookmarksJson
          .map((jsonString) => Bookmark.fromJson(json.decode(jsonString)))
          .toList();
      _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notifyListeners();
    } catch (e) {
      print('Error loading bookmarks: $e');
      _bookmarks = [];
    }
  }
  static Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson =
          _bookmarks.map((bookmark) => json.encode(bookmark.toJson())).toList();
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
      await BookmarkSyncService.syncQuranBookmarks(_bookmarks);
    } catch (e) {
      print('Error saving bookmarks: $e');
    }
  }
  static Future<bool> addBookmark(Bookmark bookmark) async {
    try {
      final existingIndex = _bookmarks.indexWhere(
        (b) =>
            b.surahNumber == bookmark.surahNumber &&
            b.verseNumber == bookmark.verseNumber,
      );
      if (existingIndex == -1) {
        _bookmarks.insert(0, bookmark); 
        await _saveBookmarks();
        _notifyListeners();
        return true;
      }
      return false; 
    } catch (e) {
      print('Error adding bookmark: $e');
      return false;
    }
  }
  static Future<bool> removeBookmark(int surahNumber, int verseNumber) async {
    try {
      final initialLength = _bookmarks.length;
      _bookmarks.removeWhere(
        (bookmark) =>
            bookmark.surahNumber == surahNumber &&
            bookmark.verseNumber == verseNumber,
      );
      if (_bookmarks.length < initialLength) {
        await _saveBookmarks();
        _notifyListeners();
        return true;
      }
      return false; 
    } catch (e) {
      print('Error removing bookmark: $e');
      return false;
    }
  }
  static bool isBookmarked(int surahNumber, int verseNumber) {
    return _bookmarks.any(
      (bookmark) =>
          bookmark.surahNumber == surahNumber &&
          bookmark.verseNumber == verseNumber,
    );
  }
  static Future<bool> updateBookmarkNote(
      int surahNumber, int verseNumber, String? note) async {
    try {
      final bookmarkIndex = _bookmarks.indexWhere(
        (b) => b.surahNumber == surahNumber && b.verseNumber == verseNumber,
      );
      if (bookmarkIndex != -1) {
        final oldBookmark = _bookmarks[bookmarkIndex];
        _bookmarks[bookmarkIndex] = Bookmark(
          surahNumber: oldBookmark.surahNumber,
          verseNumber: oldBookmark.verseNumber,
          surahName: oldBookmark.surahName,
          surahNameArabic: oldBookmark.surahNameArabic,
          verseText: oldBookmark.verseText,
          translationText: oldBookmark.translationText,
          createdAt: oldBookmark.createdAt,
          note: note,
        );
        await _saveBookmarks();
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating bookmark note: $e');
      return false;
    }
  }
  static List<Bookmark> getBookmarksBySurah(int surahNumber) {
    return _bookmarks
        .where((bookmark) => bookmark.surahNumber == surahNumber)
        .toList();
  }
  static Future<void> clearAllBookmarks() async {
    try {
      _bookmarks.clear();
      await _saveBookmarks();
      _notifyListeners();
    } catch (e) {
      print('Error clearing bookmarks: $e');
    }
  }
  static Future<void> restoreFromCloud(List<Bookmark> cloudBookmarks) async {
    try {
      _bookmarks = cloudBookmarks;
      _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson =
          _bookmarks.map((bookmark) => json.encode(bookmark.toJson())).toList();
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
      _notifyListeners();
    } catch (e) {
      print('Error restoring bookmarks from cloud: $e');
    }
  }
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  static void clearLocalBookmarks() {
    _bookmarks.clear();
    _notifyListeners();
  }
  static Future<void> reloadBookmarksForUser() async {
    _bookmarks.clear();
    await loadBookmarks();
  }
}
