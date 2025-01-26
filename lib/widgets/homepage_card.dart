import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'package:get/get.dart';


class HomePageCard extends StatefulWidget {
  final Color backgroundColor;
  final double progress;
  final String title;
  final Icon icon;
  final VoidCallback onPressed;

  const HomePageCard(
      {super.key,
      required this.icon,
      required this.backgroundColor,
      required this.progress,
      required this.title,
      required this.onPressed});

  @override
  State<HomePageCard> createState() => _HomePageCardState();
}

class _HomePageCardState extends State<HomePageCard> {

  @override
  Widget build(BuildContext context) {
    String achievementInPercentage = "";
    if(widget.progress != 0.0){
       num achievementInPercentageRounded = (widget.progress * 100).round();
       achievementInPercentage = () {
         if  (achievementInPercentageRounded.toString().length == 3) {
           return '${achievementInPercentageRounded.toString()[0].tr}${achievementInPercentageRounded.toString()[1].tr}${achievementInPercentageRounded.toString()[2].tr} %';
         }
         else if (achievementInPercentageRounded.toString().length == 2) {
           return '${achievementInPercentageRounded.toString()[0].tr}${achievementInPercentageRounded.toString()[1].tr} %';

          }
         else {
           return '${achievementInPercentageRounded.toString()[0].tr} %';
         }
       }();
    }
    else{
      achievementInPercentage =  '${'0'.tr} %' ;
    }

    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Card(
          color: widget.backgroundColor,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                  widget.icon,
                  const SizedBox(width: 10),
                  AutoSizeText(
                    widget.title,
                    style: Fonts.homePageCardLabel,
                    minFontSize: 16, // Set the minimum font size
                    maxFontSize: 16, // Set the maximum font size
                    maxLines: 1, // Limit the text to a single line
                  ),
                ]),
                Container(
                  margin:
                      const EdgeInsets.only(top: 15, right: 20, left: 20, bottom: 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: widget.progress,
                        minHeight: 30,
                        backgroundColor: AppColors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.salmon),
                      ),
                      AutoSizeText(
                        achievementInPercentage,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                        maxLines: 2, // Limit the text to a single line
                      ),
                    ],
                  )
                ),
              ],
            ),
          )),
    );
  }
}
