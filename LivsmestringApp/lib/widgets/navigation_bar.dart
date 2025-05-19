import 'package:flutter/material.dart';
import '../styles/colors.dart';
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
      currentIndex: widget.selectedTab,
      onTap: widget.onTap,
      backgroundColor: AppColors.lightGrey, // Set background color here
      selectedItemColor: AppColors.tune, // Set selected item color if needed
      unselectedItemColor: Colors.grey, // Set unselected item color if needed


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
