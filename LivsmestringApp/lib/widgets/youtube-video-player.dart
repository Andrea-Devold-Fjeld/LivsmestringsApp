import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/models/video-db.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/DataModel.dart';
import '../models/DataModelDTO.dart';
import '../models/task-db.dart';

/*
he overflowing RenderFlex has an orientation of Axis.vertical.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and black striped pattern. This is usually caused by the contents being too big for the RenderFlex.

Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be seen. If the content is legitimately bigger than the available space, consider clipping it with a ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex, like a ListView.
 */
class YoutubePage extends StatefulWidget {
  VideoDto? videoDto;
  final String url;
  final String title;
  final List<TaskDto>? tasks;
  final ValueSetter<Duration> updateProgress;

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
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  Stopwatch _totalWatchTime = Stopwatch();
  bool _isPlaying = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    int startTime = widget.videoDto?.watchedLength?.inSeconds ?? 0;
    videoId = YoutubePlayer.convertUrlToId(widget.url)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        startAt: startTime,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
    _controller.addListener(_trackWatchTime);
  }

  void _trackWatchTime() {
    // Check if player state changed to playing
    if (_controller.value.playerState == PlayerState.playing && !_isPlaying) {
      _totalWatchTime.start();
      _isPlaying = true;
    }
    if(_controller.value.playerState != PlayerState.playing) {
      _totalWatchTime.stop();
      _isPlaying = false;
    }
  }

  void listener() {
    if (_isPlayerReady && mounted) {
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
    Duration currentPosition = _controller.value.position;
    _databaseController.updateWatchTime(currentPosition, widget.url);
    //This is to update the value instantaneous
    if(widget.videoDto != null){
      widget.videoDto?.watchedLength = currentPosition;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    _controller.removeListener(_trackWatchTime);
    widget.updateProgress(_controller.value.position);
    super.dispose();
  }

  void _skipForward() {
    final currentPosition = _controller.value.position.inSeconds;
    final newPosition = currentPosition + 10; // Skip forward 10 seconds
    _controller.seekTo(Duration(seconds: newPosition));
  }

  void _skipBackward() {
    final currentPosition = _controller.value.position.inSeconds;
    final newPosition = currentPosition - 10; // Skip backward 10 seconds
    if (newPosition < 0) {
      _controller.seekTo(const Duration(seconds: 0));
    } else {
      _controller.seekTo(Duration(seconds: newPosition));
    }
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      // Exit fullscreen
      _controller.toggleFullScreenMode();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      // Enter fullscreen
      _controller.toggleFullScreenMode();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Volume:'),
                      Expanded(
                        child: Slider(
                          value: _volume,
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setModalState(() {
                              _volume = value;
                              _controller.setVolume(_volume.toInt());
                            });
                          },
                        ),
                      ),
                      Text('${_volume.toInt()}%'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Mute:'),
                      Switch(
                        value: _muted,
                        onChanged: (value) {
                          setModalState(() {
                            _muted = value;
                            _controller.setVolume(_muted ? 0 : _volume.toInt());
                          });
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    title: const Text('Playback Speed'),
                    trailing: DropdownButton<double>(
                      value: _controller.value.playbackRate,
                      items: const [
                        DropdownMenuItem(value: 0.25, child: Text('0.25x')),
                        DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                        DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                        DropdownMenuItem(value: 1.0, child: Text('Normal')),
                        DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                        DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                        DropdownMenuItem(value: 1.75, child: Text('1.75x')),
                        DropdownMenuItem(value: 2.0, child: Text('2x')),
                      ],
                      onChanged: (double? value) {
                        if (value != null) {
                          _controller.setPlaybackRate(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  /*
                  ListTile(
                    title: const Text('Captions'),
                    trailing: Switch(
                      value: _controller.value.flags.enableCaption,
                      onChanged: (value) {
                        _controller..toggleCaptions();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  */
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
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
            progressColors: const ProgressBarColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
            onReady: () {
              _isPlayerReady = true;
              _controller.addListener(listener);
            },
            topActions: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    _controller.metadata.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
            bottomActions: [
              CurrentPosition(),
              ProgressBar(isExpanded: true,),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: _showSettingsDialog,
              ),
              IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleFullScreen,
              ),
            ],
          ),

          // Title under the video player
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title, // Use the passed title from the widget constructor
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // You can change the color if needed
              ),
              textAlign: TextAlign.center, // Centers the title
            ),
          ),

          // ListView if tasks are provided
          if (widget.tasks != null && widget.tasks!.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.tasks!.length,
                itemBuilder: (context, taskIndex) {
                  final task = widget.tasks![taskIndex];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                    title: Text(task.title.tr),
                    trailing: Icon(
                      task.watched ? Icons.check_circle : Icons.circle_outlined,
                      color: task.watched ? Colors.green : Colors.grey,
                    ),
                    onTap: () {
                      widget.updateProgress(_totalWatchTime.elapsed);  // Call updateProgress method here
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
            ),
          ],
        ],
      ),
    );
  }
}