import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: AppColors.white,
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        surface: AppColors.white,
    )
);