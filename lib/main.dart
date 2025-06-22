import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/constants.dart';
import 'screens/translation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SmartTranslatorApp());
}

class SmartTranslatorApp extends StatelessWidget {
  const SmartTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Translator',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const TranslationScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppConstants.cardColor,
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing,
            vertical: AppConstants.smallSpacing,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.spacing),
        hintStyle: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: AppConstants.fontSizeMedium,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppConstants.primaryColor,
        inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.3),
        thumbColor: AppConstants.primaryColor,
        overlayColor: AppConstants.primaryColor.withOpacity(0.2),
        valueIndicatorColor: AppConstants.primaryColor,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.accentColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.accentColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppConstants.textSecondaryColor,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppConstants.backgroundColor,

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
