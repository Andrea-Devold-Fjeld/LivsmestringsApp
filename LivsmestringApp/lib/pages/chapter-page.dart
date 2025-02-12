
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:livsmestringapp/models/CategoryEnum.dart';
import 'package:livsmestringapp/widgets/youtube-video-player.dart';

import '../models/DataModel.dart';
import '../services/data.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';

class ChapterPage extends StatefulWidget {
  final Datamodel data;
  final Category category;


  const ChapterPage({super.key, required this.data, required this.category});

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Datamodel data;
  late String pageTitle;
  late Color pageColor;

  @override
  void initState() {
    super.initState();
    switch (widget.category){
      case Category.carreer:
        pageTitle = "Career";
        pageColor = AppColors.weakedGreen;
      case Category.health:
        pageTitle = "Health";
        pageColor = AppColors.spaceCadet;
      }
    data = findAndReplaceAndTranslate(widget.data);
    _tabController = TabController(length: data.chapters.length, vsync: this);
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
      body: SingleChildScrollView( // Wrap the entire body in SingleChildScrollView
        child: Column(
          children: data.chapters.map((chapter) {
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
                      VideoListPage(chapter: chapter),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class VideoListPage extends StatelessWidget {
  final Chapter chapter;

  const VideoListPage({super.key,  required this.chapter});

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
            video.watched = true;
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
}