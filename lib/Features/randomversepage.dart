import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Features/functions.dart';
import 'package:molvi/Pages/settings.dart';

class RandomVersePage extends StatefulWidget {
  const RandomVersePage({super.key});
  @override
  State<RandomVersePage> createState() => _RandomVersePageState();
}

class _RandomVersePageState extends State<RandomVersePage> {
  Ayah? currentVerse;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    loadRandomVerse();
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) setState(() {});
  }

  void loadRandomVerse() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final verse = await getRandomVerse();
      if (mounted) {
        setState(() {
          currentVerse = verse;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading verse: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Random Verse',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: loadRandomVerse,
              icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : currentVerse == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 60, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text('No verse available',
                          style:
                              GoogleFonts.inter(color: colorScheme.onSurface)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: loadRandomVerse,
                          child: const Text('Try Again')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // --- VERSE CARD ---
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                            // Header: Surah Name
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${currentVerse!.surahName} • Ayah ${currentVerse!.ayahNumber}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              currentVerse!.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'UthmaniHafs',
                                fontSize: FontSettings.arabicFontSize * 1.8,
                                height: 1.6,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 30),
                            Divider(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            const SizedBox(height: 30),

                            // TRANSLATION
                            Text(
                              currentVerse!.translation ??
                                  "Translation loading...",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: FontSettings.englishFontSize * 1.2,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface.withOpacity(0.9),
                                fontStyle: currentVerse!.translation == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loadRandomVerse,
        icon: const Icon(Icons.shuffle_rounded),
        label: const Text('New Verse'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
