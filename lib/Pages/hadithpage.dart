import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Pages/settings.dart';
import 'package:molvi/Features/hadith_bookmark_service.dart';

// ==============================================================================
// 1. MODELS
// ==============================================================================

class HadithBook {
  final String bookName;
  final String bookSlug;
  final int totalHadiths;

  HadithBook({
    required this.bookName,
    required this.bookSlug,
    required this.totalHadiths,
  });
}

class HadithData {
  final String hadithNumber;
  final String hadithEnglish;
  final String hadithArabic;
  final String bookSlug;
  final String bookName;
  final String status; // Grade

  HadithData({
    required this.hadithNumber,
    required this.hadithEnglish,
    required this.hadithArabic,
    required this.bookSlug,
    required this.bookName,
    required this.status,
  });

  factory HadithData.fromCdnJson(
      Map<String, dynamic> json, String slug, String name) {
    // The CDN data structure is simple: { "hadithnumber": 1, "text": "..." }
    // Note: The CDN separates English and Arabic into different files.
    // This model assumes we merge them or handle single language display for simplicity.

    // Grades are sometimes inside a 'grades' list or missing in the minified version.
    String grade = '';
    if (json['grades'] != null && (json['grades'] as List).isNotEmpty) {
      grade = json['grades'][0]['grade'] ?? '';
    }

    return HadithData(
      hadithNumber: json['hadithnumber']?.toString() ?? '0',
      hadithEnglish: _cleanText(json['text'] ?? ''),
      hadithArabic: '', // Populated later if merging
      bookSlug: slug,
      bookName: name,
      status: grade,
    );
  }

  // Create a copy with Arabic text added
  HadithData copyWithArabic(String arabicText) {
    return HadithData(
      hadithNumber: this.hadithNumber,
      hadithEnglish: this.hadithEnglish,
      hadithArabic: _cleanText(arabicText),
      bookSlug: this.bookSlug,
      bookName: this.bookName,
      status: this.status,
    );
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}

// ==============================================================================
// 2. API SERVICE (CDN BASED - 100% WORKING)
// ==============================================================================

class HadithApiService {
  // We use the JSONs hosted on GitHub via jsDelivr CDN
  static const String cdnBase =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  // Hardcoded books ensure the main page works instantly without fetching metadata
  static List<HadithBook> getBooks() {
    return [
      HadithBook(
          bookName: 'Sahih Bukhari',
          bookSlug: 'eng-bukhari',
          totalHadiths: 7563),
      HadithBook(
          bookName: 'Sahih Muslim', bookSlug: 'eng-muslim', totalHadiths: 3033),
      HadithBook(
          bookName: 'Sunan Abu Dawood',
          bookSlug: 'eng-abudawud',
          totalHadiths: 5274),
      HadithBook(
          bookName: 'Jami At-Tirmidhi',
          bookSlug: 'eng-tirmidhi',
          totalHadiths: 3956),
      HadithBook(
          bookName: 'Sunan An-Nasa\'i',
          bookSlug: 'eng-nasai',
          totalHadiths: 5758),
      HadithBook(
          bookName: 'Sunan Ibn Majah',
          bookSlug: 'eng-ibnmajah',
          totalHadiths: 4341),
      HadithBook(
          bookName: 'Muwatta Malik', bookSlug: 'eng-malik', totalHadiths: 1858),
    ];
  }

