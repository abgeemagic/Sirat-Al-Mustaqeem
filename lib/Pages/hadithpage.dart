import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Pages/settings.dart';
import 'package:molvi/Features/hadith_bookmark_service.dart';

class HadithBook {
  final String bookName;
  final String bookSlug;
  final String writerName;
  final int hadithsCount;
  final int chaptersCount;
  HadithBook({
    required this.bookName,
    required this.bookSlug,
    required this.writerName,
    required this.hadithsCount,
    required this.chaptersCount,
  });
  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      bookName: json['bookName'] ?? '',
      bookSlug: json['bookSlug'] ?? '',
      writerName: json['writerName'] ?? '',
      hadithsCount: json['hadiths_count'] ?? 0,
      chaptersCount: json['chapters_count'] ?? 0,
    );
  }
}

class HadithChapter {
  final int id;
  final String chapterNumber;
  final String chapterEnglish;
  final String chapterUrdu;
  final String chapterArabic;
  HadithChapter({
    required this.id,
    required this.chapterNumber,
    required this.chapterEnglish,
    required this.chapterUrdu,
    required this.chapterArabic,
  });
  factory HadithChapter.fromJson(Map<String, dynamic> json) {
    return HadithChapter(
      id: json['id'] ?? 0,
      chapterNumber: json['chapterNumber'] ?? '',
      chapterEnglish: json['chapterEnglish'] ?? '',
      chapterUrdu: json['chapterUrdu'] ?? '',
      chapterArabic: json['chapterArabic'] ?? '',
    );
  }
}

