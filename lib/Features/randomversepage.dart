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
    if (mounted) {
      setState(() {});
    }
  }

  void loadRandomVerse() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
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
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading verse: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Verse'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: loadRandomVerse,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentVerse == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('No verse available'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadRandomVerse,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${currentVerse!.surahName} - ${currentVerse!.surahNumber}',
                                  style: TextStyle(
                                    fontFamily: 'UthmaniHafs',
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: FontSettings.arabicFontSize * 1.1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${currentVerse!.ayahNumber}',
                                    style: TextStyle(
                                      fontFamily: 'UthmaniHafs',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              currentVerse!.text,
                              style: TextStyle(
                                fontFamily: 'UthmaniHafs',
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: FontSettings.arabicFontSize * 1.6,
                                fontWeight: FontWeight.w500,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (currentVerse!.translation != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.3),
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
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Translation",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentVerse!.translation!,
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize:
                                          FontSettings.englishFontSize * 1.1,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          if (currentVerse!.translation == null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Translation loading...",
                                style: GoogleFonts.inter(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loadRandomVerse,
        icon: const Icon(Icons.refresh),
        label: const Text('New Random'),
      ),
    );
  }
}
