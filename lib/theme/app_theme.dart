import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Core colors
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF141418);
  static const Color card = Color(0xFF1A1A1F);
  static const Color cardHover = Color(0xFF222228);

  // Accent colors
  static const Color primary = Color(0xFF00E676);
  static const Color primaryDim = Color(0xFF00C853);
  static const Color accent = Color(0xFF7C4DFF);
  static const Color accentDim = Color(0xFF651FFF);
  static const Color destructive = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);
  static const Color info = Color(0xFF448AFF);

  // Text colors
  static const Color text = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFFB0B0BC);
  static const Color textMuted = Color(0xFF6B6B78);
  static const Color textOnPrimary = Color(0xFF0D0D0F);

  // Border & Divider
  static const Color border = Color(0xFF2A2A32);
  static const Color borderLight = Color(0xFF35353F);
  static const Color divider = Color(0xFF2A2A32);

  // Status
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color verifiedGreen = Color(0xFF00E676);

  // Source badges
  static const Color curseforgeBadge = Color(0xFFF16436);
  static const Color mcpedlBadge = Color(0xFF2196F3);

  // Dimensions
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 100.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: textOnPrimary,
        primaryContainer: Color(0xFF003D1F),
        secondary: accent,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF2D0080),
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: card,
        error: error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        toolbarTextStyle: textTheme.bodyMedium,
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: primary.withOpacity(0.15),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        modalBackgroundColor: surface,
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 0,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: textMuted,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: border, width: 0.5),
        ),
        contentTextStyle: textTheme.bodyMedium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide(color: border, width: 0.5),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(textMuted.withOpacity(0.3)),
        thickness: WidgetStatePropertyAll(6),
        radius: Radius.circular(radiusFull),
      ),
      iconTheme: IconThemeData(
        color: textSecondary,
        size: 24,
      ),
    );
  }

  static TextTheme get textTheme {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: text,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: text,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: text,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: text,
        fontSize: 16,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: text,
        fontSize: 14,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: textSecondary,
        fontSize: 12,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: textMuted,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    );
  }

  // Shimmer colors for skeleton loading
  static Color get shimmerBase => card;
  static Color get shimmerHighlight => cardHover;

  // Helper to darken/lighten
  static Color withAlpha(Color color, double alpha) {
    return color.withOpacity(alpha);
  }
}