  // Fetch a "Section" (Chapter) of hadiths
  // Using sections is better than fetching the 10MB+ full book file
  static Future<List<HadithData>> getHadiths({
    required String bookSlug,
    required String bookName,
    int section = 1,
  }) async {
    try {
      // 1. Fetch English Section
      final engUrl = Uri.parse('$cdnBase/$bookSlug/sections/$section.json');
      final engResponse = await http.get(engUrl);

      // 2. Fetch Arabic Section (Swap 'eng' prefix with 'ara')
      // Note: Arabic slug usually replaces "eng-" with "ara-"
      final araSlug = bookSlug.replaceFirst('eng-', 'ara-');
      final araUrl = Uri.parse('$cdnBase/$araSlug/sections/$section.json');
      final araResponse = await http.get(araUrl);

      if (engResponse.statusCode == 200) {
        final Map<String, dynamic> engData = json.decode(engResponse.body);
        final List<dynamic> engList = engData['hadiths'] ?? [];

        // Parse Arabic if available
        Map<String, String> arabicMap = {};
        if (araResponse.statusCode == 200) {
          final Map<String, dynamic> araData = json.decode(araResponse.body);
          final List<dynamic> araList = araData['hadiths'] ?? [];
          for (var item in araList) {
            // Map by hadithnumber for merging
            arabicMap[item['hadithnumber'].toString()] =
                _cleanText(item['text'] ?? '');
          }
        }

        // Merge and Return
        return engList.map((jsonItem) {
          HadithData hadith =
              HadithData.fromCdnJson(jsonItem, bookSlug, bookName);
          // Attach Arabic text if found
          if (arabicMap.containsKey(hadith.hadithNumber)) {
            hadith = hadith.copyWithArabic(arabicMap[hadith.hadithNumber]!);
          }
          return hadith;
        }).toList();
      } else {
        // If section doesn't exist or error (End of book)
        return [];
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  static Future<HadithData> getRandomHadith() async {
    try {
      // Random Book
      final books = getBooks();
      final randomBook = books[Random().nextInt(books.length)];

      // Random Section (Approx 1-50 is safe for most books)
      final randomSection = Random().nextInt(30) + 1;

      final hadiths = await getHadiths(
          bookSlug: randomBook.bookSlug,
          bookName: randomBook.bookName,
          section: randomSection);

      if (hadiths.isNotEmpty) {
        return hadiths[Random().nextInt(hadiths.length)];
      }
    } catch (_) {}

    // Fallback if network fails
    return HadithData(
      hadithNumber: '1',
      hadithEnglish: 'Actions are judged by intentions...',
      hadithArabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      bookSlug: 'eng-bukhari',
      bookName: 'Sahih Bukhari',
      status: 'Sahih',
    );
  }

  // Add this inside HadithApiService class
  static Future<HadithData?> getHadithByNumber({
    required String bookSlug,
    required String bookName,
    required String hadithNumber,
  }) async {
    try {
      // CDN Endpoint for specific hadith number
      // URL: .../editions/{slug}/hadiths/{number}.json
      final engUrl = Uri.parse('$cdnBase/$bookSlug/hadiths/$hadithNumber.json');
      final araSlug = bookSlug.replaceFirst('eng-', 'ara-');
      final araUrl = Uri.parse('$cdnBase/$araSlug/hadiths/$hadithNumber.json');

      final engResponse = await http.get(engUrl);

      if (engResponse.statusCode == 200) {
        final engJson = json.decode(engResponse.body);
        // Sometimes the CDN returns a list, sometimes a single object for specific ID
        final engItem = (engJson is List) ? engJson.first : engJson;

        var hadith = HadithData.fromCdnJson(engItem, bookSlug, bookName);

        // Try to get Arabic
        try {
          final araResponse = await http.get(araUrl);
          if (araResponse.statusCode == 200) {
            final araJson = json.decode(araResponse.body);
            final araItem = (araJson is List) ? araJson.first : araJson;
            hadith = hadith.copyWithArabic(_cleanText(araItem['text'] ?? ''));
          }
        } catch (_) {} // Ignore arabic failure, return english at least

        return hadith;
      }
      return null; // Not found
    } catch (e) {
      return null;
    }
  }

  static String _cleanText(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

// ==============================================================================
// 3. MAIN HADITH PAGE
// ==============================================================================

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});
  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_redraw);
  }

