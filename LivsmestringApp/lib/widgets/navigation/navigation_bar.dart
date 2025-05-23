
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import '../../styles/colors.dart';
import 'package:get/get.dart';

class NavigationBarWrapper extends StatefulWidget {
  final int selectedTab;
  final Function(int) onTap;
  const NavigationBarWrapper({
    super.key,
    required this.selectedTab,
    required this.onTap,
  });

  @override
  State<NavigationBarWrapper> createState() => NavigationBarWrapperState();
}

class NavigationBarWrapperState extends State<NavigationBarWrapper> {
  @override
  Widget build(BuildContext context) {
    return  BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.selectedTab,
      onTap: (index) {
        Get.find<HomePageController>().currentIndex.value = index;
        widget.onTap(index);
      },
      backgroundColor: AppColors.lightGrey,
      selectedItemColor: AppColors.tune,
      unselectedItemColor: Colors.grey,
      items:  [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'home'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.work,
          ),
          label: 'career_nav'.tr,
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.health_and_safety,
          ),
          label: 'health_nav'.tr,
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.language,
          ),
          label: 'language'.tr,
        ),
      ],
        );
  }
}
