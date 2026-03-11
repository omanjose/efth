import 'package:efth/app/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ─── Brand Palette ───────────────────────────────────────────────────────────
class AppColors {
  // Warm gold — primary accent for both themes
  static const gold = Color(0xFFC4A46A);
  static const goldLight = Color(0xFFD9BC8A);
  static const goldDark = Color(0xFF9A7D4A);

  // Dark theme surfaces
  static const darkBg = Color(0xFF0D0C0A);
  static const darkSurface = Color(0xFF1A1814);
  static const darkCard = Color(0xFF211F1A);
  static const darkBorder = Color(0xFF2E2B24);
  static const darkMuted = Color(0xFF7A7468);

  // Light theme surfaces
  static const lightBg = Color(0xFFF7F3EC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFAFAF7);
  static const lightBorder = Color(0xFFE8E2D9);
  static const lightMuted = Color(0xFF9A9088);

  // Semantic
  static const error = Color(0xFFE87070);
  static const success = Color(0xFF7BAE8F);

  // Language accents
  static const english = Color(0xFFC4A96A);
  static const igbo = Color(0xFF7BAE8F);
  static const efik = Color(0xFF6F70E3);
}

// ─── Text Styles ─────────────────────────────────────────────────────────────
class AppTextStyles {
  static const String _display =
      'serif'; // Maps to system serif (use google_fonts for Cinzel)

  static TextStyle appTitle(Color color) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 3,
  );

  static TextStyle sectionLabel(Color color) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 2,
  );

  static TextStyle hymnTitle(Color color) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle hymnId(Color color) =>
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color);

  static TextStyle lyrics(Color color, double fontSize) => TextStyle(
    fontSize: fontSize,
    height: 1.9,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w300,
    color: color,
  );
}

class ThemeService extends GetxController {
  final _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = StorageService.getThemeMode();
    switch (savedMode) {
      case 'light':
        _themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        _themeMode.value = ThemeMode.dark;
        break;
      default:
        _themeMode.value = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    String modeString = 'system';
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    StorageService.setThemeMode(modeString);
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.gold,
        onPrimary: Colors.white,

        // seedColor: const Color(0xFF1976D2), // Bright blue
        // primary: const Color(0xFF1976D2),
        secondary: const Color(0xFFE91E63), // Bright pink
        tertiary: const Color(0xFF9C27B0), // Bright purple

        // secondary: AppColors.goldLight,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: const Color(0xFF1A1714),
        primaryContainer: const Color(0xFFF5EDD9),
        onPrimaryContainer: AppColors.goldDark,
        surfaceVariant: AppColors.lightCard,
        onSurfaceVariant: AppColors.lightMuted,
        outline: AppColors.lightBorder,
        shadow: Colors.black12,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        // backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF1A1714),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white, size: 20),
        actionsIconTheme: IconThemeData(color: Colors.white, size: 20),
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 2.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        minVerticalPadding: 10,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.gold,
        disabledColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        hintStyle: const TextStyle(
          color: AppColors.lightMuted,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        prefixIconColor: AppColors.lightMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF1A1714),
          highlightColor: AppColors.lightBorder,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        // backgroundColor: AppColors.lightCard,
        // foregroundColor: Color(0xFF1A1714),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1714),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme(
        // seedColor: const Color(0xFF0D47A1), // Dark blue
        brightness: Brightness.dark,
        // primary: const Color(0xFF0D47A1),
        // secondary: const Color(0xFF880E4F), // Dark pink
        tertiary: const Color(0xFF4A148C), // Dark purple
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        primary: AppColors.gold,
        onPrimary: AppColors.darkBg,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.darkBg,
        error: AppColors.error,
        onError: Colors.white,
        // surface: AppColors.darkSurface,
        onSurface: const Color(0xFFEDE8DF),
        primaryContainer: const Color(0xFF2A2518),
        onPrimaryContainer: AppColors.gold,
        surfaceVariant: AppColors.darkCard,
        onSurfaceVariant: AppColors.darkMuted,
        outline: AppColors.darkBorder,
        shadow: Colors.black54,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF141210),
        foregroundColor: Color(0xFFEDE8DF),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Color(0xFFEDE8DF), size: 20),
        actionsIconTheme: IconThemeData(color: Color(0xFFEDE8DF), size: 20),
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 2.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        minVerticalPadding: 10,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.gold,
        disabledColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Color(0xFFEDE8DF),
        ),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        hintStyle: const TextStyle(
          color: AppColors.darkMuted,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        prefixIconColor: AppColors.darkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFFEDE8DF),
          highlightColor: AppColors.darkBorder,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        // backgroundColor: AppColors.darkCard,
        // foregroundColor: Color(0xFFEDE8DF),
        backgroundColor: const Color(0xFF880E4F),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFEDE8DF),
        ),
      ),
    );
  }
}
