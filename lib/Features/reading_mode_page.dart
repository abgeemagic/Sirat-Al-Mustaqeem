import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:molvi/Features/reading_progress_service.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await ReadingProgressService.getProgress();
    if (mounted) {
      setState(() {
        // update state
      });
    }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final arabic =
        quran.getVerse(_currentSurah, _currentAyah, verseEndSymbol: true);
    final translation = quran.getVerseTranslation(_currentSurah, _currentAyah);
    final surahName = quran.getSurahName(_currentSurah);
    // Calculate total verses read so far by summing all ayahs in previous surahs and adding current ayah
    int versesRead = 0;
    for (int i = 1; i < _currentSurah; i++) {
      versesRead += quran.getVerseCount(i);
    }
    versesRead += _currentAyah;
    final progressPercent = versesRead / 6236;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$surahName ($_currentSurah) : $_currentAyah',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart from beginning',
            onPressed: () async {
              setState(() {
                _currentSurah = 1;
                _currentAyah = 1;
                _totalAyat = quran.getVerseCount(1);
              });
              await _saveProgress();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            _nextVerse();
          } else if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0) {
            _prevVerse();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.08),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          arabic,
                          style: TextStyle(
                              fontFamily: 'UthmaniHafs',
                              fontSize: 36,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          translation,
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progress: $versesRead / 6236 verses',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Swipe left/right to navigate',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
