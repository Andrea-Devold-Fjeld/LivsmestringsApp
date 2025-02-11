import 'package:flutter/material.dart';
import 'colors.dart';

class Fonts {
  static const regular = TextStyle(
    fontFamily: 'Oslo',
  );
  static const LanguageButton = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AppColors.tune,
  );

  static const LanguageButtonActive = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AppColors.white,
  );

  static const header1 = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: AppColors.tune,
  );
  static const header3 = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 25,
    color: AppColors.tune,
  );

  static const italic =
      TextStyle(fontFamily: 'Oslo', fontStyle: FontStyle.italic);
  static const italicBold = TextStyle(
    fontFamily: 'Oslo',
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    fontSize: 30,
  );
  static const bottomNavLabelSelected = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: AppColors.tune,
  );
  static const bottomNavLabel = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: AppColors.ashGrey,
  );
  static const homePageCardLabel = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.bold,
    fontSize: 25,
    color: AppColors.white,
  );
  static const header2 = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.w500,
    fontSize: 35,
    color: AppColors.tune,
  );
  static const appBarLabel = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.w500,
    fontSize: 20,
    color: AppColors.tune,
  );
  static const languagePageLogo = TextStyle(
    fontFamily: 'Oslo',
    fontWeight: FontWeight.w500,
    fontSize: 25,
    color: AppColors.tune,
  );
}
