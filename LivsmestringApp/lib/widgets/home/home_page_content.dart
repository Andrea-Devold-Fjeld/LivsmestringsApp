import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/models/cateregory.dart';
import 'package:livsmestringapp/models/page_enum.dart';

import '../../controllers/home-page-controller.dart';
import '../../styles/colors.dart';
import 'homepage_card.dart';

/**
 * * * This widget is responsible for displaying the content of the home page.
 */
class HomePageContent extends StatefulWidget {
  final List<CategoryClass> categories;
  final ValueSetter<bool> updateProgress;

  const HomePageContent({super.key, required this.categories, required this.updateProgress});

  @override
  State<StatefulWidget> createState() => _HomePageContent();
}

class _HomePageContent extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    final homePageController = Get.find<HomePageController>();

    return SizedBox(
    height: MediaQuery.of(context).size.height,
    child:Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/logo_black.png',
          width: 300,
          semanticLabel: "Logo of Oslo skolen",
        ),
        ...widget.categories.map((entry) {
          final categporyId = entry.id;
          // Use the category ID to determine the icon and background color
          int id = categporyId;
          String name = entry.name;
          String title = name.tr;
          Icon icon;
          Color backgroundColor;
          Pages page = Pages.home; // need to have a fallback value
          switch (name) {
            case 'career':
              icon = Icon(
                Icons.work,
                size: 40,
                color: AppColors.white,
                semanticLabel: "Career",
              );
              page = Pages.career;
              backgroundColor = AppColors.weakedGreen;
              break;
            case 'health':
              icon = Icon(
                Icons.local_hospital,
                size: 40,
                color: AppColors.white,
                semanticLabel: "Health",
              );
              page = Pages.health;
              backgroundColor = AppColors.spaceCadet;
              break;
            default:
              icon = Icon(
                Icons.help,
                size: 40,
                color: AppColors.white,
                semanticLabel: "Unknown",
              );
              backgroundColor = Colors.grey;
              break;
          }
          return Semantics(
            label: 'Navigate to $title',
            button: true,
            child: HomePageCard(
              key: ValueKey(name),
              categoryId: id,
              backgroundColor: backgroundColor,
              title: title,
              icon: icon,
              onPressed: () {
                homePageController.currentIndex.value = page.index;
              },
            ),
          );
            },
        )
      ],
    ));
  }
}


