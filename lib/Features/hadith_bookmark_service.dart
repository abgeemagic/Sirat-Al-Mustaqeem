import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:molvi/Firebase/bookmark_sync_service.dart';
import 'package:molvi/Firebase/auth_service.dart';
class HadithBookmark {
  final String bookSlug;
  final String bookName;
  final String hadithNumber;
  final String headingEnglish;
  final String headingUrdu;
  final String headingArabic;
  final String hadithEnglish;
  final String hadithUrdu;
  final String hadithArabic;
  final String chapterNumber;
  final String volume;
  final String status;
  final DateTime createdAt;
  String? note;
  HadithBookmark({
    required this.bookSlug,
    required this.bookName,
    required this.hadithNumber,
    required this.headingEnglish,
    required this.headingUrdu,
    required this.headingArabic,
    required this.hadithEnglish,
    required this.hadithUrdu,
    required this.hadithArabic,
    required this.chapterNumber,
    required this.volume,
    required this.status,
    required this.createdAt,
    this.note,
  });
  factory HadithBookmark.fromJson(Map<String, dynamic> json) {
    return HadithBookmark(
      bookSlug: json['bookSlug'] ?? '',
      bookName: json['bookName'] ?? '',
      hadithNumber: json['hadithNumber'] ?? '',
      headingEnglish: json['headingEnglish'] ?? '',
      headingUrdu: json['headingUrdu'] ?? '',
      headingArabic: json['headingArabic'] ?? '',
      hadithEnglish: json['hadithEnglish'] ?? '',
      hadithUrdu: json['hadithUrdu'] ?? '',
      hadithArabic: json['hadithArabic'] ?? '',
      chapterNumber: json['chapterNumber'] ?? '',
      volume: json['volume'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bookSlug': bookSlug,
      'bookName': bookName,
      'hadithNumber': hadithNumber,
      'headingEnglish': headingEnglish,
      'headingUrdu': headingUrdu,
      'headingArabic': headingArabic,
      'hadithEnglish': hadithEnglish,
      'hadithUrdu': hadithUrdu,
      'hadithArabic': hadithArabic,
      'chapterNumber': chapterNumber,
      'volume': volume,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }
  String get uniqueId => '${bookSlug}_$hadithNumber';
}
class HadithBookmarkService {
  static const String _baseKey = 'hadith_bookmarks';
  static final List<HadithBookmark> _bookmarks = [];
  static final List<VoidCallback> _listeners = [];
  static List<HadithBookmark> get bookmarks => List.unmodifiable(_bookmarks);
  static String get _key {
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      return '${_baseKey}_${currentUser.uid}';
    }
    return '${_baseKey}_guest'; 
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
  static Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString(_key);
      if (bookmarksJson != null) {
        final List<dynamic> bookmarksList = json.decode(bookmarksJson);
        _bookmarks.clear();
        _bookmarks.addAll(
          bookmarksList.map((bookmark) => HadithBookmark.fromJson(bookmark)),
        );
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading hadith bookmarks: $e');
    }
  }
  static Future<bool> saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String bookmarksJson = json.encode(
        _bookmarks.map((bookmark) => bookmark.toJson()).toList(),
      );
      await prefs.setString(_key, bookmarksJson);
      await BookmarkSyncService.syncHadithBookmarks(_bookmarks);
      return true;
    } catch (e) {
      print('Error saving hadith bookmarks: $e');
      return false;
    }
  }
  static Future<bool> addBookmark(HadithBookmark bookmark) async {
    try {
      if (!isBookmarked(bookmark.bookSlug, bookmark.hadithNumber)) {
        _bookmarks.add(bookmark);
        _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await saveBookmarks();
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding hadith bookmark: $e');
      return false;
    }
  }
  static Future<bool> removeBookmark(
      String bookSlug, String hadithNumber) async {
    try {
      final index = _bookmarks.indexWhere(
        (bookmark) =>
            bookmark.bookSlug == bookSlug &&
            bookmark.hadithNumber == hadithNumber,
      );
      if (index != -1) {
        _bookmarks.removeAt(index);
        await saveBookmarks();
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing hadith bookmark: $e');
      return false;
    }
  }
  static bool isBookmarked(String bookSlug, String hadithNumber) {
    return _bookmarks.any(
      (bookmark) =>
          bookmark.bookSlug == bookSlug &&
          bookmark.hadithNumber == hadithNumber,
    );
  }
  static HadithBookmark? getBookmark(String bookSlug, String hadithNumber) {
    try {
      return _bookmarks.firstWhere(
        (bookmark) =>
            bookmark.bookSlug == bookSlug &&
            bookmark.hadithNumber == hadithNumber,
      );
    } catch (e) {
      return null;
    }
  }
  static Future<bool> updateBookmarkNote(
      String bookSlug, String hadithNumber, String? note) async {
    try {
      final bookmark = getBookmark(bookSlug, hadithNumber);
      if (bookmark != null) {
        bookmark.note = note;
        await saveBookmarks();
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating hadith bookmark note: $e');
      return false;
    }
  }
  static Future<bool> clearAllBookmarks() async {
    try {
      _bookmarks.clear();
      await saveBookmarks();
      _notifyListeners();
      return true;
    } catch (e) {
      print('Error clearing hadith bookmarks: $e');
      return false;
    }
  }
  static Future<void> restoreFromCloud(
      List<HadithBookmark> cloudBookmarks) async {
    try {
      _bookmarks.clear();
      _bookmarks.addAll(cloudBookmarks);
      _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final prefs = await SharedPreferences.getInstance();
      final String bookmarksJson = json.encode(
        _bookmarks.map((bookmark) => bookmark.toJson()).toList(),
      );
      await prefs.setString(_key, bookmarksJson);
      _notifyListeners();
    } catch (e) {
      print('Error restoring hadith bookmarks from cloud: $e');
    }
  }
  static List<HadithBookmark> searchBookmarks(String query) {
    if (query.isEmpty) return bookmarks;
    return _bookmarks.where((bookmark) {
      return bookmark.bookName.toLowerCase().contains(query.toLowerCase()) ||
          bookmark.hadithNumber.contains(query) ||
          bookmark.headingEnglish.toLowerCase().contains(query.toLowerCase()) ||
          bookmark.headingUrdu.contains(query) ||
          bookmark.hadithEnglish.toLowerCase().contains(query.toLowerCase()) ||
          bookmark.hadithUrdu.contains(query) ||
          (bookmark.note?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
  static Map<String, List<HadithBookmark>> getBookmarksByBook() {
    final Map<String, List<HadithBookmark>> groupedBookmarks = {};
    for (final bookmark in _bookmarks) {
      if (!groupedBookmarks.containsKey(bookmark.bookName)) {
        groupedBookmarks[bookmark.bookName] = [];
      }
      groupedBookmarks[bookmark.bookName]!.add(bookmark);
    }
    return groupedBookmarks;
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
