import 'package:flutter/material.dart';

const _milkTea = Color(0xFF8B5E3C);
const _taro = Color(0xFF8F78A8);
const _bobaBlack = Color(0xFF2A211D);
const _cream = Color(0xFFFFF8F0);
const _peach = Color(0xFFFFB38A);

final ThemeData bobaTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _milkTea,
    brightness: Brightness.light,
  ).copyWith(
    primary: _milkTea,
    onPrimary: Colors.white,
    secondary: _taro,
    onSecondary: Colors.white,
    tertiary: _peach,
    surface: _cream,
    onSurface: _bobaBlack,
  ),
  scaffoldBackgroundColor: _cream,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: _cream,
    foregroundColor: _bobaBlack,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
);
