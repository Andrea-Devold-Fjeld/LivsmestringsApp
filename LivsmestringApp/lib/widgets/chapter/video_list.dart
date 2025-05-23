
import 'package:flutter/material.dart';
import 'package:livsmestringapp/widgets/chapter/video_tile.dart';

import '../../dto/chapter_dto.dart';
import '../../dto/video_dto.dart';

class VideoList extends StatelessWidget {
  final ChapterDto chapter;
  final ValueSetter<bool> updateWatched;

  const VideoList(
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
          if(chapter.videos.isEmpty){
            return Text("No Videos Here!");
          }
          VideoDto video = chapter.videos[videoIndex];
          double progress = video.getVideoProgress();

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
          );
        });
  }
}