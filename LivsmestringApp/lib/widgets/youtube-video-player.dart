import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/models/video-db.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/DataModel.dart';
import '../models/task-db.dart';

class YoutubePage extends StatefulWidget {
  VideoDto? videoDto;
  final String url;
  final String title;
  final List<TaskDto>? tasks;
  final ValueSetter<bool> updateProgress;

  YoutubePage({
    super.key,
    this.videoDto,
    required this.url,
    required this.tasks,
    required this.title,
    required this.updateProgress,
  });

  @override
  State<StatefulWidget> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  final DatabaseController _databaseController = Get.find<DatabaseController>();


  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  late String videoId;
  final double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  //int? _watchTime;
  //int? _watchStartTime;
  Stopwatch _totalWatchTime = Stopwatch();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.url)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
    //_databaseController.updateTotalLength(_videoMetaData.duration, widget.url);
    _controller.addListener(_trackWatchTime);
  }

  void _trackWatchTime() {
    // Check if player state changed to playing
    if (_controller.value.playerState == PlayerState.playing && !_isPlaying) {
      _totalWatchTime.start();
      _isPlaying = true;
    }
  }

  void listener() {
    if (_isPlayerReady && mounted) { //!_controller.value.isFullScreen)
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
        if(_videoMetaData.duration.inSeconds > 0) {
          _databaseController.updateTotalLength(_videoMetaData.duration, widget.url);
          if(widget.videoDto != null){
            widget.videoDto?.totalLength =_videoMetaData.duration;
          }
        }
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    _totalWatchTime.stop();
    _databaseController.updateWatchTime(_totalWatchTime.elapsed, widget.url);
    if(widget.videoDto != null){
      widget.videoDto?.watchedLength = _totalWatchTime.elapsed;
    }
    log("in deactivare $_totalWatchTime");
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    _controller.removeListener(_trackWatchTime);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Youtube Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.amber,
            progressColors: ProgressBarColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
            onReady: () {
              _isPlayerReady = true;
              _controller.addListener(listener);
            },
          ),

          // Title under the video player
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title, // Use the passed title from the widget constructor
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // You can change the color if needed
              ),
              textAlign: TextAlign.center, // Centers the title
            ),
          ),

          // ListView if tasks are provided
          if (widget.tasks != null && widget.tasks!.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.tasks!.length,
              itemBuilder: (context, taskIndex) {
                final task = widget.tasks![taskIndex];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                  title: Text(task.title),
                  trailing: Icon(
                    task.watched ? Icons.check_circle : Icons.circle_outlined,
                    color: task.watched ? Colors.green : Colors.grey,
                  ),
                  onTap: () {
                    widget.updateProgress(true);  // Call updateProgress method here
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => YoutubePage(
                          url: task.url,
                          title: task.title,
                          tasks: null,
                          updateProgress: widget.updateProgress, // Pass the updateProgress function
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }


}