  @override
  void dispose() {
    FontSettings.removeListener(_redraw);
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
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
              // HEADER
              _buildHeader(context),

              const SizedBox(height: 24),

              // BANNER
              _buildBanner(context, isDark),

              const SizedBox(height: 30),

              // OPTIONS
              Text(
                'Browse',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context,
                icon: Icons.auto_stories_rounded,
                title: 'Browse Books',
                description: 'Read the major collections',
                color: Colors.greenAccent,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HadithBooksPage())),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.bookmarks_rounded,
                title: 'Bookmarks',
                description: 'Your saved hadiths',
                color: Colors.orangeAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HadithBookmarksListPage())),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.search_rounded,
                title: 'Search Hadith',
                description: 'Find hadiths',
                color: Colors.purpleAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HadithSearchPage())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Icon(Icons.library_books_rounded,
                color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hadith Collection',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              Text('Wisdom of the Prophet (?)',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.menu_book_rounded, size: 40, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Sunnah & Hadith',
            style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Authentic narrations from Sahih Bukhari, Muslim, and more.',
            style: GoogleFonts.inter(
                color: colorScheme.onSurfaceVariant, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required Color color,
      required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
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
                      color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(icon,
                      color: isDark ? color : color.withOpacity(0.8)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant)),
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

// ==============================================================================
// 4. HADITH BOOKS PAGE
// ==============================================================================

class HadithBooksPage extends StatelessWidget {
  const HadithBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Uses the hardcoded list for instant loading
    final books = HadithApiService.getBooks();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Collections',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: books.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text('${index + 1}',
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ),
              title: Text(book.bookName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('${book.totalHadiths} Hadiths',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: colorScheme.onSurfaceVariant)),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HadithListPage(book: book)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==============================================================================
// 5. HADITH LIST PAGE (Infinite Scroll)
// ==============================================================================

class HadithListPage extends StatefulWidget {
  final HadithBook book;
  const HadithListPage({super.key, required this.book});
  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  List<HadithData> hadiths = [];
  bool isLoading = true;
  int currentSection = 1;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_redraw);
    HadithBookmarkService.addListener(_redraw);
    _loadHadiths();
  }

  @override
  void dispose() {
    FontSettings.removeListener(_redraw);
    HadithBookmarkService.removeListener(_redraw);
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  Future<void> _loadHadiths() async {
    if (!hasMore) return;

    try {
      final newHadiths = await HadithApiService.getHadiths(
        bookSlug: widget.book.bookSlug,
        bookName: widget.book.bookName,
        section: currentSection,
      );

      if (newHadiths.isEmpty) {
        setState(() {
          hasMore = false;
          isLoading = false;
        });
      } else {
        setState(() {
          hadiths.addAll(newHadiths);
          currentSection++;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleBookmark(HadithData hadith) async {
    final isBookmarked = HadithBookmarkService.isBookmarked(
        hadith.bookSlug, hadith.hadithNumber);
    if (isBookmarked) {
      await HadithBookmarkService.removeBookmark(
          hadith.bookSlug, hadith.hadithNumber);
    } else {
      await HadithBookmarkService.addBookmark(HadithBookmark(
        bookSlug: hadith.bookSlug,
        bookName: hadith.bookName,
        hadithNumber: hadith.hadithNumber,
        headingEnglish: '',
        headingUrdu: '',
        headingArabic: '',
        hadithEnglish: hadith.hadithEnglish,
        hadithUrdu: '',
        hadithArabic: hadith.hadithArabic,
        chapterNumber: '',
        volume: '',
        status: hadith.status,
        createdAt: DateTime.now(),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.book.bookName,
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: hadiths.isEmpty && isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: hadiths.length + 1,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == hadiths.length) {
                  return hasMore
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: ElevatedButton(
                                  onPressed: _loadHadiths,
                                  child: const Text("Load More"))),
                        )
                      : const SizedBox();
                }

                final hadith = hadiths[index];
                final isBookmarked = HadithBookmarkService.isBookmarked(
                    hadith.bookSlug, hadith.hadithNumber);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('#${hadith.hadithNumber}',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer)),
                          ),
                          Row(
                            children: [
                              if (hadith.status.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(hadith.status,
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                ),
                              IconButton(
                                onPressed: () => _toggleBookmark(hadith),
                                icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: isBookmarked
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (hadith.hadithArabic.isNotEmpty)
                        Text(
                          hadith.hadithArabic,
                          style: GoogleFonts.amiri(
                              fontSize: FontSettings.arabicFontSize * 1.3,
                              height: 1.8,
                              color: colorScheme.onSurface),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      if (hadith.hadithArabic.isNotEmpty)
                        Divider(
                            color: colorScheme.outline.withOpacity(0.2),
                            height: 32),
                      Text(
                        hadith.hadithEnglish,
                        style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize,
                            height: 1.5,
                            color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ==============================================================================
// 6. RANDOM PAGE & BOOKMARKS
// ==============================================================================

class RandomHadithPage extends StatefulWidget {
  const RandomHadithPage({super.key});
  @override
  State<RandomHadithPage> createState() => _RandomHadithPageState();
}

class _RandomHadithPageState extends State<RandomHadithPage> {
  HadithData? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    setState(() => loading = true);
    final res = await HadithApiService.getRandomHadith();
    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Random'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch)
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 40, color: colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 20),
                    if (data?.hadithArabic.isNotEmpty == true) ...[
                      Text(data!.hadithArabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(fontSize: 22, height: 1.8)),
                      const SizedBox(height: 20),
                    ],
                    Text(data?.hadithEnglish ?? 'Error',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 16, height: 1.6)),
                    const SizedBox(height: 24),
                    Chip(
                      label: Text('${data!.bookName} #${data!.hadithNumber}',
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class HadithBookmarksListPage extends StatefulWidget {
  const HadithBookmarksListPage({super.key});
  @override
  State<HadithBookmarksListPage> createState() =>
      _HadithBookmarksListPageState();
}

class _HadithBookmarksListPageState extends State<HadithBookmarksListPage> {
  @override
  void initState() {
    super.initState();
    HadithBookmarkService.addListener(_redraw);
  }

  @override
  void dispose() {
    HadithBookmarkService.removeListener(_redraw);
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = HadithBookmarkService.bookmarks;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
          title: const Text('Bookmarks'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: colorScheme.surface),
      body: bookmarks.isEmpty
          ? Center(
              child: Text("No bookmarks yet",
                  style:
                      GoogleFonts.inter(color: colorScheme.onSurfaceVariant)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookmarks.length,
              itemBuilder: (c, i) {
                final item = bookmarks[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(item.bookName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary)),
                    subtitle: Text(item.hadithEnglish,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        HadithBookmarkService.removeBookmark(
                            item.bookSlug, item.hadithNumber);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class HadithSearchPage extends StatefulWidget {
  const HadithSearchPage({super.key});
  @override
  State<HadithSearchPage> createState() => _HadithSearchPageState();
}

class _HadithSearchPageState extends State<HadithSearchPage> {
  final TextEditingController _numberController = TextEditingController();
  HadithBook? _selectedBook;
  HadithData? _foundHadith;
  bool _isLoading = false;
  String? _error;

  // Load books for dropdown
  final List<HadithBook> _books = HadithApiService.getBooks();

  @override
  void initState() {
    super.initState();
    _selectedBook = _books.first; // Default to first book
  }

  void _search() async {
    if (_numberController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _foundHadith = null;
    });

    final result = await HadithApiService.getHadithByNumber(
      bookSlug: _selectedBook!.bookSlug,
      bookName: _selectedBook!.bookName,
      hadithNumber: _numberController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result != null) {
        _foundHadith = result;
      } else {
        _error =
            "Hadith #${_numberController.text} not found in ${_selectedBook!.bookName}.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Find Hadith',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SEARCH INPUTS CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Book',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: colorScheme.primary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<HadithBook>(
                        value: _selectedBook,
                        isExpanded: true,
                        items: _books.map((book) {
                          return DropdownMenuItem(
                            value: book,
                            child:
                                Text(book.bookName, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedBook = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Hadith Number',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: colorScheme.primary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 1, 45, 100',
                      hintStyle: GoogleFonts.inter(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: colorScheme.outline.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: colorScheme.outline.withOpacity(0.2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Search',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- RESULTS AREA ---
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_error!,
                            style: TextStyle(color: colorScheme.onSurface))),
                  ],
                ),
              ),

            if (_foundHadith != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${_foundHadith!.hadithNumber}',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer),
                          ),
                        ),
                        if (_foundHadith!.status.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _foundHadith!.status,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_foundHadith!.hadithArabic.isNotEmpty)
                      Text(
                        _foundHadith!.hadithArabic,
                        style: GoogleFonts.amiri(
                          fontSize: FontSettings.arabicFontSize * 1.3,
                          height: 1.8,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _foundHadith!.hadithEnglish,
                      style: GoogleFonts.inter(
                        fontSize: FontSettings.englishFontSize,
                        height: 1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
