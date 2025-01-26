import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';


class LanguageButton extends StatelessWidget {
  String language;
  bool active;
  final VoidCallback onPressed;
  LanguageButton(
      {super.key,
      required this.language,
      required this.active,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: onPressed,
            child: Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              // height: 50,
              decoration: BoxDecoration(
                color: active ? AppColors.weakedGreenComplementary : AppColors.spaceCadetComplementaryBlackText,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                  child:  AutoSizeText(
                language,
                style: active ? Fonts.LanguageButtonActive : Fonts.LanguageButton,
                overflow: TextOverflow.ellipsis,
                    minFontSize: 14, // Set the minimum font size
                    maxFontSize: 14, // Set the maximum font size
                    maxLines: 4,
              )),
            )),
        SizedBox(height: 5), // Add space between buttons
      ],
    );
  }
}
