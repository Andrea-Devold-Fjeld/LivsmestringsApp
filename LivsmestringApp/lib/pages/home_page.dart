import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/databse/database_operation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/language_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import '../controllers/home-page-controller.dart';
import '../styles/colors.dart';
import '../widgets/buttom_navigation.dart';
import '../widgets/homepage_card.dart';

class HomePage extends StatelessWidget {
  final int? selectedLanguage;
  const HomePage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final homePageController = Get.find<HomePageController>();
    if(selectedLanguage == null){
      return LanguagePage(selectedLanguage: (int value) {});
    }
    else {
      return Scaffold(
        body:
        IndexedStack(
          index: homePageController.currentIndex.value,
          children: [
            HomePageContent(
              categories: homePageController.categories,
              progress: homePageController.progress.value,
              updateProgress: homePageController.updateProgress,
            ),
            ChapterPage(
              category: homePageController.careerCategory.value!,
              updateProgress: homePageController.updateProgress,
            ),
            ChapterPage(
              category: homePageController.healthCategory.value!,
              updateProgress: homePageController.updateProgress,
            ),
            LanguagePageNav(),
          ],
        )
        ,
        bottomNavigationBar: ButtomNavigationBar(
          selectedTab: homePageController.currentIndex.value,
          onTap: homePageController.changePage,
        ),
      );
    }

  }
}

class HomePageContent extends StatefulWidget {
  final List<CategoryDTO> categories;
  final Map<int, ProgressModel> progress;
  final ValueSetter<bool> updateProgress;

  const HomePageContent({super.key, required this.categories, required this.progress, required this.updateProgress});

  @override
  State<StatefulWidget> createState() => _HomePageContent();
}

class _HomePageContent extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    final homePageController = Get.find<HomePageController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/logo_black.png',
          width: 300,
        ),
        ...widget.categories.map((entry) {
          int id = entry.id;
          String name = entry.name;
          String title = name.tr;
          Icon icon;
          Color backgroundColor;

          switch (name) {
            case 'career':
              icon = Icon(
                Icons.work,
                size: 40,
                color: AppColors.white,
              );
              backgroundColor = AppColors.weakedGreen;
              break;
            case 'health':
              icon = Icon(
                Icons.local_hospital,
                size: 40,
                color: AppColors.white,
              );
              backgroundColor = AppColors.spaceCadet;
              break;
            default:
              icon = Icon(
                Icons.help,
                size: 40,
                color: AppColors.white,
              );
              backgroundColor = Colors.grey;
              break;
          }

          return HomePageCard(
            key: ValueKey(name),
            progress: widget.progress[id]?.progress ?? 0.0,
            backgroundColor: backgroundColor,
            title: title,
            icon: icon,
            onPressed: () {
              log("In onTap homepagecard title: $title");
              var route = "/${title.toLowerCase()}";
              log("route is $route");
              homePageController.changePage(1);

            }
            );
            },
        )
      ],
    );
  }
}
