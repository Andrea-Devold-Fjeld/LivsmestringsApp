
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/widgets/youtube-video-player.dart';

import '../controllers/database-controller.dart';
import '../controllers/home-page-controller.dart';
import '../models/DataModel.dart';
import '../models/DataModelDTO.dart';
import '../models/chapter-db.dart';
import '../models/task-db.dart';
import '../models/video-db.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';

class ChapterPage extends StatefulWidget {
  final CategoryDTO category;
  final ValueSetter<bool> updateProgress;

  const ChapterPage({super.key, required this.category, required this.updateProgress}); //required this.data

  void _updateProgress() {
    updateProgress(true);
  }
  @override
  _ChapterPageState createState() => _ChapterPageState();
}


class _ChapterPageState extends State<ChapterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String pageTitle;
  late Color pageColor;
  final DatabaseController _databaseController = Get.find<DatabaseController>();
  final HomePageController _homeController = Get.find<HomePageController>();
  DatamodelDto? data;

  void reloadData() {
    //_databaseController.getDatamodelWithLAnguage(widget.category.name, _homeController.currentLocale.value!.languageCode).then((result) {
    _homeController.fetchAllData().then((onValue) {
      if(onValue){
        setState(() {
          data = _homeController.careerData;
          log("In Chapter page data reload data: $data");
          widget._updateProgress();
        });
    }});
  }

  @override
  void initState() {
    super.initState();
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
        pageColor = Colors.grey;
        break;
    }
    //_databaseController.getDatamodelWithLAnguage(widget.category.name, _homeController.currentLocale.value!.languageCode).then((result) {
    _homeController.fetchAllData().then((onValue) {
      if(onValue){
        setState(() {
          data = _homeController.careerData;
          log("In Chapter page data: $data");
          widget._updateProgress();
        });
      }});
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                homePageController.changePage(0);  // You can change 0 to any other tab index if needed
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.black,
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
      body: data != null ? SingleChildScrollView( // Wrap the entire body in SingleChildScrollView
        child: Column(
          children: data!.chapters.map((chapter) {
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
                      // Nested ListView.builder for videos inside the ExpansionTile
                      VideoListPage(chapter: chapter, updateWatched: (bool value) { reloadData(); }),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}


class VideoListPage extends StatelessWidget {
  final ChapterDto chapter;
  final ValueSetter<bool> updateWatched;
  const VideoListPage({super.key,  required this.chapter, required this.updateWatched});

  void _onUpdate(){
    updateWatched(true);
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapter.videos.length,
      itemBuilder: (context, videoIndex) {
        VideoDto video = chapter.videos[videoIndex];
        bool hasTasks = video.tasks != null && video.tasks!.isNotEmpty;

        return ListTile(
          title: Text(video.title.tr),
          trailing: Icon(
            video.watched ? Icons.check_circle : Icons.circle_outlined,
            color: video.watched ? Colors.green : Colors.grey,
          ),
          onTap: () {
            // Navigate to the YouTube video when title is tapped
            _markVideoAsWatched(video);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => YoutubePage(
                  url: video.url,
                  tasks: video.tasks,
                  title: video.title.tr,
                  updateProgress: (bool value) {},
                ),
              ),
            );
          },
          subtitle: hasTasks
              ? ExpansionTile(
            title: Text("Tasks"),
            children: [
              // Show tasks when ExpansionTile is expanded
              TaskListPage(
                tasks: video.tasks!,
                updateWatched: (bool value) {
                  _onUpdate();
                },
              ),
            ],
          )
              : null,  // No tasks, so subtitle is null
        );
      },
    );
  }
  void _markVideoAsWatched(VideoDto video) async {
    final DatabaseController databaseController = Get.find<DatabaseController>();
    await databaseController.markVideoWatched(video.title);
    _onUpdate();
    video.watched = true;
  }
}

class TaskListPage extends StatelessWidget {
  final List<TaskDto> tasks;
  final ValueSetter<bool> updateWatched;
  const TaskListPage({super.key, required this.tasks, required this.updateWatched});

  void _onUpdate(){
    updateWatched(true);
  }
  void _markTaskAsWatched(TaskDto task) async {
    final DatabaseController databaseController = Get.find<DatabaseController>();
    await databaseController.markTaskWatched(task.title);
    _onUpdate();
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, taskIndex) {
        TaskDto task = tasks[taskIndex];
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
          title: Text(task.title.tr),
          trailing: Icon(
            task.watched ? Icons.check_circle : Icons.circle_outlined,
            color: task.watched ? Colors.green : Colors.grey,
          ),
          onTap: () {
            _markTaskAsWatched(task);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => YoutubePage(url: task.url, title: task.title.tr, tasks: null, updateProgress: (bool value){_markTaskAsWatched(task);},),
              ),
            );
          },
        );
      },
    );
  }

}