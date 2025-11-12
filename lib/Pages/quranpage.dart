import 'package:flutter/material.dart';
import 'package:molvi/Features/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:molvi/Pages/settings.dart';
import 'package:molvi/Features/bookmark_service.dart';

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
    if (mounted) {
      setState(() {});
    }
  }

  void _showBookmarksList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookmarksListPage(
          isDarkMode: false,
          fontSizeMultiplier: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : null,
          gradient: Theme.of(context).brightness == Brightness.light
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.1),
                    Theme.of(context).colorScheme.surface,
                  ],
                )
              : null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.04,
                    ),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Text(
                          'Choose your reading method',
                          style: GoogleFonts.amiriQuran(
                            fontSize: FontSettings.englishFontSize * 1.3,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  _buildOptionCard(
                    context,
                    icon: Icons.translate,
                    title: 'Quran with Translation',
                    description: 'Arabic text with English translation',
                    onTap: () {
                      which = 2;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArabicQuran()));
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildOptionCard(
                    context,
                    icon: Icons.bookmarks_rounded,
                    title: 'Bookmarked Verses',
                    description: 'View your saved verses with notes',
                    onTap: () => _showBookmarksList(context),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildOptionCard(
                    context,
                    icon: Icons.search_rounded,
                    title: 'Search Verses',
                    description:
                        'Search specific verse by surah and ayah number',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerseSearchPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            ),
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
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardTheme.color,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.12,
                height: MediaQuery.of(context).size.width * 0.12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.amiriQuran(
                        fontSize: FontSettings.arabicFontSize * 1.1,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: FontSettings.englishFontSize * 0.9,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
                size: MediaQuery.of(context).size.width * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    getQuran((updatequran) {
      setState(() {
        quranList = updatequran;
      });
    });
  }

  void _onFontSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'القرآن الکریم',
          style: TextStyle(
            fontSize: FontSettings.arabicFontSize * 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'UthmanicHafs',
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSurahs,
                decoration: InputDecoration(
                  hintText: 'Search by surah name or number...',
                  hintStyle: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            searchController.clear();
                            filterSurahs('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSearching)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filteredSurahs.isEmpty
                          ? 'No surahs found'
                          : '${filteredSurahs.length} surah(s) found',
                      style: GoogleFonts.inter(
                        fontSize: FontSettings.englishFontSize * 0.85,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: filteredSurahs.length,
                itemBuilder: (context, index) {
                  int surahNumber = filteredSurahs[index];
                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$surahNumber',
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: FontSettings.englishFontSize * 0.85,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          quran.getSurahName(surahNumber),
                          style: GoogleFonts.amiriQuran(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: FontSettings.arabicFontSize * 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          '${quran.getVerseCount(surahNumber)} آیات',
                          style: GoogleFonts.inter(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: FontSettings.arabicFontSize * 0.8,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class thetextofquran extends StatefulWidget {
  const thetextofquran({super.key});
  @override
  State<thetextofquran> createState() => _thetextofquranState();
}

class _thetextofquranState extends State<thetextofquran> {
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final isCurrentlyBookmarked =
        BookmarkService.isBookmarked(surahnum, ayahNumber);

    if (isCurrentlyBookmarked) {
      await BookmarkService.removeBookmark(surahnum, ayahNumber);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark removed'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } else {
      final bookmark = Bookmark(
        surahNumber: surahnum,
        verseNumber: ayahNumber,
        surahName: surahname,
        surahNameArabic: quran.getSurahNameArabic(surahnum),
        verseText: quran.getVerse(surahnum, ayahNumber),
        translationText: '', // No translation in Arabic-only view
        createdAt: DateTime.now(),
      );

      await BookmarkService.addBookmark(bookmark);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verse bookmarked'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              surahname,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                surahnum.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterAyahs,
                decoration: InputDecoration(
                  hintText: 'Search by ayah number or text...',
                  hintStyle: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: Icon(
                            filteredAyahs.length == 1
                                ? Icons.my_location
                                : Icons.clear,
                            color: filteredAyahs.length == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          onPressed: () {
                            if (filteredAyahs.length == 1) {
                              scrollToAyah(filteredAyahs.first);
                            } else {
                              searchController.clear();
                              filterAyahs('');
                            }
                          },
                          tooltip: filteredAyahs.length == 1
                              ? 'Go to ayah'
                              : 'Clear',
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSearching)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filteredAyahs.isEmpty
                          ? 'No ayahs found'
                          : '${filteredAyahs.length} ayah(s) found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: filteredAyahs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  int ayahNumber = filteredAyahs[index];
                  bool isBookmarked =
                      BookmarkService.isBookmarked(surahnum, ayahNumber);

                  return Card(
                    elevation: 4,
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "آیت $ayahNumber",
                                        style: GoogleFonts.amiriQuran(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  onPressed: () => _toggleBookmark(ayahNumber),
                                  tooltip: isBookmarked
                                      ? 'Remove bookmark'
                                      : 'Add bookmark',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                quran.getVerse(surahnum, ayahNumber),
                                style: GoogleFonts.amiriQuran(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSettings.arabicFontSize * 1.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
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
      ),
    );
  }
}

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
    if (mounted) {
      setState(() {});
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark removed'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verse bookmarked'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              surahname,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                surahnum.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterAyahs,
                decoration: InputDecoration(
                  hintText:
                      'Search by ayah number, Arabic text, or translation...',
                  hintStyle: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: Icon(
                            filteredAyahs.length == 1
                                ? Icons.my_location
                                : Icons.clear,
                            color: filteredAyahs.length == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          onPressed: () {
                            if (filteredAyahs.length == 1) {
                              scrollToAyah(filteredAyahs.first);
                            } else {
                              searchController.clear();
                              filterAyahs('');
                            }
                          },
                          tooltip: filteredAyahs.length == 1
                              ? 'Go to ayah'
                              : 'Clear',
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSearching)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filteredAyahs.isEmpty
                          ? 'No ayahs found'
                          : '${filteredAyahs.length} ayah(s) found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: filteredAyahs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  int ayahNumber = filteredAyahs[index];
                  bool isBookmarked =
                      BookmarkService.isBookmarked(surahnum, ayahNumber);

                  return Card(
                    elevation: 4,
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "آیت $ayahNumber",
                                        style: GoogleFonts.amiriQuran(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  onPressed: () => _toggleBookmark(ayahNumber),
                                  tooltip: isBookmarked
                                      ? 'Remove bookmark'
                                      : 'Add bookmark',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                quran.getVerse(surahnum, ayahNumber),
                                style: TextStyle(
                                  fontFamily: 'UthmanicHafs',
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSettings.arabicFontSize * 1.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                quran.getVerseTranslation(surahnum, ayahNumber),
                                style: GoogleFonts.inter(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSettings.englishFontSize * 1.1,
                                  fontWeight: FontWeight.w400,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.left,
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
      ),
    );
  }
}

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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    await BookmarkService.removeBookmark(
        bookmark.surahNumber, bookmark.verseNumber);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark removed'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkService.bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarked Verses',
          style: GoogleFonts.inter(
            fontSize: FontSettings.englishFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: bookmarks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarked verses yet',
                      style: GoogleFonts.inter(
                        fontSize: FontSettings.englishFontSize * 1.1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start reading and bookmark your favorite verses',
                      style: GoogleFonts.inter(
                        fontSize: FontSettings.englishFontSize * 0.9,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookmarks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  return Card(
                    elevation: 4,
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${bookmark.surahName} ${bookmark.verseNumber}',
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize:
                                          FontSettings.englishFontSize * 0.85,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _removeBookmark(bookmark),
                                  tooltip: 'Remove bookmark',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                bookmark.verseText,
                                style: TextStyle(
                                  fontFamily: 'UthmanicHafs',
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSettings.arabicFontSize * 1.3,
                                  fontWeight: FontWeight.w500,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            if (bookmark.translationText.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  bookmark.translationText,
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize:
                                        FontSettings.englishFontSize * 1.0,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Bookmarked on ${bookmark.createdAt.day}/${bookmark.createdAt.month}/${bookmark.createdAt.year}',
                              style: GoogleFonts.inter(
                                fontSize: FontSettings.englishFontSize * 0.8,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

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

    if (surahNum == null || ayahNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid surah and ayah numbers'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (surahNum < 1 || surahNum > 114) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surah number must be between 1 and 114'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (ayahNum < 1 || ayahNum > quran.getVerseCount(surahNum)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ayah number must be between 1 and ${quran.getVerseCount(surahNum)}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark removed'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verse bookmarked'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Verse',
          style: GoogleFonts.inter(
            fontSize: FontSettings.englishFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter Verse Details',
                        style: GoogleFonts.inter(
                          fontSize: FontSettings.englishFontSize * 1.1,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: surahController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Surah Number (1-114)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                              ),
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: ayahController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Ayah Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                              ),
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _searchVerse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Search Verse',
                          style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (verseText != null && translationText != null) ...[
                Expanded(
                  child: Card(
                    elevation: 4,
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      '${quran.getSurahName(selectedSurah!)} - آیت $selectedAyah',
                                      style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize:
                                            FontSettings.englishFontSize * 0.9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: isBookmarked
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                    onPressed: _toggleBookmark,
                                    tooltip: isBookmarked
                                        ? 'Remove bookmark'
                                        : 'Add bookmark',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  verseText!,
                                  style: TextStyle(
                                    fontFamily: 'UthmanicHafs',
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: FontSettings.arabicFontSize * 1.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  translationText!,
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize:
                                        FontSettings.englishFontSize * 1.1,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter surah and ayah numbers to search',
                          style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 1.0,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
