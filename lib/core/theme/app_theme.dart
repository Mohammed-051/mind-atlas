import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MindMentor's premium, calming design system.
///
/// Inspired by Calm, Headspace, and Wysa — pastel palette,
/// generous whitespace, soft shadows, rounded squircle shapes.
class AppColors {
  AppColors._();

  // ── Primary Palette ──────────────────────────────────────
  static const Color primary = Color(0xFF6B9BD2);
  static const Color primaryLight = Color(0xFF9DC4E8);
  static const Color primaryDark = Color(0xFF4A7FB5);

  // ── Accent / Secondary ──────────────────────────────────
  static const Color secondary = Color(0xFF8BC6A5);
  static const Color secondaryLight = Color(0xFFB5DEC8);
  static const Color accent = Color(0xFFF4C27F);

  // ── Backgrounds (Light) ─────────────────────────────────
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F0EB);
  static const Color warmCream = Color(0xFFFFF5E6);

  // ── Backgrounds (Dark) ──────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1D2E);
  static const Color darkSurface = Color(0xFF242840);
  static const Color darkSurfaceVariant = Color(0xFF2D3154);
  static const Color darkElevated = Color(0xFF363B5E);

  // ── Text (Light) ────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // ── Text (Dark) ─────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFFB0B3C8);
  static const Color darkTextHint = Color(0xFF6B6F8A);

  // ── Mood Colors ─────────────────────────────────────────
  static const Color moodGreat = Color(0xFF6BCB77);
  static const Color moodGood = Color(0xFF9DC4E8);
  static const Color moodOkay = Color(0xFFF4C27F);
  static const Color moodBad = Color(0xFFE8A87C);
  static const Color moodAwful = Color(0xFFD4726A);

  // ── Emergency ───────────────────────────────────────────
  static const Color emergency = Color(0xFFE74C3C);
  static const Color emergencyLight = Color(0xFFFDEDED);
  static const Color emergencyDark = Color(0xFF3D1A1A);

  // ── Gradients ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7EB6E6), Color(0xFF6B9BD2), Color(0xFF5A8AC1)],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F4F8), Color(0xFFFAF8F5)],
  );

  static const LinearGradient darkCalmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E2140), Color(0xFF1A1D2E)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8E8D4), Color(0xFFE8C4A8), Color(0xFFD4A088)],
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 100;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> colorShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// Softer shadows for dark mode — glow effect instead of drop shadow.
  static List<BoxShadow> get darkSoft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  // Light Theme
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.emergency,
      ),
      textTheme: _buildTextTheme(baseTextTheme, Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBorder,
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textHint,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
        space: AppSpacing.lg,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Dark Theme — Midnight blues, soft charcoals, soothing contrast
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Color(0xFF1A1D2E),
        secondary: AppColors.secondary,
        onSecondary: Color(0xFF1A1D2E),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.emergency,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
      ),
      textTheme: _buildTextTheme(baseTextTheme, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBorder,
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextHint,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkSurfaceVariant,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkElevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Shared Text Theme Builder
  // ═══════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(TextTheme base, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary = isLight ? AppColors.textPrimary : AppColors.darkTextPrimary;
    final secondary =
        isLight ? AppColors.textSecondary : AppColors.darkTextSecondary;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 34,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 28,
        letterSpacing: -0.3,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: primary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: secondary,
        fontSize: 14,
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
