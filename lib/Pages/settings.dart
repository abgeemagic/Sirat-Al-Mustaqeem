import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:molvi/Firebase/user_preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:molvi/Firebase/auth_service.dart';
import 'package:molvi/Features/notification_service.dart';

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
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadFontSettings();
    _loadAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // ... existing font loading ...
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      // Request permission if turning ON
      bool granted = await NotificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification permission denied')));
        }
        return;
      }
    } else {
      // Cancel all if turning OFF
      await NotificationService.cancelAllNotifications();
    }

    setState(() {
      notificationsEnabled = value;
    });
    await prefs.setBool('notifications_enabled', value);
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
    setState(() => arabicFontSize = size);
    FontSettings.updateArabicFontSize(size);
  }

  Future<void> _saveEnglishFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('english_font_size', size);
    setState(() => englishFontSize = size);
    FontSettings.updateEnglishFontSize(size);
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    setState(() => currentThemeMode = themeMode);
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings reset to defaults')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER INFO ---
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
                        Icon(Icons.tune_rounded,
                            color: colorScheme.primary, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personalization',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Customize your reading experience',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- SECTION: TYPOGRAPHY ---
                  _buildSectionHeader(context, 'Typography'),
                  _buildFontSizeCard(
                    context,
                    title: 'Arabic Text Size',
                    currentSize: arabicFontSize,
                    onChanged: _saveArabicFontSize,
                    isArabicFont: true,
                    minSize: 12.0,
                    maxSize: 40.0,
                    sampleText: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),
                  _buildFontSizeCard(
                    context,
                    title: 'English Text Size',
                    currentSize: englishFontSize,
                    onChanged: _saveEnglishFontSize,
                    isArabicFont: false,
                    minSize: 10.0,
                    maxSize: 28.0,
                    sampleText: 'In the name of Allah, the Most Gracious',
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION: APPEARANCE ---
                  _buildSectionHeader(context, 'Appearance'),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildThemeOption(
                          context,
                          icon: Icons.brightness_auto_rounded,
                          title: 'System Default',
                          themeMode: ThemeMode.system,
                          isFirst: true,
                        ),
                        Divider(
                            height: 1,
                            color: colorScheme.outlineVariant.withOpacity(0.5)),
                        _buildThemeOption(
                          context,
                          icon: Icons.light_mode_rounded,
                          title: 'Light Mode',
                          themeMode: ThemeMode.light,
                        ),
                        Divider(
                            height: 1,
                            color: colorScheme.outlineVariant.withOpacity(0.5)),
                        _buildThemeOption(
                          context,
                          icon: Icons.dark_mode_rounded,
                          title: 'Dark Mode',
                          themeMode: ThemeMode.dark,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: 'Prayer Notifications',
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: _toggleNotifications,
                    ),
                  ),

                  // --- SECTION: ACCOUNT ---
                  _buildSectionHeader(context, 'Account'),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.person_outline,
                            color: colorScheme.primary),
                      ),
                      title: Text(
                        AuthService.userDisplayName ?? 'User',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        AuthService.userEmail ?? 'No email linked',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await AuthService.signOut();
                          if (context.mounted) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        'Log Out',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      'Version $_appVersion',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: trailing,
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
    required ColorScheme colorScheme,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentSize.toInt()}px',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Preview Box
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Text(
              sampleText,
              style: isArabicFont
                  ? TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: currentSize,
                      color: colorScheme.onSurface,
                      height: 1.5,
                    )
                  : GoogleFonts.inter(
                      fontSize: currentSize,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Slider
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.text_decrease_rounded),
                  onPressed: () =>
                      onChanged((currentSize - 2).clamp(minSize, maxSize)),
                  color: colorScheme.onSurfaceVariant,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: currentSize,
                      min: minSize,
                      max: maxSize,
                      divisions: ((maxSize - minSize) / 2).round(),
                      onChanged: onChanged,
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase_rounded),
                  onPressed: () =>
                      onChanged((currentSize + 2).clamp(minSize, maxSize)),
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required ThemeMode themeMode,
    bool isFirst = false,
    bool isLast = false,
  }) {
    bool isSelected = currentThemeMode == themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _saveThemeMode(themeMode),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, color: colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// EXISTING HELPERS (KEPT EXACTLY THE SAME FOR COMPATIBILITY)
// -------------------------------------------------------------

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