class HadithData {
  final int id;
  final String hadithNumber;
  final String hadithEnglish;
  final String hadithUrdu;
  final String hadithArabic;
  final String headingEnglish;
  final String headingUrdu;
  final String headingArabic;
  final String chapterNumber;
  final String bookSlug;
  final String volume;
  final String status;
  HadithData({
    required this.id,
    required this.hadithNumber,
    required this.hadithEnglish,
    required this.hadithUrdu,
    required this.hadithArabic,
    required this.headingEnglish,
    required this.headingUrdu,
    required this.headingArabic,
    required this.chapterNumber,
    required this.bookSlug,
    required this.volume,
    required this.status,
  });
  factory HadithData.fromJson(Map<String, dynamic> json) {
    return HadithData(
      id: json['id'] ?? 0,
      hadithNumber: json['hadithNumber'] ?? '',
      hadithEnglish: json['hadithEnglish'] ?? '',
      hadithUrdu: json['hadithUrdu'] ?? '',
      hadithArabic: json['hadithArabic'] ?? '',
      headingEnglish: json['headingEnglish'] ?? '',
      headingUrdu: json['headingUrdu'] ?? '',
      headingArabic: json['headingArabic'] ?? '',
      chapterNumber: json['chapterNumber'] ?? '',
      bookSlug: json['bookSlug'] ?? '',
      volume: json['volume'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class HadithApiService {
  static const String baseUrl = 'https://hadithapi.com/api';
  static const String apiKey =
      r'$2y$10$yMV4cRCudqwiKQD92XNP2uIqyQzq2cx9akjkIvz39vI9Ec5uvX8hK';
  static Future<List<HadithBook>> getBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books?apiKey=$apiKey'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final books = (data['books'] as List)
            .map((book) => HadithBook.fromJson(book))
            .toList();
        return books;
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  static Future<List<HadithChapter>> getChapters(String bookSlug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$bookSlug/chapters?apiKey=$apiKey'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chapters = (data['chapters'] as List)
            .map((chapter) => HadithChapter.fromJson(chapter))
            .toList();
        return chapters;
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

  static Future<List<HadithData>> getHadiths({
    String? bookSlug,
    String? chapterNumber,
    int paginate = 25,
    int page = 1,
  }) async {
    try {
      String url =
          '$baseUrl/hadiths?apiKey=$apiKey&paginate=$paginate&page=$page';
      if (bookSlug != null) url += '&book=$bookSlug';
      if (chapterNumber != null) url += '&chapter=$chapterNumber';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hadiths = (data['hadiths']['data'] as List)
            .map((hadith) => HadithData.fromJson(hadith))
            .toList();
        return hadiths;
      } else {
        throw Exception('Failed to load hadiths: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching hadiths: $e');
    }
  }

  static Future<HadithData?> searchHadithByNumber({
    required String bookSlug,
    required String hadithNumber,
    Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('Starting search...');
      for (int page = 1; page <= 30; page++) {
        onProgress?.call('Searching page $page...');
        final hadiths = await getHadiths(
          bookSlug: bookSlug,
          paginate: 100,
          page: page,
        );
        for (final hadith in hadiths) {
          if (hadith.hadithNumber == hadithNumber) {
            onProgress?.call('Hadith found!');
            return hadith;
          }
        }
        if (hadiths.length < 100) {
          onProgress?.call('Reached end of collection');
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      onProgress?.call('Search completed - hadith not found');
      return null;
    } catch (e) {
      onProgress?.call('Error occurred during search');
      throw Exception('Error searching for hadith: $e');
    }
  }
}

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});
  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
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

  void _showHadithBookmarksList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HadithBookmarksListPage(),
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
                          'Authentic collections of Prophet Muhammad\'s (?) sayings',
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
                    icon: Icons.library_books,
                    title: 'Browse Hadith Collections',
                    description:
                        'Explore 9 authentic hadith books with chapters',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HadithBooksPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildOptionCard(
                    context,
                    icon: Icons.bookmarks_rounded,
                    title: 'Bookmarked Hadiths',
                    description: 'View your saved hadiths with notes',
                    onTap: () => _showHadithBookmarksList(context),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildOptionCard(
                    context,
                    icon: Icons.search_rounded,
                    title: 'Search Any Hadith',
                    description: 'Search specific hadith by book and number',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HadithSearchPage(),
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

class HadithBooksPage extends StatefulWidget {
  const HadithBooksPage({super.key});
  @override
  State<HadithBooksPage> createState() => _HadithBooksPageState();
}

class _HadithBooksPageState extends State<HadithBooksPage> {
  List<HadithBook> books = [];
  bool isLoading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    loadBooks();
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

  void loadBooks() async {
    try {
      final loadedBooks = await HadithApiService.getBooks();
      setState(() {
        books = loadedBooks;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      loadDemoBooks();
    }
  }

  void loadDemoBooks() {
    final demoBooks = [
      HadithBook(
        bookName: 'Sahih Bukhari',
        bookSlug: 'sahih-bukhari',
        writerName: 'Imam Bukhari',
        hadithsCount: 7563,
        chaptersCount: 97,
      ),
      HadithBook(
        bookName: 'Sahih Muslim',
        bookSlug: 'sahih-muslim',
        writerName: 'Imam Muslim',
        hadithsCount: 7190,
        chaptersCount: 56,
      ),
      HadithBook(
        bookName: "Jami' Al-Tirmidhi",
        bookSlug: 'al-tirmidhi',
        writerName: 'Imam Tirmidhi',
        hadithsCount: 3956,
        chaptersCount: 46,
      ),
      HadithBook(
        bookName: 'Sunan Abu Dawood',
        bookSlug: 'abu-dawood',
        writerName: 'Imam Abu Dawood',
        hadithsCount: 5274,
        chaptersCount: 43,
      ),
      HadithBook(
        bookName: 'Sunan Ibn-e-Majah',
        bookSlug: 'ibn-e-majah',
        writerName: 'Ibn Majah',
        hadithsCount: 4341,
        chaptersCount: 37,
      ),
      HadithBook(
        bookName: "Sunan An-Nasa'i",
        bookSlug: 'sunan-nasai',
        writerName: 'Imam An-Nasa\'i',
        hadithsCount: 5758,
        chaptersCount: 51,
      ),
      HadithBook(
        bookName: 'Mishkat Al-Masabih',
        bookSlug: 'mishkat',
        writerName: 'Imam Baghawi',
        hadithsCount: 6285,
        chaptersCount: 29,
      ),
      HadithBook(
        bookName: 'Musnad Ahmad',
        bookSlug: 'musnad-ahmad',
        writerName: 'Imam Ahmad ibn Hanbal',
        hadithsCount: 26363,
        chaptersCount: 126,
      ),
      HadithBook(
        bookName: 'Al-Silsila Sahiha',
        bookSlug: 'al-silsila-sahiha',
        writerName: 'Sheikh Al-Albani',
        hadithsCount: 3367,
        chaptersCount: 45,
      ),
    ];
    setState(() {
      books = demoBooks;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hadith Books',
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RandomHadithPage()),
              );
            },
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random Hadith',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : null,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadBooks,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.04),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return Card(
                              elevation: 4,
                              shadowColor: Theme.of(context).colorScheme.shadow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.015,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HadithChaptersPage(
                                        book: book,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.04),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Theme.of(context).cardTheme.color,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06),
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
                                          Icons.menu_book,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                        ),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.bookName,
                                              style: GoogleFonts.inter(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'By: ${book.writerName}',
                                              style: GoogleFonts.inter(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${book.hadithsCount} Hadiths � ${book.chaptersCount} Chapters',
                                              style: GoogleFonts.inter(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
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

class HadithChaptersPage extends StatefulWidget {
  final HadithBook book;
  const HadithChaptersPage({super.key, required this.book});
  @override
  State<HadithChaptersPage> createState() => _HadithChaptersPageState();
}

class _HadithChaptersPageState extends State<HadithChaptersPage> {
  List<HadithChapter> chapters = [];
  bool isLoading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    loadChapters();
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

  void loadChapters() async {
    try {
      final loadedChapters =
          await HadithApiService.getChapters(widget.book.bookSlug);
      setState(() {
        chapters = loadedChapters;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      loadDemoChapters();
    }
  }

  void loadDemoChapters() {
    final demoChapters = List.generate(
      10,
      (index) => HadithChapter(
        id: index + 1,
        chapterNumber: '${index + 1}',
        chapterEnglish: 'Chapter ${index + 1}: Demo Chapter',
        chapterUrdu: '??? ${index + 1}: ???? ???',
        chapterArabic: '??? ${index + 1}: ??? ????????',
      ),
    );
    setState(() {
      chapters = demoChapters;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.bookName,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : null,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading chapters'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadChapters,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            final chapter = chapters[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).cardTheme.color,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                        chapter.chapterNumber,
                                        style: GoogleFonts.inter(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    chapter.chapterEnglish,
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    chapter.chapterArabic,
                                    style: TextStyle(
                                      fontFamily: 'UthmaniHafs',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.035,
                                    ),
                                    textDirection: TextDirection.rtl,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HadithListPage(
                                          book: widget.book,
                                          chapter: chapter,
                                        ),
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

class HadithListPage extends StatefulWidget {
  final HadithBook book;
  final HadithChapter? chapter;
  const HadithListPage({super.key, required this.book, this.chapter});
  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  List<HadithData> hadiths = [];
  bool isLoading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    HadithBookmarkService.addListener(_onBookmarksChanged);
    loadHadiths();
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    HadithBookmarkService.removeListener(_onBookmarksChanged);
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onBookmarksChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void loadHadiths() async {
    try {
      final loadedHadiths = await HadithApiService.getHadiths(
        bookSlug: widget.book.bookSlug,
        chapterNumber: widget.chapter?.chapterNumber,
      );
      setState(() {
        hadiths = loadedHadiths;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      loadDemoHadiths();
    }
  }

  void loadDemoHadiths() {
    setState(() {
      hadiths = [
        HadithData(
          id: 1,
          hadithNumber: '1',
          hadithEnglish:
              'Actions are but by intention and every man shall have but that which he intended.',
          hadithUrdu:
              '????? ?? ???????? ??? ?? ?? ??? ?? ??? ?? ??? ??? ?? ?? ?? ?? ?? ??? ?? ???',
          hadithArabic:
              '???????? ??????????? ?????????????? ?????????? ??????? ??????? ??? ?????',
          headingEnglish: 'The Book of Revelation',
          headingUrdu: '???? ?????',
          headingArabic: '???? ??? ?????',
          chapterNumber: widget.chapter?.chapterNumber ?? '1',
          bookSlug: widget.book.bookSlug,
          volume: '1',
          status: 'Sahih',
        ),
        HadithData(
          id: 2,
          hadithNumber: '2',
          hadithEnglish:
              'A Muslim is one from whose tongue and hands the Muslims are safe.',
          hadithUrdu:
              '?????? ?? ?? ?? ?? ???? ??? ???? ?? ????? ?????? ????? ?????',
          hadithArabic:
              '??????????? ???? ?????? ?????????????? ???? ????????? ????????',
          headingEnglish: 'The Book of Faith',
          headingUrdu: '???? ???????',
          headingArabic: '???? ???????',
          chapterNumber: widget.chapter?.chapterNumber ?? '1',
          bookSlug: widget.book.bookSlug,
          volume: '1',
          status: 'Sahih',
        ),
      ];
      error = null;
    });
  }

  Future<void> _toggleHadithBookmark(HadithData hadith) async {
    if (HadithBookmarkService.isBookmarked(
        hadith.bookSlug, hadith.hadithNumber)) {
      final success = await HadithBookmarkService.removeBookmark(
          hadith.bookSlug, hadith.hadithNumber);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Hadith ${hadith.hadithNumber} removed from bookmarks'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      final bookmark = HadithBookmark(
        bookSlug: hadith.bookSlug,
        bookName: widget.book.bookName,
        hadithNumber: hadith.hadithNumber,
        headingEnglish: hadith.headingEnglish,
        headingUrdu: hadith.headingUrdu,
        headingArabic: hadith.headingArabic,
        hadithEnglish: hadith.hadithEnglish,
        hadithUrdu: hadith.hadithUrdu,
        hadithArabic: hadith.hadithArabic,
        chapterNumber: hadith.chapterNumber,
        volume: hadith.volume,
        status: hadith.status,
        createdAt: DateTime.now(),
      );
      final success = await HadithBookmarkService.addBookmark(bookmark);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hadith ${hadith.hadithNumber} bookmarked'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View All',
              onPressed: () => _showHadithBookmarksList(context),
            ),
          ),
        );
      }
    }
  }

  void _showHadithBookmarksList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HadithBookmarksListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Text(
                widget.chapter?.chapterEnglish ?? 'All Hadiths',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.chapter != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.chapter!.chapterNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmarks_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => _showHadithBookmarksList(context),
            tooltip: 'View Hadith Bookmarks',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : null,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading hadiths'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadHadiths,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: hadiths.length,
                          itemBuilder: (context, index) {
                            final hadith = hadiths[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.format_quote,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Hadith ${hadith.hadithNumber}",
                                                  style: GoogleFonts.inter(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.035,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    _toggleHadithBookmark(
                                                        hadith),
                                                icon: Icon(
                                                  HadithBookmarkService
                                                          .isBookmarked(
                                                              hadith.bookSlug,
                                                              hadith
                                                                  .hadithNumber)
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: HadithBookmarkService
                                                          .isBookmarked(
                                                              hadith.bookSlug,
                                                              hadith
                                                                  .hadithNumber)
                                                      ? Colors.amber
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                ),
                                                tooltip: HadithBookmarkService
                                                        .isBookmarked(
                                                            hadith.bookSlug,
                                                            hadith.hadithNumber)
                                                    ? 'Remove Bookmark'
                                                    : 'Add Bookmark',
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: hadith.status ==
                                                          'Sahih'
                                                      ? Colors.green.shade100
                                                      : Colors.orange.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: hadith.status ==
                                                            'Sahih'
                                                        ? Colors.green.shade300
                                                        : Colors
                                                            .orange.shade300,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  hadith.status,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: hadith.status ==
                                                            'Sahih'
                                                        ? Colors.green.shade700
                                                        : Colors
                                                            .orange.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      if (hadith.hadithArabic.isNotEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            hadith.hadithArabic,
                                            style: TextStyle(
                                              fontFamily: 'UthmaniHafs',
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontSize:
                                                  FontSettings.arabicFontSize *
                                                      1.1,
                                              fontWeight: FontWeight.w500,
                                              height: 1.8,
                                            ),
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.translate,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "English Translation",
                                                  style: GoogleFonts.inter(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              hadith.hadithEnglish,
                                              style: GoogleFonts.inter(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: FontSettings
                                                    .englishFontSize,
                                                fontWeight: FontWeight.w400,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Vol. ${hadith.volume}',
                                            style: GoogleFonts.inter(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            widget.book.bookName,
                                            style: GoogleFonts.inter(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class RandomHadithPage extends StatefulWidget {
  const RandomHadithPage({super.key});
  @override
  State<RandomHadithPage> createState() => _RandomHadithPageState();
}

class _RandomHadithPageState extends State<RandomHadithPage> {
  HadithData? currentHadith;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    getRandomHadith();
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

  void getRandomHadith() async {
    setState(() {
      isLoading = true;
    });
    try {
      final hadiths = await HadithApiService.getHadiths(paginate: 50);
      if (hadiths.isNotEmpty) {
        final randomIndex =
            DateTime.now().millisecondsSinceEpoch % hadiths.length;
        setState(() {
          currentHadith = hadiths[randomIndex];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        currentHadith = HadithData(
          id: 1,
          hadithNumber: '1',
          hadithEnglish:
              'Actions are but by intention and every man shall have but that which he intended.',
          hadithUrdu:
              '????? ?? ???????? ??? ?? ?? ??? ?? ??? ?? ??? ??? ?? ?? ?? ?? ?? ??? ?? ???',
          hadithArabic:
              '???????? ??????????? ?????????????? ?????????? ??????? ??????? ??? ?????',
          headingEnglish: 'The Book of Revelation',
          headingUrdu: '???? ?????',
          headingArabic: '???? ??? ?????',
          chapterNumber: '1',
          bookSlug: 'sahih-bukhari',
          volume: '1',
          status: 'Sahih',
        );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Hadith'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: getRandomHadith,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentHadith == null
              ? const Center(child: Text('No hadith available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hadith ${currentHadith!.hadithNumber}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Chip(
                                label: Text(currentHadith!.status),
                                backgroundColor:
                                    currentHadith!.status == 'Sahih'
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (currentHadith!.hadithArabic.isNotEmpty) ...[
                            Text(
                              'Arabic:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentHadith!.hadithArabic,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'English:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentHadith!.hadithEnglish,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (currentHadith!.hadithUrdu.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Urdu:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentHadith!.hadithUrdu,
                              style: const TextStyle(fontSize: 16),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Source: ${currentHadith!.bookSlug.replaceAll('-', ' ').toUpperCase()} - Volume ${currentHadith!.volume}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getRandomHadith,
        icon: const Icon(Icons.shuffle),
        label: const Text('New Random'),
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
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    HadithBookmarkService.addListener(_onBookmarksChanged);
  }

  @override
  void dispose() {
    HadithBookmarkService.removeListener(_onBookmarksChanged);
    super.dispose();
  }

  void _onBookmarksChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = HadithBookmarkService.bookmarks;
    final filteredBookmarks = _searchQuery.isEmpty
        ? bookmarks
        : bookmarks.where((bookmark) {
            return bookmark.bookName.toLowerCase().contains(_searchQuery) ||
                bookmark.hadithNumber.contains(_searchQuery) ||
                bookmark.headingEnglish.toLowerCase().contains(_searchQuery) ||
                bookmark.hadithEnglish.toLowerCase().contains(_searchQuery) ||
                (bookmark.note?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hadith Bookmarks (${bookmarks.length})',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (bookmarks.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Bookmarks'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            if (bookmarks.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search bookmarks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
            Expanded(
              child: filteredBookmarks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBookmarks.length,
                      itemBuilder: (context, index) {
                        return _buildHadithBookmarkCard(
                            filteredBookmarks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No hadith bookmarks yet'
                : 'No bookmarks match your search',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Bookmark hadiths by tapping the bookmark icon while reading'
                : 'Try searching for different terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHadithBookmarkCard(HadithBookmark bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Opening ${bookmark.bookName} - Hadith ${bookmark.hadithNumber}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.bookName,
                          style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hadith ${bookmark.hadithNumber}',
                          style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 0.8,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'add_note':
                          _showNoteDialog(bookmark);
                          break;
                        case 'remove':
                          _removeBookmark(bookmark);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'add_note',
                        child: Row(
                          children: [
                            Icon(bookmark.note?.isNotEmpty == true
                                ? Icons.edit_note
                                : Icons.note_add),
                            const SizedBox(width: 8),
                            Text(bookmark.note?.isNotEmpty == true
                                ? 'Edit Note'
                                : 'Add Note'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Remove Bookmark'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (bookmark.headingEnglish.isNotEmpty) ...[
                Text(
                  bookmark.headingEnglish,
                  style: GoogleFonts.inter(
                    fontSize: FontSettings.englishFontSize * 0.85,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                bookmark.hadithEnglish.length > 150
                    ? '${bookmark.hadithEnglish.substring(0, 150)}...'
                    : bookmark.hadithEnglish,
                style: GoogleFonts.inter(
                  fontSize: FontSettings.englishFontSize * 0.8,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (bookmark.note?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookmark.note!,
                          style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 0.75,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bookmark.status == 'Sahih'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bookmark.status,
                      style: GoogleFonts.inter(
                        fontSize: FontSettings.englishFontSize * 0.7,
                        fontWeight: FontWeight.w600,
                        color: bookmark.status == 'Sahih'
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: FontSettings.englishFontSize * 0.7,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNoteDialog(HadithBookmark bookmark) {
    final TextEditingController controller =
        TextEditingController(text: bookmark.note ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add your personal note about this hadith...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final note = controller.text.trim();
              await HadithBookmarkService.updateBookmarkNote(
                bookmark.bookSlug,
                bookmark.hadithNumber,
                note.isEmpty ? null : note,
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeBookmark(HadithBookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bookmark'),
        content: Text(
            'Are you sure you want to remove this bookmark for Hadith ${bookmark.hadithNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HadithBookmarkService.removeBookmark(
                  bookmark.bookSlug, bookmark.hadithNumber);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text(
            'Are you sure you want to remove all hadith bookmarks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HadithBookmarkService.clearAllBookmarks();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
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
  HadithBook? selectedBook;
  String hadithNumber = '';
  HadithData? foundHadith;
  bool isLoading = false;
  String? error;
  String searchProgress = '';
  final TextEditingController hadithNumberController = TextEditingController();
  final List<HadithBook> books = [
    HadithBook(
      bookName: 'Sahih Bukhari',
      bookSlug: 'sahih-bukhari',
      writerName: 'Imam Bukhari',
      hadithsCount: 7563,
      chaptersCount: 97,
    ),
    HadithBook(
      bookName: 'Sahih Muslim',
      bookSlug: 'sahih-muslim',
      writerName: 'Imam Muslim',
      hadithsCount: 7190,
      chaptersCount: 56,
    ),
    HadithBook(
      bookName: "Jami' Al-Tirmidhi",
      bookSlug: 'al-tirmidhi',
      writerName: 'Imam Tirmidhi',
      hadithsCount: 3956,
      chaptersCount: 46,
    ),
    HadithBook(
      bookName: 'Sunan Abu Dawood',
      bookSlug: 'abu-dawood',
      writerName: 'Imam Abu Dawood',
      hadithsCount: 5274,
      chaptersCount: 43,
    ),
    HadithBook(
      bookName: 'Sunan Ibn-e-Majah',
      bookSlug: 'ibn-e-majah',
      writerName: 'Ibn Majah',
      hadithsCount: 4341,
      chaptersCount: 37,
    ),
    HadithBook(
      bookName: "Sunan An-Nasa'i",
      bookSlug: 'sunan-nasai',
      writerName: 'Imam An-Nasa\'i',
      hadithsCount: 5758,
      chaptersCount: 51,
    ),
    HadithBook(
      bookName: 'Mishkat Al-Masabih',
      bookSlug: 'mishkat',
      writerName: 'Imam Baghawi',
      hadithsCount: 6285,
      chaptersCount: 29,
    ),
    HadithBook(
      bookName: 'Musnad Ahmad',
      bookSlug: 'musnad-ahmad',
      writerName: 'Imam Ahmad ibn Hanbal',
      hadithsCount: 26363,
      chaptersCount: 126,
    ),
    HadithBook(
      bookName: 'Al-Silsila Sahiha',
      bookSlug: 'al-silsila-sahiha',
      writerName: 'Sheikh Al-Albani',
      hadithsCount: 3367,
      chaptersCount: 45,
    ),
  ];
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    hadithNumberController.dispose();
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> searchHadith() async {
    if (selectedBook == null || hadithNumber.trim().isEmpty) {
      setState(() {
        error = 'Please select a book and enter hadith number';
      });
      return;
    }
    setState(() {
      isLoading = true;
      error = null;
      foundHadith = null;
      searchProgress = 'Initializing search...';
    });
    try {
      final targetHadithNumber = hadithNumber.trim();
      final matchingHadith = await HadithApiService.searchHadithByNumber(
        bookSlug: selectedBook!.bookSlug,
        hadithNumber: targetHadithNumber,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              searchProgress = progress;
            });
          }
        },
      );
      if (matchingHadith != null) {
        setState(() {
          foundHadith = matchingHadith;
          isLoading = false;
          searchProgress = '';
        });
      } else {
        setState(() {
          error =
              'Hadith #$targetHadithNumber not found in ${selectedBook!.bookName}.\n\n'
              'Possible reasons:\n'
              '� The hadith number doesn\'t exist in this collection\n'
              '� The numbering system might be different\n'
              '� Try a different hadith number or book\n\n'
              'Note: We searched through multiple pages (up to 3000 hadiths) but couldn\'t find this specific number.';
          isLoading = false;
          searchProgress = '';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error searching for hadith: ${e.toString()}';
        isLoading = false;
        searchProgress = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Hadith',
          style: GoogleFonts.inter(
            fontSize: FontSettings.englishFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to Search',
                            style: GoogleFonts.inter(
                              fontSize: FontSettings.englishFontSize * 1.1,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Select a hadith book from the dropdown\n'
                        '2. Enter the hadith number you want to find\n'
                        '3. Tap "Search" to find the hadith',
                        style: GoogleFonts.inter(
                          fontSize: FontSettings.englishFontSize * 0.9,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Hadith Book',
                        style: GoogleFonts.inter(
                          fontSize: FontSettings.englishFontSize * 1.1,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonFormField<HadithBook>(
                          value: selectedBook,
                          isExpanded: true,
                          menuMaxHeight: 300,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            hintText: 'Choose a hadith collection...',
                          ),
                          items: books.map((book) {
                            return DropdownMenuItem<HadithBook>(
                              value: book,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      book.bookName,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'By ${book.writerName} � ${book.hadithsCount} Hadiths',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (book) {
                            setState(() {
                              selectedBook = book;
                              foundHadith = null;
                              error = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Hadith Number',
                        style: GoogleFonts.inter(
                          fontSize: FontSettings.englishFontSize * 1.1,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: hadithNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g., 1, 25, 100...',
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            hadithNumber = value;
                            foundHadith = null;
                            error = null;
                          });
                        },
                        onSubmitted: (_) {
                          if (selectedBook != null &&
                              hadithNumber.trim().isNotEmpty) {
                            searchHadith();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (selectedBook != null &&
                        hadithNumber.trim().isNotEmpty &&
                        !isLoading)
                    ? searchHadith
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Searching...',
                                style: GoogleFonts.inter(
                                  fontSize: FontSettings.englishFontSize,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (searchProgress.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              searchProgress,
                              style: GoogleFonts.inter(
                                fontSize: FontSettings.englishFontSize * 0.85,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search Hadith',
                            style: GoogleFonts.inter(
                              fontSize: FontSettings.englishFontSize,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              if (error != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            error!,
                            style: GoogleFonts.inter(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (foundHadith != null)
                Card(
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
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.format_quote,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Hadith ${foundHadith!.hadithNumber}",
                                      style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: foundHadith!.status == 'Sahih'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: foundHadith!.status == 'Sahih'
                                        ? Colors.green.shade300
                                        : Colors.orange.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  foundHadith!.status,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: foundHadith!.status == 'Sahih'
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (foundHadith!.hadithArabic.isNotEmpty) ...[
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
                                foundHadith!.hadithArabic,
                                style: GoogleFonts.amiriQuran(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSettings.arabicFontSize * 1.1,
                                  fontWeight: FontWeight.w500,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.translate,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "English Translation",
                                      style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  foundHadith!.hadithEnglish,
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: FontSettings.englishFontSize,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedBook!.bookName,
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Vol. ${foundHadith!.volume}',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
