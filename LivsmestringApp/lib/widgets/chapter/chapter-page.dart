
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/models/cateregory.dart';
import 'package:livsmestringapp/widgets/chapter/video_list.dart';

import '../../controllers/database-controller.dart';
import '../../controllers/home-page-controller.dart';
import '../../models/page_enum.dart';
import '../../styles/colors.dart';
import '../../styles/fonts.dart';

/**
 * * * This widget is responsible for displaying the chapter page.
 */
class ChapterPage extends StatefulWidget {
  final CategoryClass category;
  final ValueSetter<bool> updateProgress;

  const ChapterPage({super.key, required this.category, required this.updateProgress}); //required this.data

  void _updateProgress() {
    updateProgress(true);
  }
  @override
  _ChapterPageState createState() => _ChapterPageState();
}


class _ChapterPageState extends State<ChapterPage> with SingleTickerProviderStateMixin {
  //late TabController _tabController;
  late String pageTitle;
  late Color pageColor;
  final DatabaseController _databaseController = Get.find<DatabaseController>();
  final HomePageController _homeController = Get.find<HomePageController>();
  CategoryDto? data;

  void reloadData() {
    //_databaseController.getDatamodelWithLAnguage(widget.category.name, _homeController.currentLocale.value!.languageCode).then((result) {
    _homeController.fetchDataFromCategory(widget.category.name).then((onValue) {
      if(!mounted) return;
      setState(() {
        data = onValue;
        widget._updateProgress();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _homeController.fetchDataFromCategory(widget.category.name).then((onValue) {
      if(!mounted) return;
        setState(() {
          data = onValue;
          widget._updateProgress();
        });
      });
    switch (widget.category.name) {
      case 'career':
        pageTitle = "Career";
        pageColor = AppColors.weakedGreen;
        break;
      case 'health':
        pageTitle = "Health";
        pageColor = AppColors.spaceCadet;
        break;
      default:
        pageTitle = "Unknown";
        pageColor = Colors.grey[800]!;
        break;
    }

  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homePageController = Get.find<HomePageController>();
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                homePageController.currentIndex.value = Pages.home.index;
              },
              icon: const Icon(
                semanticLabel: "Back",
                Icons.arrow_back,
                color: AppColors.white,
                size: 30,
              ),
            ),
          ],
        ),
        title: AutoSizeText(
          pageTitle.tr,
          style: Fonts.homePageCardLabel,
          minFontSize: 10,
          maxFontSize: 20,
          maxLines: 2,
        ),
        backgroundColor: pageColor,
      ),
      body: data != null ? SingleChildScrollView(
        child: Column(
          children: data!.chapters.isNotEmpty ? data!.chapters.map((chapter) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter header
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: AutoSizeText(
                      chapter.title.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 15,
                      maxFontSize: 15,
                      maxLines: 4,
                    ),
                    textColor: Colors.purple[600],
                    children: [
                      VideoList(chapter: chapter, updateWatched: (bool value) { reloadData(); }),
                    ],
                  ),
                ),
              ],
            );
          }).toList()
          :[ Center(child: Text("No Videos, Please come back later"),)]
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}




