import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:molvi/Pages/aipage.dart';
import 'package:molvi/Pages/hadithpage.dart';
import 'package:molvi/Pages/qibla_compass_page.dart';
import 'package:molvi/Pages/quranpage.dart';
import 'package:molvi/Features/randomversepage.dart';
import 'package:molvi/Pages/salahpage.dart';
import 'package:molvi/Pages/settings.dart';
import 'package:molvi/Features/themes.dart' as theme;
import 'package:molvi/Features/reading_mode_page.dart';
import 'package:molvi/Firebase/auth_service.dart';
import 'package:molvi/Widgets/prayer_tracker_card.dart';
import 'Firebase/firebase_options.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:molvi/Features/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeSettings.themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Sirat Al Mustaqeem',
          theme: theme.lighttheme,
          darkTheme: theme.darktheme,
          themeMode: currentMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainNavigator();
        }
        return const LoginPage();
      },
    );
  }
}

// ---------------------------------------------------------
// IMPROVED LOGIN PAGE
// ---------------------------------------------------------
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleAuthAction(BuildContext context) async {
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        AuthService.showErrorDialog(
            context, 'Failed to sign in: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with a subtle glow effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sync your settings, bookmarks, and preferences across all devices.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 48),
                // Custom Styled Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _handleAuthAction(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.login_rounded),
                        SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  final PageController _pageController = PageController(initialPage: 2);
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const HadithPage(),
    const Quranpage(),
    const Home(),
    const Aipage(),
    const ReadingModePage(),
  ];

  final List<IconData> _pageIcons = [
    Icons.book_rounded,
    Icons.menu_book_rounded,
    Icons.home_rounded,
    Icons.psychology_rounded,
    Icons.auto_stories_outlined,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        // Only show AppBar for pages OTHER than Home (Index 2)
        // // Home has its own custom header now.
        // appBar: _currentIndex == 2
        //     ? null
        //     : AppBar(
        //         title: Text(_pageTitles[_currentIndex]),
        //         centerTitle: true,
        //         elevation: 0,
        //       ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics:
              const NeverScrollableScrollPhysics(), // Prevent swiping to avoid UI glitches
          children: _pages,
        ),
        bottomNavigationBar: ConvexAppBar(
          key: ValueKey(_currentIndex),
          style: TabStyle.react,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          activeColor: Theme.of(context).colorScheme.primary,
          color: isDark ? Colors.grey : Colors.grey.shade600,
          elevation: 2,
          items: List.generate(
            _pages.length,
            (index) => TabItem(
              icon: _pageIcons[index],
              title: _getShortLabel(index),
            ),
          ),
          initialActiveIndex: _currentIndex,
          onTap: _navigateToPage,
        ));
  }

  String _getShortLabel(int index) {
    switch (index) {
      case 0:
        return 'Hadith';
      case 1:
        return 'Quran';
      case 2:
        return 'Home';
      case 3:
        return 'AI Guide';
      case 4:
        return 'Reading';
      default:
        return '';
    }
  }
}

// ---------------------------------------------------------
// RE-DESIGNED HOME SCREEN
// ---------------------------------------------------------
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) FontSettings.addListener(_onFontSettingsChanged);
    });
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (User Info + Settings)
              _buildHeader(context),

              const SizedBox(height: 24),

              // 2. Main Banner (Logo + Slogan)
              _buildMainBanner(context),
              const SizedBox(height: 24),

              const PrayerTrackerCard(),
              const SizedBox(height: 24),

              // 3. Quick Actions Grid
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Using a Row + Column approach for better alignment than flexible
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.refresh_rounded,
                      title: 'Random Verse',
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RandomVersePage())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.auto_stories_rounded,
                      title: 'Random Hadith',
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RandomHadithPage())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Full width card
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.schedule_rounded,
                      title: 'Prayer Timings',
                      color: Colors.greenAccent,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SalahPage())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.explore_rounded, // Compass Icon
                      title: 'Qibla Finder',
                      color: Colors.purpleAccent, // Fun distinct color
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QiblaCompassPage())),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'As-salamu alaykum,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                AuthService.userDisplayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // AVATAR WITH SETTINGS BADGE
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // 1. The Avatar Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: AuthService.userPhotoURL != null
                      ? NetworkImage(AuthService.userPhotoURL!)
                      : null,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: AuthService.userPhotoURL == null
                      ? Icon(Icons.person,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
              ),
              // 2. The Settings Icon Badge
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMainBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icon/logo.png',
            width: 70,
            height: 70,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sirat Al Mustaqeem',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your daily companion for Islamic guidance & wisdom.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isHorizontal = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme
                .surfaceContainer, // Better than standard Card color
            borderRadius: BorderRadius.circular(24),
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
          child: isHorizontal
              ? Row(
                  children: [
                    _buildIconBox(icon, color, isDark),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconBox(icon, color, isDark),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isDark ? color.withOpacity(0.9) : color,
        size: 24,
      ),
    );
  }
}
