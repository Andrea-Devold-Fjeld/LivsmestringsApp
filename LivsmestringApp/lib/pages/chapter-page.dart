
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
  //late TabController _tabController;
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
        pageColor = Colors.grey[800]!;
        break;
    }
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
    //_tabController.dispose();
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
                homePageController.changePage(0);
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

class VideoTile extends StatefulWidget {
  final VideoDto video;
  final Function() onUpdate;

  const VideoTile({
    required this.video,
    required this.onUpdate,
    super.key,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}
class _VideoTileState extends State<VideoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final hasTasks = video.tasks != null && video.tasks!.isNotEmpty;
    final progress = video.getVideoProgress();
    final isComplete = progress >= 0.95 || video.watched;

    return Column(
      children: [
        ListTile(
          title: Text(video.title.tr),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasTasks) const SizedBox(width: 8),
              if (hasTasks)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              isComplete
                  ? Icon(
                video.watched ? Icons.check_circle : Icons.circle_outlined,
                color: video.watched ? Colors.green : Colors.grey,
              )
                  : SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                  strokeWidth: 2.5,
                ),
              ),

            ],
          ),
          onTap: () {
            // Navigate to video
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => YoutubePage(
                  url: video.url,
                  tasks: video.tasks,
                  title: video.title.tr,
                  updateProgress: (Duration value) {
                    widget.onUpdate();
                  },
                  videoDto: video,
                ),
              ),
            );
          },
        ),
        if (_expanded && hasTasks)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: TaskListPage(
              tasks: video.tasks!,
              updateWatched: (bool value) {
                widget.onUpdate();
              },
            ),
          ),
    //const SizedBox(height: 8), // Instead of just Divider
    //Divider(thickness: 1, height: 1),
    //const SizedBox(height: 8),

      ],
    );
  }
}
class VideoListPage extends StatelessWidget {
  final ChapterDto chapter;
  final ValueSetter<bool> updateWatched;

  const VideoListPage(
      {super.key, required this.chapter, required this.updateWatched});

  void _onUpdate() {
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
        double progress = video.getVideoProgress();
        bool isComplete = progress >= 0.95 || video.watched;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: VideoTile(
            video: chapter.videos[videoIndex],
            onUpdate: _onUpdate,
          ),
        );});}}
          /*ExpansionTile(
          title: Text(video.title.tr),
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // So the row doesn't take full width
            children: [
              // Check mark or progress indicator
              isComplete
                  ? Icon(
                video.watched ? Icons.check_circle : Icons.circle_outlined,
                color: video.watched ? Colors.green : Colors.grey,
              )
                  : SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                  strokeWidth: 2.5,
                ),
              ),

              // Optional spacing between icons
              if (hasTasks) const SizedBox(width: 8),

              // Task icon or arrow if there are tasks
              if (hasTasks)
                const Icon(
                  Icons.chevron_right, // or use Icons.assignment / Icons.task_alt
                  color: Colors.grey,
                  size: 20,
                ),
            ],
          ),
          /*? Icon(
            video.watched ? Icons.check_circle : Icons.circle_outlined,
            color: video.watched ? Colors.green : Colors.grey,
          )
              : SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation(Colors.green),
              strokeWidth: 2.5,
            ),
          ),*/
          onExpansionChanged: (isExpanded) {
            if (isExpanded) {
              // Optional logic on expand
            }
          },
          children: [
            ListTile(
              title: Text("Watch Video"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        YoutubePage(
                          url: video.url,
                          tasks: video.tasks,
                          title: video.title.tr,
                          updateProgress: (Duration value) {
                            _onUpdate();
                          },
                          videoDto: video,
                        ),
                  ),
                );
              },
            ),
            if (hasTasks)
              ExpansionTile(
                title: Text("Tasks"),
                children: [
                  TaskListPage(
                    tasks: video.tasks!,
                    updateWatched: (bool value) {
                      _onUpdate();
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
*/
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
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, taskIndex) {
        TaskDto task = tasks[taskIndex];
        return ListTile(
          dense: true,
          //contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
          title: Text(task.title.tr),
          trailing: Icon(
            task.watched ? Icons.check_circle : Icons.circle_outlined,
            color: task.watched ? Colors.green : Colors.grey,
          ),
          onTap: () {
            _markTaskAsWatched(task);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => YoutubePage(url: task.url, title: task.title.tr, tasks: null, updateProgress: (Duration value){_markTaskAsWatched(task);},),
              ),
            );
          },
        );
      },
    ),);
  }

}