import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF1ABC9C),
    scaffoldBackgroundColor: Color(0xFFECF0F1),
    appBarTheme: AppBarTheme(
      color: Color(0xFFECF0F1),
      iconTheme: IconThemeData(color: Color(0xFF38434E)),
      titleTextStyle: TextStyle(color: Color(0xFF38434E), fontSize: 20),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: Color(0xFF38434E)),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF38434E)),
      bodyMedium: TextStyle(color: Color(0xFF38434E)),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF1ABC9C),
      textTheme: ButtonTextTheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1ABC9C)),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1ABC9C)),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF1ABC9C),
    scaffoldBackgroundColor: Color(0xFF38434E),
    appBarTheme: AppBarTheme(
      color: Color(0xFF38434E),
      iconTheme: IconThemeData(color: Color(0xFFECF0F1)),
      titleTextStyle: TextStyle(color: Color(0xFFECF0F1), fontSize: 20),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: Color(0xFFECF0F1)),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFECF0F1)),
      bodyMedium: TextStyle(color: Color(0xFFECF0F1)),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF1ABC9C),
      textTheme: ButtonTextTheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1ABC9C)),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1ABC9C)),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ),
  );
}