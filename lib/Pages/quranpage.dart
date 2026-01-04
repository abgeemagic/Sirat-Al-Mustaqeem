import 'package:flutter/material.dart';
import 'package:molvi/Features/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:molvi/Pages/settings.dart';
import 'package:molvi/Features/bookmark_service.dart';

// Global variables (kept as requested)
List<dynamic> quranList = [];
int currentAyahIndex = 0;
late int surahnum;
late String surahname;
late String juzname;
late int juznum;
late int which;

class Quranpage extends StatefulWidget {
  const Quranpage({super.key});
  @override
  State<Quranpage> createState() => _QuranpageState();
}

class _QuranpageState extends State<Quranpage> {
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _showBookmarksList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookmarksListPage(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          fontSizeMultiplier: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. IMPROVED HEADER (Matches Settings Page Style) ---
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: colorScheme.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Holy Quran',
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Read, Recite, Reflect',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. FIXED BANNER (Cleaner, Modern UI) ---
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainer, // Matches Home page cards
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 30,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'The Noble Quran',
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your reading method below',
                      style: GoogleFonts.inter(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- Options ---
              Text(
                'Browse',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context,
                icon: Icons.translate_rounded,
                title: 'Quran with Translation',
                description: 'Arabic text with English translation',
                color: Colors.orangeAccent,
                onTap: () {
                  which = 2;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ArabicQuran()));
                },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.bookmarks_rounded,
                title: 'Bookmarked Verses',
                description: 'View your saved verses',
                color: Colors.tealAccent,
                onTap: () => _showBookmarksList(context),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.search_rounded,
                title: 'Search Verses',
                description: 'Find specific verses easily',
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VerseSearchPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: isDark ? color : color.withOpacity(0.8)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARABIC QURAN (SURAH LIST)
// ---------------------------------------------------------------------------

class ArabicQuran extends StatefulWidget {
  const ArabicQuran({super.key});
  @override
  State<ArabicQuran> createState() => _ArabicQuranState();
}

class _ArabicQuranState extends State<ArabicQuran> {
  TextEditingController searchController = TextEditingController();
  List<int> filteredSurahs = List.generate(114, (index) => index + 1);
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    // Preserving logic
    getQuran((updatequran) {
      if (mounted) setState(() => quranList = updatequran);
    });
  }

  void _onFontSettingsChanged() {
    if (mounted) setState(() {});
  }

  void filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSurahs = List.generate(114, (index) => index + 1);
        isSearching = false;
      } else {
        isSearching = true;
        filteredSurahs = [];
        if (RegExp(r'^[0-9]+$').hasMatch(query)) {
          int? surahNumber = int.tryParse(query);
          if (surahNumber != null && surahNumber >= 1 && surahNumber <= 114) {
            filteredSurahs.add(surahNumber);
          }
        } else {
          for (int i = 1; i <= 114; i++) {
            String surahName = quran.getSurahName(i).toLowerCase();
            if (surahName.contains(query.toLowerCase())) {
              filteredSurahs.add(i);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Surahs',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSurahs,
                decoration: InputDecoration(
                  hintText: 'Search Surah...',
                  hintStyle:
                      GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: colorScheme.primary),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            searchController.clear();
                            filterSurahs('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredSurahs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                int surahNumber = filteredSurahs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      surahnum = surahNumber;
                      surahname = quran.getSurahName(surahNumber);
                      juzname = quran.getJuzURL(surahNumber);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => which == 2
                              ? const TranslatedQuran()
                              : const thetextofquran(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '$surahNumber',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quran.getSurahName(surahNumber),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${quran.getVerseCount(surahNumber)} Verses',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            quran.getSurahNameArabic(surahNumber),
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARABIC ONLY READING VIEW
// ---------------------------------------------------------------------------

class thetextofquran extends StatefulWidget {
  const thetextofquran({super.key});
  @override
  State<thetextofquran> createState() => _thetextofquranState();
}

class _thetextofquranState extends State<thetextofquran> {
  // Logic from original code
  void filterAyahs(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredAyahs =
            List.generate(quran.getVerseCount(surahnum), (index) => index + 1);
      } else {
        final RegExp numberRegex = RegExp(r'^\d+$');
        if (numberRegex.hasMatch(query)) {
          int ayahNumber = int.parse(query);
          if (ayahNumber >= 1 && ayahNumber <= quran.getVerseCount(surahnum)) {
            filteredAyahs = [ayahNumber];
          } else {
            filteredAyahs = [];
          }
        } else {
          filteredAyahs = [];
          for (int i = 1; i <= quran.getVerseCount(surahnum); i++) {
            String ayahText = quran.getVerse(surahnum, i).toLowerCase();
            if (ayahText.contains(query.toLowerCase())) {
              filteredAyahs.add(i);
            }
          }
        }
      }
    });
  }

  void scrollToAyah(int ayahNumber) {
    if (scrollController.hasClients) {
      double position = (ayahNumber - 1) * 212.0;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  final TextEditingController searchController = TextEditingController();
  List<int> filteredAyahs = [];
  bool isSearching = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    filteredAyahs =
        List.generate(quran.getVerseCount(surahnum), (index) => index + 1);
    BookmarkService.addListener(_onBookmarkChanged);
  }

  @override
  void dispose() {
    BookmarkService.removeListener(_onBookmarkChanged);
    super.dispose();
  }

  void _onBookmarkChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final isCurrentlyBookmarked =
        BookmarkService.isBookmarked(surahnum, ayahNumber);
    if (isCurrentlyBookmarked) {
      await BookmarkService.removeBookmark(surahnum, ayahNumber);
    } else {
      final bookmark = Bookmark(
        surahNumber: surahnum,
        verseNumber: ayahNumber,
        surahName: surahname,
        surahNameArabic: quran.getSurahNameArabic(surahnum),
        verseText: quran.getVerse(surahnum, ayahNumber),
        translationText: '',
        createdAt: DateTime.now(),
      );
      await BookmarkService.addBookmark(bookmark);
    }
    if (mounted) setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return _buildReadingScaffold(
      context: context,
      title: surahname,
      surahNumber: surahnum,
      searchController: searchController,
      onSearch: filterAyahs,
      isSearching: isSearching,
      filteredList: filteredAyahs,
      scrollController: scrollController,
      onClearSearch: () {
        searchController.clear();
        filterAyahs('');
      },
      itemBuilder: (context, index) {
        int ayahNumber = filteredAyahs[index];
        bool isBookmarked = BookmarkService.isBookmarked(surahnum, ayahNumber);

        return _buildAyahCard(
          context,
          ayahNumber: ayahNumber,
          arabicText: quran.getVerse(surahnum, ayahNumber),
          translation: null, // No translation
          isBookmarked: isBookmarked,
          onBookmark: () => _toggleBookmark(ayahNumber),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// TRANSLATED QURAN READING VIEW
// ---------------------------------------------------------------------------

class TranslatedQuran extends StatefulWidget {
  const TranslatedQuran({super.key});
  @override
  State<TranslatedQuran> createState() => _TranslatedQuranState();
}

class _TranslatedQuranState extends State<TranslatedQuran> {
  final TextEditingController searchController = TextEditingController();
  List<int> filteredAyahs = [];
  bool isSearching = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    filteredAyahs =
        List.generate(quran.getVerseCount(surahnum), (index) => index + 1);
    BookmarkService.addListener(_onBookmarkChanged);
  }

  @override
  void dispose() {
    BookmarkService.removeListener(_onBookmarkChanged);
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onBookmarkChanged() {
    if (mounted) setState(() {});
  }

  void filterAyahs(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredAyahs =
            List.generate(quran.getVerseCount(surahnum), (index) => index + 1);
      } else {
        final RegExp numberRegex = RegExp(r'^\d+$');
        if (numberRegex.hasMatch(query)) {
          int ayahNumber = int.parse(query);
          if (ayahNumber >= 1 && ayahNumber <= quran.getVerseCount(surahnum)) {
            filteredAyahs = [ayahNumber];
          } else {
            filteredAyahs = [];
          }
        } else {
          filteredAyahs = [];
          for (int i = 1; i <= quran.getVerseCount(surahnum); i++) {
            String ayahText = quran.getVerse(surahnum, i).toLowerCase();
            String translation =
                quran.getVerseTranslation(surahnum, i).toLowerCase();
            if (ayahText.contains(query.toLowerCase()) ||
                translation.contains(query.toLowerCase())) {
              filteredAyahs.add(i);
            }
          }
        }
      }
    });
  }

  void scrollToAyah(int ayahNumber) {
    if (scrollController.hasClients) {
      double position = (ayahNumber - 1) * 300.0;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final isCurrentlyBookmarked =
        BookmarkService.isBookmarked(surahnum, ayahNumber);
    if (isCurrentlyBookmarked) {
      await BookmarkService.removeBookmark(surahnum, ayahNumber);
    } else {
      final bookmark = Bookmark(
        surahNumber: surahnum,
        verseNumber: ayahNumber,
        surahName: surahname,
        surahNameArabic: quran.getSurahNameArabic(surahnum),
        verseText: quran.getVerse(surahnum, ayahNumber),
        translationText: quran.getVerseTranslation(surahnum, ayahNumber),
        createdAt: DateTime.now(),
      );
      await BookmarkService.addBookmark(bookmark);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildReadingScaffold(
      context: context,
      title: surahname,
      surahNumber: surahnum,
      searchController: searchController,
      onSearch: filterAyahs,
      isSearching: isSearching,
      filteredList: filteredAyahs,
      scrollController: scrollController,
      onClearSearch: () {
        searchController.clear();
        filterAyahs('');
      },
      itemBuilder: (context, index) {
        int ayahNumber = filteredAyahs[index];
        bool isBookmarked = BookmarkService.isBookmarked(surahnum, ayahNumber);

        return _buildAyahCard(
          context,
          ayahNumber: ayahNumber,
          arabicText: quran.getVerse(surahnum, ayahNumber),
          translation: quran.getVerseTranslation(surahnum, ayahNumber),
          isBookmarked: isBookmarked,
          onBookmark: () => _toggleBookmark(ayahNumber),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED WIDGETS FOR READING VIEWS
// ---------------------------------------------------------------------------

Widget _buildReadingScaffold({
  required BuildContext context,
  required String title,
  required int surahNumber,
  required TextEditingController searchController,
  required Function(String) onSearch,
  required bool isSearching,
  required List<int> filteredList,
  required ScrollController scrollController,
  required VoidCallback onClearSearch,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Scaffold(
    backgroundColor: colorScheme.surface,
    appBar: AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            'Surah $surahNumber',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search Ayah...',
                hintStyle:
                    GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                prefixIcon:
                    Icon(Icons.search_rounded, color: colorScheme.primary),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: onClearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ),
        if (isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  filteredList.isEmpty
                      ? 'No ayahs found'
                      : '${filteredList.length} results',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: filteredList.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    ),
  );
}

Widget _buildAyahCard(
  BuildContext context, {
  required int ayahNumber,
  required String arabicText,
  String? translation,
  required bool isBookmarked,
  required VoidCallback onBookmark,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Row: Number & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Ayah $ayahNumber',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isBookmarked
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Arabic Text
        Text(
          arabicText,
          style: GoogleFonts.amiri(
            // Or UthmanicHafs
            fontSize: FontSettings.arabicFontSize * 1.5,
            height: 2.0,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),

        // Translation
        if (translation != null) ...[
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            translation,
            style: GoogleFonts.inter(
              fontSize: FontSettings.englishFontSize * 1.1,
              height: 1.6,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// BOOKMARKS PAGE
// ---------------------------------------------------------------------------

class BookmarksListPage extends StatefulWidget {
  final bool isDarkMode;
  final double fontSizeMultiplier;

  const BookmarksListPage({
    super.key,
    required this.isDarkMode,
    required this.fontSizeMultiplier,
  });

  @override
  State<BookmarksListPage> createState() => _BookmarksListPageState();
}

class _BookmarksListPageState extends State<BookmarksListPage> {
  @override
  void initState() {
    super.initState();
    BookmarkService.addListener(_onBookmarkChanged);
    BookmarkService.loadBookmarks();
  }

  @override
  void dispose() {
    BookmarkService.removeListener(_onBookmarkChanged);
    super.dispose();
  }

  void _onBookmarkChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    await BookmarkService.removeBookmark(
        bookmark.surahNumber, bookmark.verseNumber);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkService.bookmarks;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Bookmarks',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 60, color: colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookmarks.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return Dismissible(
                  key: Key('${bookmark.surahNumber}_${bookmark.verseNumber}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.delete_outline, color: colorScheme.error),
                  ),
                  onDismissed: (direction) => _removeBookmark(bookmark),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${bookmark.surahName} : ${bookmark.verseNumber}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            Icon(Icons.bookmark_rounded,
                                size: 20, color: colorScheme.primary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookmark.verseText,
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (bookmark.translationText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            bookmark.translationText,
                            style: GoogleFonts.inter(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// VERSE SEARCH PAGE
// ---------------------------------------------------------------------------

class VerseSearchPage extends StatefulWidget {
  const VerseSearchPage({super.key});

  @override
  State<VerseSearchPage> createState() => _VerseSearchPageState();
}

class _VerseSearchPageState extends State<VerseSearchPage> {
  final TextEditingController surahController = TextEditingController();
  final TextEditingController ayahController = TextEditingController();
  int? selectedSurah;
  int? selectedAyah;
  String? verseText;
  String? translationText;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    BookmarkService.addListener(_onBookmarkChanged);
  }

  @override
  void dispose() {
    BookmarkService.removeListener(_onBookmarkChanged);
    surahController.dispose();
    ayahController.dispose();
    super.dispose();
  }

  void _onBookmarkChanged() {
    if (mounted && selectedSurah != null && selectedAyah != null) {
      setState(() {
        isBookmarked =
            BookmarkService.isBookmarked(selectedSurah!, selectedAyah!);
      });
    }
  }

  void _searchVerse() {
    final surahNum = int.tryParse(surahController.text);
    final ayahNum = int.tryParse(ayahController.text);

    if (surahNum == null || ayahNum == null || surahNum < 1 || surahNum > 114) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid input')));
      return;
    }

    if (ayahNum < 1 || ayahNum > quran.getVerseCount(surahNum)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayah number out of range')));
      return;
    }

    setState(() {
      selectedSurah = surahNum;
      selectedAyah = ayahNum;
      verseText = quran.getVerse(surahNum, ayahNum);
      translationText = quran.getVerseTranslation(surahNum, ayahNum);
      isBookmarked = BookmarkService.isBookmarked(surahNum, ayahNum);
    });
  }

  Future<void> _toggleBookmark() async {
    if (selectedSurah == null || selectedAyah == null) return;
    if (isBookmarked) {
      await BookmarkService.removeBookmark(selectedSurah!, selectedAyah!);
    } else {
      final bookmark = Bookmark(
        surahNumber: selectedSurah!,
        verseNumber: selectedAyah!,
        surahName: quran.getSurahName(selectedSurah!),
        surahNameArabic: quran.getSurahNameArabic(selectedSurah!),
        verseText: verseText!,
        translationText: translationText!,
        createdAt: DateTime.now(),
      );
      await BookmarkService.addBookmark(bookmark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Find Verse',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                            context, surahController, 'Surah (1-114)'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInput(context, ayahController, 'Ayah No.'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _searchVerse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('Search',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (verseText != null)
              _buildAyahCard(
                context,
                ayahNumber: selectedAyah!,
                arabicText: verseText!,
                translation: translationText,
                isBookmarked: isBookmarked,
                onBookmark: _toggleBookmark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
      BuildContext context, TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
