import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/periodo_provider.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'utils/cores.dart';

class FaltaControlApp extends StatelessWidget {
  const FaltaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OvsbMissing',
      debugShowCheckedModeBanner: false,
      
      // TEMA AUTOMÁTICO - detecta configuração do dispositivo
      themeMode: ThemeMode.system,
      
      // Tema claro
      theme: _buildLightTheme(),
      
      // Tema escuro
      darkTheme: _buildDarkTheme(),
      
      home: Consumer<PeriodoProvider>(
        builder: (context, periodoProvider, child) {
          if (periodoProvider.periodo == null) {
            return const SetupScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }

  /// Tema CLARO (estilo Kindle papel)
  ThemeData _buildLightTheme() {
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: KindleColors.black,
        onPrimary: KindleColors.white,
        secondary: KindleColors.dark,
        onSecondary: KindleColors.white,
        surface: KindleColors.white,
        onSurface: KindleColors.black,
        background: KindleColors.offWhite,
        onBackground: KindleColors.black,
        error: KindleColors.black,
        onError: KindleColors.white,
        outline: KindleColors.light,
      ),
      
      scaffoldBackgroundColor: KindleColors.offWhite,
      
      appBarTheme: AppBarTheme(
        backgroundColor: KindleColors.offWhite,
        foregroundColor: KindleColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: KindleColors.black,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: KindleColors.dark,
          size: 22,
        ),
      ),
      
      cardTheme: CardTheme(
        color: KindleColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: KindleColors.light, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KindleColors.black,
          foregroundColor: KindleColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KindleColors.black,
          side: const BorderSide(color: KindleColors.black, width: 1),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KindleColors.dark,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KindleColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KindleColors.light),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KindleColors.light),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KindleColors.black, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: KindleColors.medium),
        hintStyle: textTheme.bodyMedium?.copyWith(color: KindleColors.medium),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KindleColors.white,
        selectedItemColor: KindleColors.black,
        unselectedItemColor: KindleColors.medium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KindleColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: KindleColors.light,
        thickness: 1,
        space: 1,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KindleColors.white;
          }
          return KindleColors.medium;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KindleColors.black;
          }
          return KindleColors.light;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),
      
      sliderTheme: const SliderThemeData(
        activeTrackColor: KindleColors.black,
        inactiveTrackColor: KindleColors.light,
        thumbColor: KindleColors.black,
        overlayColor: Color(0x1A000000),
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: KindleColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: KindleColors.black,
        contentTextStyle: TextStyle(color: KindleColors.white),
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KindleColors.black,
        linearTrackColor: KindleColors.light,
      ),
      
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: KindleColors.black),
        displayMedium: textTheme.displayMedium?.copyWith(color: KindleColors.black),
        displaySmall: textTheme.displaySmall?.copyWith(color: KindleColors.black),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: KindleColors.black),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: KindleColors.black),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: KindleColors.black),
        titleLarge: textTheme.titleLarge?.copyWith(color: KindleColors.black),
        titleMedium: textTheme.titleMedium?.copyWith(color: KindleColors.black),
        titleSmall: textTheme.titleSmall?.copyWith(color: KindleColors.dark),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: KindleColors.dark),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: KindleColors.dark),
        bodySmall: textTheme.bodySmall?.copyWith(color: KindleColors.medium),
        labelLarge: textTheme.labelLarge?.copyWith(color: KindleColors.black),
        labelMedium: textTheme.labelMedium?.copyWith(color: KindleColors.dark),
        labelSmall: textTheme.labelSmall?.copyWith(color: KindleColors.medium),
      ),
    );
  }

  /// Tema ESCURO (estilo Kindle noturno)
  ThemeData _buildDarkTheme() {
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: KindleColorsDark.black,
        onPrimary: KindleColorsDark.offWhite,
        secondary: KindleColorsDark.dark,
        onSecondary: KindleColorsDark.offWhite,
        surface: KindleColorsDark.white,
        onSurface: KindleColorsDark.black,
        background: KindleColorsDark.offWhite,
        onBackground: KindleColorsDark.black,
        error: Color(0xFFFF6B6B),
        onError: KindleColorsDark.offWhite,
        outline: KindleColorsDark.light,
      ),
      
      scaffoldBackgroundColor: KindleColorsDark.offWhite,
      
      appBarTheme: AppBarTheme(
        backgroundColor: KindleColorsDark.offWhite,
        foregroundColor: KindleColorsDark.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: KindleColorsDark.black,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: KindleColorsDark.dark,
          size: 22,
        ),
      ),
      
      cardTheme: CardTheme(
        color: KindleColorsDark.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: KindleColorsDark.light, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KindleColors.white,
          foregroundColor: KindleColors.black,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KindleColorsDark.black,
          side: const BorderSide(color: KindleColorsDark.dark, width: 1),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KindleColorsDark.dark,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KindleColorsDark.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KindleColorsDark.light),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KindleColorsDark.light),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KindleColorsDark.dark, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: KindleColorsDark.medium),
        hintStyle: textTheme.bodyMedium?.copyWith(color: KindleColorsDark.medium),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KindleColorsDark.white,
        selectedItemColor: KindleColorsDark.black,
        unselectedItemColor: KindleColorsDark.medium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KindleColorsDark.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: KindleColorsDark.light,
        thickness: 1,
        space: 1,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KindleColors.black;
          }
          return KindleColorsDark.medium;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KindleColors.white;
          }
          return KindleColorsDark.light;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),
      
      sliderTheme: const SliderThemeData(
        activeTrackColor: KindleColors.white,
        inactiveTrackColor: KindleColorsDark.light,
        thumbColor: KindleColors.white,
        overlayColor: Color(0x1AFFFFFF),
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: KindleColorsDark.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: KindleColors.white,
        contentTextStyle: TextStyle(color: KindleColors.black),
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KindleColors.white,
        linearTrackColor: KindleColorsDark.light,
      ),
      
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: KindleColorsDark.black),
        displayMedium: textTheme.displayMedium?.copyWith(color: KindleColorsDark.black),
        displaySmall: textTheme.displaySmall?.copyWith(color: KindleColorsDark.black),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: KindleColorsDark.black),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: KindleColorsDark.black),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: KindleColorsDark.black),
        titleLarge: textTheme.titleLarge?.copyWith(color: KindleColorsDark.black),
        titleMedium: textTheme.titleMedium?.copyWith(color: KindleColorsDark.black),
        titleSmall: textTheme.titleSmall?.copyWith(color: KindleColorsDark.dark),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: KindleColorsDark.dark),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: KindleColorsDark.dark),
        bodySmall: textTheme.bodySmall?.copyWith(color: KindleColorsDark.medium),
        labelLarge: textTheme.labelLarge?.copyWith(color: KindleColorsDark.black),
        labelMedium: textTheme.labelMedium?.copyWith(color: KindleColorsDark.dark),
        labelSmall: textTheme.labelSmall?.copyWith(color: KindleColorsDark.medium),
      ),
    );
  }
}
