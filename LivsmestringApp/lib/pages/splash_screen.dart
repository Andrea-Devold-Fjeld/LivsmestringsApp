import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styles/fonts.dart';

class SplashScreen extends StatefulWidget {
  final int? selectedLanguage;
  const SplashScreen({super.key, required this.selectedLanguage});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late int? selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3)
    );




    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_black.png',
              width: 300,
            ),
            SizedBox(
              height: 30,
            ),
            AutoSizeText('life_mastery_app'.tr,
                style: Fonts.italicBold,
              minFontSize: 8, // Set the minimum font size
              maxFontSize: 30, // Set the maximum font size
              maxLines: 1, // Limit the text to a single line
            ),
          ],
        ),
      ),
    );
  }
}
