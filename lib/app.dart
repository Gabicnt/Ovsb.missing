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
      themeMode: ThemeMode.system,
      theme: _buildLightTheme(),
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
      cardTheme: CardThemeData(
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
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KindleColors.white,
        selectedItemColor: KindleColors.black,
        unselectedItemColor: KindleColors.medium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: KindleColors.black,
        inactiveTrackColor: KindleColors.light,
        thumbColor: KindleColors.black,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: KindleColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: textTheme,
    );
  }

  ThemeData _buildDarkTheme() {
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: KindleColorsDark.black,
        onPrimary: KindleColorsDark.white,
        secondary: KindleColorsDark.dark,
        onSecondary: KindleColorsDark.white,
        surface: KindleColorsDark.white,
        onSurface: KindleColorsDark.black,
        background: KindleColorsDark.offWhite,
        onBackground: KindleColorsDark.black,
        error: KindleColorsDark.black,
        onError: KindleColorsDark.white,
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
      cardTheme: CardThemeData(
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
          backgroundColor: KindleColorsDark.black,
          foregroundColor: KindleColorsDark.white,
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
          side: const BorderSide(color: KindleColorsDark.black, width: 1),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
          borderSide: const BorderSide(color: KindleColorsDark.black, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KindleColorsDark.white,
        selectedItemColor: KindleColorsDark.black,
        unselectedItemColor: KindleColorsDark.medium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KindleColorsDark.white;
          }
          return KindleColorsDark.medium;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KindleColorsDark.black;
          }
          return KindleColorsDark.light;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: KindleColorsDark.black,
        inactiveTrackColor: KindleColorsDark.light,
        thumbColor: KindleColorsDark.black,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: KindleColorsDark.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: textTheme,
    );
  }
}
