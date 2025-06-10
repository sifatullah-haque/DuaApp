import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF66BB6A);

  // Secondary Colors
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color lightGold = Color(0xFFFFF176);
  static const Color darkGold = Color(0xFFFF8F00);

  // Neutral Colors
  static const Color glassMorphWhite = Color(0xFFFFFFFF);
  static const Color glassMorphBlack = Color(0xFF000000);
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color whiteText = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: goldAccent,
        surface: glassMorphWhite.withOpacity(0.1),
        background: Colors.transparent,
        onPrimary: whiteText,
        onSecondary: primaryText,
        onSurface: primaryText,
        onBackground: primaryText,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        iconTheme: const IconThemeData(color: whiteText),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card Theme (Glassmorphic)
      cardTheme: CardThemeData(
        color: glassBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen.withOpacity(0.8),
          foregroundColor: whiteText,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: glassBorder, width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          textStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.sp,
          color: secondaryText,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.sp,
          color: secondaryText,
        ),
      ),

      // Text Themes - Updated with ScreenUtil
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.normal,
          color: whiteText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: whiteText,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.normal,
          color: secondaryText,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: whiteText, size: 20.sp),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen.withOpacity(0.8),
        foregroundColor: whiteText,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: glassBackground,
        selectedItemColor: goldAccent,
        unselectedItemColor: whiteText.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: glassBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.sp,
          color: secondaryText,
        ),
        iconColor: whiteText,
      ),
    );
  }

  // Dynamic theme based on mood
  static ThemeData getMoodTheme(
    Color primaryColor,
    Color lightColor,
    Color darkColor,
    Color accentColor,
  ) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: glassMorphWhite.withOpacity(0.1),
        background: Colors.transparent,
        onPrimary: whiteText,
        onSecondary: whiteText,
        onSurface: whiteText,
        onBackground: whiteText,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        iconTheme: const IconThemeData(color: whiteText),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Text Themes
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: whiteText,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.normal,
          color: whiteText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: whiteText,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.normal,
          color: secondaryText,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: whiteText, size: 20.sp),
    );
  }

  // Glassmorphic Container Decoration
  static BoxDecoration get glassMorphicDecoration => BoxDecoration(
    color: glassBackground,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: glassBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // Glassmorphic Container with custom radius
  static BoxDecoration glassMorphicDecorationWithRadius(double radius) =>
      BoxDecoration(
        color: glassBackground,
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  // Background Container Widget
  static Widget backgroundContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen.withOpacity(0.2), darkGreen.withOpacity(0.4)],
          ),
        ),
        child: child,
      ),
    );
  }

  // Mood-based Background Container Widget
  static Widget moodBackgroundContainer({
    required Widget child,
    required Color primaryColor,
    required Color darkColor,
  }) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.3), darkColor.withOpacity(0.5)],
          ),
        ),
        child: child,
      ),
    );
  }

  // Mood-based glassmorphic decoration
  static BoxDecoration getMoodGlassMorphicDecoration(Color accentColor) =>
      BoxDecoration(
        color: glassBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
