import 'package:flutter/material.dart';
import 'package:livsmestringapp/widgets/youtube-video-player.dart';

import '../models/DataModel.dart';
import '../services/career_data.dart';
import '../styles/colors.dart';

class CareerTabsPage extends StatefulWidget {
  final Datamodel data;

  CareerTabsPage({required this.data});

  @override
  _CareerTabsPageState createState() => _CareerTabsPageState();
}

class _CareerTabsPageState extends State<CareerTabsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Datamodel careerData;

  @override
  void initState() {
    super.initState();
    careerData = findAndReplaceAndTranslate(widget.data);
    _tabController = TabController(length: careerData.chapters.length, vsync: this);
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
        title: Text("Career"),
        leading: Row(
          children: [
            IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 30,
            ))
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: careerData.chapters
              .map((chapter) => Tab(text: chapter.title))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: careerData.chapters.map((chapter) {
          return VideoListPage(videos: chapter.videos);
        }).toList(),
      ),
    );
  }
}

class VideoListPage extends StatelessWidget {
  final List<Video> videos;

  VideoListPage({required this.videos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return ListTile(
          title: Text(video.title),
          subtitle: Text(video.url),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => YoutubePage(url: video.url),
              ),
            );          },
        );
      },
    );
  }
}