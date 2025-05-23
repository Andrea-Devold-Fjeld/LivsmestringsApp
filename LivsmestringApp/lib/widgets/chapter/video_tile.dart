import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/widgets/chapter/task_list.dart';

import '../../dto/video_dto.dart';
import '../video_player/youtube-video-player.dart';

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
    final hasTasks = video.tasks.isNotEmpty;
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
            child: TaskList(
              tasks: video.tasks!,
              updateWatched: (bool value) {
                widget.onUpdate();
              },
            ),
          ),
      ],
    );
  }
}