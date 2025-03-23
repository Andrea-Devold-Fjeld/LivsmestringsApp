import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'package:get/get.dart';


class HomePageCard extends StatefulWidget {
  final Color backgroundColor;
  final int categoryId;
  //final double progress;
  final String title;
  final Icon icon;
  final VoidCallback onPressed;

  const HomePageCard(
      {super.key,
      required this.icon,
      required this.backgroundColor,
        required this.categoryId,
      //required this.progress,
      required this.title,
      required this.onPressed});

  @override
  State<HomePageCard> createState() => _HomePageCardState();
}

class _HomePageCardState extends State<HomePageCard> {

  @override
  Widget build(BuildContext context) {
    var homepageController = Get.find<HomePageController>();
    var progress = homepageController.progress[widget.categoryId];
    double progressValue = progress?.progress.toDouble() ?? 0.0;
    String achievementInPercentage = "";

// Calculate the percentage value
    num achievementInPercentageRounded = (progressValue * 100).round();

// Format the percentage string with translations
    if (progressValue != 0.0) {
      final percentString = achievementInPercentageRounded.toString();
      final translatedDigits = percentString.split('')
          .map((digit) => digit.tr)
          .join('');
      achievementInPercentage = '$translatedDigits %';
    } else {
      achievementInPercentage = '${'0'.tr} %';
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
                  margin: const EdgeInsets.only(top: 15, right: 20, left: 20, bottom: 0),
                  // Wrap progress-dependent UI with Obx
                  child: Obx(() {
                    var progress = homepageController.progress[widget.categoryId];
                    double progressValue = progress?.progress.toDouble() ?? 0.0;

                    // Calculate the percentage value
                    num achievementInPercentageRounded = (progressValue * 100).round();

                    // Format the percentage string with translations
                    String achievementInPercentage;
                    if (progressValue != 0.0) {
                      final percentString = achievementInPercentageRounded.toString();
                      final translatedDigits = percentString.split('')
                          .map((digit) => digit.tr)
                          .join('');
                      achievementInPercentage = '$translatedDigits %';
                    } else {
                      achievementInPercentage = '${'0'.tr} %';
                    }

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: progressValue,
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
                          maxLines: 2,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
