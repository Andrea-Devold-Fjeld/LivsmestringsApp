import 'package:flutter/material.dart';
import '../styles/fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ListButton extends StatelessWidget {
  String content;
  bool active;
  Color activeColor;
  Color inactiveColor;
 // int buttonsLength;

  final VoidCallback onPressed;
  ListButton({super.key,
    required this.content,
    required this.activeColor,
    required this.inactiveColor,
    required this.active,
    required this.onPressed,
  //  required this.buttonsLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Container(
            width: MediaQuery.of(context).size.width,
       /*    height:
            buttonsLength == 5 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 1.6):
            buttonsLength == 11 ?
            MediaQuery.of(context).size.height/ (buttonsLength * 0.7):
            buttonsLength == 3 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 2.65):
            buttonsLength == 2 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 4.1):
            buttonsLength == 9 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 0.85):
            buttonsLength == 4 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 1.9):
            buttonsLength == 8 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 0.95):
            buttonsLength == 7 ?
            MediaQuery.of(context).size.height/ (buttonsLength* 1.15):
            MediaQuery.of(context).size.height/ (buttonsLength* 7.1 )
            ,

        */



            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(5),
              // border: Border.all(),
              //  shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: AutoSizeText(
                content,
                style: active
                    ? Fonts.LanguageButtonActive
                    : Fonts.LanguageButton,
                minFontSize: 15, // Set the minimum font size
                maxFontSize: 15, // Set the maximum font size
                maxLines: 4,
              ),
            ),
          ),
        ),
        SizedBox(height: 9), // Add space between buttons
      ],
    );
  }
}