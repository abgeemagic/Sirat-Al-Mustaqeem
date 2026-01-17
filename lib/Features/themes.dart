import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

ThemeData lighttheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1B5E20), // Keep deep green for buttons/active states
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE8F5E8), // Very light green for backgrounds
    onPrimaryContainer:
        Color(0xFF003300), // Darker text on containers for contrast
    secondary: Color(0xFF2E7D32),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF1F8E9),
    onSecondaryContainer: Color(0xFF1B5E20),
    tertiary: Color(0xFF4CAF50),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFC8E6C9),
    onTertiaryContainer: Color(0xFF003300),
    error: Color(0xFFB00020),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFAFAFA), // Clean off-white background
    onSurface: Color(0xFF1A1A1A), // Standard Black text
    surfaceContainerHighest: Color(0xFFF0F0F0), // For inputs/cards
    onSurfaceVariant: Color(0xFF44474E), // Softer grey for subtitles
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C7C5),
    shadow: Colors.black12,
    scrim: Colors.black54,
    inverseSurface: Color(0xFF303030),
    onInverseSurface: Color(0xFFF2F2F2),
    inversePrimary: Color(0xFF81C784),
    surfaceTint: Color(0xFF1B5E20),
  ),
  textTheme: TextTheme(
    // FIXED: Headlines are now Dark Grey (Standard Material 3)
    // This removes the "heavy" feeling of colored text
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: const Color(0xFF1A1A1A),
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF1A1A1A),
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF1A1A1A),
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF1A1A1A),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: const Color(0xFF1A1A1A),
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFF1A1A1A),
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: const Color(0xFF1A1A1A),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFF424242),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFF616161),
    ),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 2,
    // Modern approach: Use Surface color for AppBar with Colored Text
    // This feels lighter and cleaner than a solid block of green
    backgroundColor: const Color(0xFFFAFAFA),
    foregroundColor: const Color(0xFF1B5E20), // Green Icons/Text
    surfaceTintColor: const Color(0xFFFAFAFA),
    centerTitle: true,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700, // Slightly bolder to stand out
      color: const Color(0xFF1B5E20), // Primary Green Title
      letterSpacing: 0,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF1B5E20),
      size: 24,
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 0, // Flat modern look
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: Color(0xFFE0E0E0), width: 1), // Subtle border
    ),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0, // Flat button
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.white,
    elevation: 3,
    shadowColor: Colors.black12,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF424242),
    size: 24,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
  ),
);

ThemeData darktheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF66BB6A),
    onPrimary: Color(0xFF1B5E20),
    primaryContainer: Color(0xFF2E7D32),
    onPrimaryContainer: Color(0xFFE8F5E8),
    secondary: Color(0xFF4CAF50),
    onSecondary: Color(0xFF1B5E20),
    secondaryContainer: Color(0xFF388E3C),
    onSecondaryContainer: Color(0xFFF1F8E9),
    tertiary: Color(0xFF81C784),
    onTertiary: Color(0xFF1B5E20),
    tertiaryContainer: Color(0xFF2E7D32),
    onTertiaryContainer: Color(0xFFE8F5E8),
    error: Color(0xFFE57373),
    onError: Color(0xFF1A1A1A),
    errorContainer: Color(0xFFD32F2F),
    onErrorContainer: Color(0xFFFFEBEE),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceContainerHighest: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFBDBDBD),
    outline: Color(0xFF616161),
    outlineVariant: Color(0xFF424242),
    shadow: Colors.black87,
    scrim: Colors.black87,
    inverseSurface: Color(0xFFE0E0E0),
    onInverseSurface: Color(0xFF121212),
    inversePrimary: Color(0xFF1B5E20),
    surfaceTint: Color(0xFF66BB6A),
  ),
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: const Color(0xFF66BB6A),
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF66BB6A),
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF66BB6A),
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFE0E0E0),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: const Color(0xFFE0E0E0),
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFFE0E0E0),
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: const Color(0xFFE0E0E0),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFFBDBDBD),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFF9E9E9E),
    ),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 2,
    backgroundColor: const Color(0xFF1B5E20),
    foregroundColor: Colors.white,
    surfaceTintColor: const Color(0xFF1B5E20),
    centerTitle: true,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 4,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    color: Color(0xFF1E1E1E),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      backgroundColor: const Color(0xFF66BB6A),
      foregroundColor: const Color(0xFF1B5E20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Color(0xFF121212),
    elevation: 8,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFBDBDBD),
    size: 24,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF121212),
    surfaceTintColor: Color(0xFF121212),
  ),
);
