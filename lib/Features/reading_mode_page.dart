import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:molvi/Features/reading_progress_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Pages/settings.dart'; // Added to use FontSettings

class ReadingModePage extends StatefulWidget {
  const ReadingModePage({super.key});
  @override
  State<ReadingModePage> createState() => _ReadingModePageState();
}

class _ReadingModePageState extends State<ReadingModePage> {
  int _currentSurah = 1;
  int _currentAyah = 1;
  int _totalAyat = 1;
  bool _loading = true;

  Future<void> _showRestartConfirmation(BuildContext parentContext) async {
    final colorScheme = Theme.of(parentContext).colorScheme;

    return showDialog<void>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        // 1. Rename this to dialogContext
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Start Over?',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will reset your reading progress back to the beginning (Al-Fatiha).',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext to close
              },
            ),
            TextButton(
              child: Text(
                'Restart',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Use dialogContext to close

                // Logic
                setState(() {
                  _currentSurah = 1;
                  _currentAyah = 1;
                  _totalAyat = quran.getVerseCount(1);
                });
                await _saveProgress();

                // Check if the PARENT page is still mounted
                if (mounted) {
                  // Use parentContext (which is still alive) for the SnackBar
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Progress reset to start',
                        style: GoogleFonts.inter(color: colorScheme.onPrimary),
                      ),
                      backgroundColor: colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to font changes to redraw if user changes settings
    FontSettings.addListener(_onFontSettingsChanged);
    _loadProgress();
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProgress() async {
    final progress = await ReadingProgressService.getProgress();
    if (mounted) {
      setState(() {
        _currentSurah = progress['surah'] ?? 1;
        _currentAyah = progress['ayah'] ?? 1;
        _totalAyat = quran.getVerseCount(_currentSurah);
        _loading = false;
      });
    }
  }

  Future<void> _saveProgress() async {
    await ReadingProgressService.saveProgress(_currentSurah, _currentAyah);
  }

  void _nextVerse() {
    setState(() {
      if (_currentAyah < _totalAyat) {
        _currentAyah++;
      } else if (_currentSurah < 114) {
        _currentSurah++;
        _currentAyah = 1;
        _totalAyat = quran.getVerseCount(_currentSurah);
      }
      _saveProgress();
    });
  }

  void _prevVerse() {
    setState(() {
      if (_currentAyah > 1) {
        _currentAyah--;
      } else if (_currentSurah > 1) {
        _currentSurah--;
        _totalAyat = quran.getVerseCount(_currentSurah);
        _currentAyah = _totalAyat;
      }
      _saveProgress();
    });
  }

  // Helper to convert English numbers to Arabic
  String toArabicNumbers(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    final arabicText =
        quran.getVerse(_currentSurah, _currentAyah, verseEndSymbol: false);
    final translation = quran.getVerseTranslation(_currentSurah, _currentAyah);
    final surahName = quran.getSurahName(_currentSurah);
    final surahNameArabic = quran.getSurahNameArabic(_currentSurah);

    // Calculate Progress
    int versesRead = 0;
    for (int i = 1; i < _currentSurah; i++) {
      versesRead += quran.getVerseCount(i);
    }
    versesRead += _currentAyah;
    final progressPercent = versesRead / 6236;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Transparent AppBar for immersive feel
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              '$surahName ($surahNameArabic)',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Juz ${quran.getJuzNumber(_currentSurah, _currentAyah)} • Ayah $_currentAyah',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: colorScheme.onSurfaceVariant),
            tooltip: 'Restart from Al-Fatiha',
            onPressed: () => _showRestartConfirmation(context),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe Left/Right to navigate
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _nextVerse(); // Swipe Left -> Next
            } else if (details.primaryVelocity! > 0) {
              _prevVerse(); // Swipe Right -> Prev
            }
          }
        },
        child: Column(
          children: [
            // --- MAIN READING CARD ---
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer, // Modern card color
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. ARABIC TEXT
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily:
                                    'UthmaniHafs', // Matches other pages
                                fontSize: FontSettings.arabicFontSize *
                                    2.0, // Large for reading mode
                                height: 1.6,
                                color: colorScheme.onSurface,
                              ),
                              children: [
                                TextSpan(text: arabicText),
                                // End of Verse Symbol
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, left: 4.0),
                                    child: SizedBox(
                                      width: FontSettings.arabicFontSize *
                                          2.2, // Scale with font
                                      height: FontSettings.arabicFontSize * 2.2,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Circle Icon
                                          Icon(
                                            Icons
                                                .circle_outlined, // Simplified circle or custom glyph
                                            size: FontSettings.arabicFontSize *
                                                2.2,
                                            color: colorScheme.primary
                                                .withOpacity(0.4),
                                          ),
                                          // Verse Number
                                          Text(
                                            toArabicNumbers(_currentAyah),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'UthmaniHafs',
                                              fontSize:
                                                  FontSettings.arabicFontSize *
                                                      0.9,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                              height: 1.0,
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

                        const SizedBox(height: 30),
                        Divider(
                            color: colorScheme.outlineVariant.withOpacity(0.5)),
                        const SizedBox(height: 30),

                        // 2. TRANSLATION
                        Text(
                          translation,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 1.2,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- BOTTOM CONTROLS ---
            Container(
              padding: const EdgeInsets.all(24),
              color: colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${(progressPercent * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 12,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Swipe left or right to navigate',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
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
