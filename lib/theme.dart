import 'package:flutter/material.dart';

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    // We force every surface property to White and every primary property to Black
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      // These three control the backgrounds of panels, sheets, and the scaffold
      surface: Colors.white,
      onSurface: Colors.black,
      // ignore: deprecated_member_use
      background: Colors.white, 
      // ignore: deprecated_member_use
      onBackground: Colors.black,
      // This is likely the culprit for the "Red" panels
      surfaceContainer: Colors.white, 
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: Colors.white,
    ),

    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      surfaceTintColor: Colors.transparent, // Prevents tinting on scroll
    ),

    // Ensure dialogs and bottom sheets stay white
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    ),
  );
}