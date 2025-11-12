import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:molvi/Firebase/user_preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double arabicFontSize = 18.0;
  double englishFontSize = 16.0;
  bool isLoading = true;
  ThemeMode currentThemeMode = ThemeMode.system;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadFontSettings();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadFontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      arabicFontSize = prefs.getDouble('arabic_font_size') ?? 18.0;
      englishFontSize = prefs.getDouble('english_font_size') ?? 16.0;
      String themeModeString = prefs.getString('theme_mode') ?? 'system';
      switch (themeModeString) {
        case 'light':
          currentThemeMode = ThemeMode.light;
          break;
        case 'dark':
          currentThemeMode = ThemeMode.dark;
          break;
        default:
          currentThemeMode = ThemeMode.system;
      }
      isLoading = false;
    });
  }

  Future<void> _saveArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabic_font_size', size);
    setState(() {
      arabicFontSize = size;
    });
    FontSettings.updateArabicFontSize(size);
  }

  Future<void> _saveEnglishFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('english_font_size', size);
    setState(() {
      englishFontSize = size;
    });
    FontSettings.updateEnglishFontSize(size);
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    setState(() {
      currentThemeMode = themeMode;
    });
    await ThemeSettings.updateThemeMode(themeMode);
  }

  void _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('arabic_font_size');
    await prefs.remove('english_font_size');
    await prefs.remove('theme_mode');
    setState(() {
      arabicFontSize = 18.0;
      englishFontSize = 16.0;
      currentThemeMode = ThemeMode.system;
    });
    FontSettings.updateArabicFontSize(18.0);
    FontSettings.updateEnglishFontSize(16.0);
    ThemeSettings.updateThemeMode(ThemeMode.system);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: englishFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
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
                                Icons.settings,
                                size: MediaQuery.of(context).size.width * 0.12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.015,
                              ),
                              Text(
                                'Customize your reading experience',
                                style: GoogleFonts.inter(
                                  fontSize: englishFontSize * 1.3,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        _buildFontSizeCard(
                          context,
                          title: 'Arabic Text Size',
                          currentSize: arabicFontSize,
                          onChanged: _saveArabicFontSize,
                          isArabicFont: true,
                          minSize: 12.0,
                          maxSize: 32.0,
                          sampleText: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        _buildFontSizeCard(
                          context,
                          title: 'English Text Size',
                          currentSize: englishFontSize,
                          onChanged: _saveEnglishFontSize,
                          isArabicFont: false,
                          minSize: 10.0,
                          maxSize: 28.0,
                          sampleText:
                              'In the name of Allah, the Most Gracious, the Most Merciful',
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        _buildThemeCard(context),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'App Version: $_appVersion',
                              style: GoogleFonts.inter(
                                fontSize: englishFontSize * 0.85,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.04,
                          ),
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
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Font size changes will apply throughout the entire app and will be saved for your next session.',
                                  style: GoogleFonts.inter(
                                    fontSize: englishFontSize * 0.85,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
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
      ),
    );
  }

  Widget _buildFontSizeCard(
    BuildContext context, {
    required String title,
    required double currentSize,
    required Function(double) onChanged,
    required bool isArabicFont,
    required double minSize,
    required double maxSize,
    required String sampleText,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
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
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: englishFontSize * 1.1,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currentSize.toInt()}px',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                sampleText,
                style: isArabicFont
                    ? TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: currentSize,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.6,
                      )
                    : GoogleFonts.inter(
                        fontSize: currentSize,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                textAlign: isArabicFont ? TextAlign.right : TextAlign.left,
                textDirection:
                    isArabicFont ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.text_decrease,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: currentSize,
                    min: minSize,
                    max: maxSize,
                    divisions: ((maxSize - minSize) / 2).round(),
                    onChanged: onChanged,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.3),
                  ),
                ),
                Icon(
                  Icons.text_increase,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${minSize.toInt()}px',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${maxSize.toInt()}px',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Mode',
                      style: GoogleFonts.inter(
                        fontSize: englishFontSize * 1.1,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildThemeOption(
                context,
                icon: Icons.brightness_auto,
                title: 'System Default',
                subtitle: 'Follow device theme',
                themeMode: ThemeMode.system,
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context,
                icon: Icons.light_mode,
                title: 'Light Mode',
                subtitle: 'Always use light theme',
                themeMode: ThemeMode.light,
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context,
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Always use dark theme',
                themeMode: ThemeMode.dark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Available Themes: Light, Dark, System',
                style: GoogleFonts.inter(
                  fontSize: englishFontSize * 0.85,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode themeMode,
  }) {
    bool isSelected = currentThemeMode == themeMode;
    return GestureDetector(
      onTap: () => _saveThemeMode(themeMode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: englishFontSize * 1.0,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: englishFontSize * 0.85,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class FontSettings {
  static double _arabicFontSize = 18.0;
  static double _englishFontSize = 16.0;
  static final List<VoidCallback> _listeners = [];
  static double get arabicFontSize => _arabicFontSize;
  static double get englishFontSize => _englishFontSize;
  static double get fontSize => _englishFontSize;
  static Future<void> updateArabicFontSize(double size) async {
    _arabicFontSize = size;
    await _saveToLocal('arabic_font_size', size);
    await UserPreferencesService.savePreferences(arabicFontSize: size);
    _notifyListeners();
  }

  static Future<void> updateEnglishFontSize(double size) async {
    _englishFontSize = size;
    await _saveToLocal('english_font_size', size);
    await UserPreferencesService.savePreferences(fontSize: size);
    _notifyListeners();
  }

  static Future<void> setFontSize(double size) async {
    _englishFontSize = size;
    await _saveToLocal('english_font_size', size);
    _notifyListeners();
  }

  static Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    await _saveToLocal('arabic_font_size', size);
    _notifyListeners();
  }

  static Future<void> _saveToLocal(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble('arabic_font_size') ?? 18.0;
    _englishFontSize = prefs.getDouble('english_font_size') ?? 16.0;
    _notifyListeners();
  }
}

class ThemeSettings {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.system);

  static ThemeMode get themeMode => themeModeNotifier.value;

  static Future<void> updateThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await _saveToLocal(mode);
    await UserPreferencesService.savePreferences(themeMode: mode.name);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await _saveToLocal(mode);
  }

  static Future<void> _saveToLocal(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    await prefs.setString('theme_mode', themeModeString);
  }

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString = prefs.getString('theme_mode') ?? 'system';
    switch (themeModeString) {
      case 'light':
        themeModeNotifier.value = ThemeMode.light;
        break;
      case 'dark':
        themeModeNotifier.value = ThemeMode.dark;
        break;
      default:
        themeModeNotifier.value = ThemeMode.system;
    }
  }
}

class Settingspage extends StatelessWidget {
  const Settingspage({super.key});
  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }
}