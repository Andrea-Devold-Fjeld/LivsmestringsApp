
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/widgets/youtube-video-player.dart';

import '../controllers/database-controller.dart';
import '../models/DataModel.dart';
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


class ChapterPageNav extends StatefulWidget {
  final CategoryDTO category;

  const ChapterPageNav({super.key, required this.category}); //required this.data

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Datamodel? data;
  late String pageTitle;
  late Color pageColor;
  final DatabaseController _databaseController = Get.find<DatabaseController>();

  void reloadData() {
    _databaseController.getDatamodel(widget.category.name).then((result) {
      setState(() {
        data = result;
        widget._updateProgress();
      });
    });
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
    _databaseController.getDatamodel(widget.category.name).then((result) {
      setState(() {
        data = result;
        _tabController = TabController(length: data!.chapters.length, vsync: this);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
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
          pageTitle,
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
                      chapter.title,
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
  final Chapter chapter;
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
        Video video = chapter.videos[videoIndex];
        return ListTile(
          title: Text(video.title),
          subtitle: Text(video.url),
          trailing: Icon(
            video.watched ? Icons.check_circle : Icons
                .circle_outlined,
            color: video.watched ? Colors.green : Colors.grey,
          ),
          onTap: () {
            _markVideoAsWatched(video);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    YoutubePage(url: video.url),
              ),
            );
          },
        );
      },
    );
  }


  void _markVideoAsWatched(Video video) async {
    final DatabaseController databaseController = Get.find<DatabaseController>();
    await databaseController.markVideoWatched(video.title);
    _onUpdate();
    video.watched = true;
  }
}