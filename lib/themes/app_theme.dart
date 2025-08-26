import 'package:flutter/material.dart';

class AppTheme {
  // Paleta base de colores
  static const Color primary = Color(0xFF1ABC9C);
  static const Color secondary = Color(0xFF38434E);
  static const Color backgroundLight = Color(0xFFECF0F1);
  static const Color backgroundDark = Color(0xFF38434E);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF38434E);
  static const Color error = Colors.red;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      color: backgroundLight,
      iconTheme: IconThemeData(color: secondary),
      titleTextStyle: TextStyle(color: secondary, fontSize: 20),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: secondary),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: secondary),
      bodyMedium: TextStyle(color: secondary),
      titleMedium: TextStyle(color: secondary, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: secondary, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: secondary,
      suffixIconColor: secondary,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primary),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primary),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      labelStyle: TextStyle(color: primary),
      floatingLabelStyle: TextStyle(color: primary),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withOpacity(0.2),
      selectionHandleColor: primary,
    ),
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      background: backgroundLight,
      onBackground: secondary,
      surface: surfaceLight,
      onSurface: secondary,
      error: error,
      onError: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    cardColor: surfaceLight,
    dividerColor: secondary.withOpacity(0.2),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      color: backgroundDark,
      iconTheme: IconThemeData(color: backgroundLight),
      titleTextStyle: TextStyle(color: backgroundLight, fontSize: 20),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: backgroundLight),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: backgroundLight),
      bodyMedium: TextStyle(color: backgroundLight),
      titleMedium: TextStyle(color: backgroundLight, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: backgroundLight, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: Colors.white,                      // ICONOS DE INPUTS VERDE (se ve bien en fondo oscuro)
      suffixIconColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primary),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primary),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      labelStyle: TextStyle(color: primary),
      floatingLabelStyle: TextStyle(color: primary),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withOpacity(0.2),
      selectionHandleColor: primary,
    ),
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: backgroundLight,
      onSecondary: secondary,
      background: backgroundDark,
      onBackground: backgroundLight,
      surface: surfaceDark,
      onSurface: backgroundLight,
      error: error,
      onError: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    cardColor: surfaceDark,
    dividerColor: backgroundLight.withOpacity(0.15),
  );
}