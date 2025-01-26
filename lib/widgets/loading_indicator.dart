import 'package:flutter/material.dart';
import '../styles/colors.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:get/get.dart';


class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 150.0,
      lineWidth: 12.0,
      animation: true,
      animationDuration: 3000,
      percent: 1,
      center:  Text(
        "loading".tr,
        style:
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: AppColors.GreenLeave,
    );
  }
}
