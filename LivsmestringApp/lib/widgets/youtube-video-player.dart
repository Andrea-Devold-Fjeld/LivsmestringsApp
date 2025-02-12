

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePage extends StatefulWidget {
  final String url;
  const YoutubePage({super.key, required this.url});

  @override
  State<StatefulWidget> createState() => _YoutubePageState();

}


class _YoutubePageState extends State<YoutubePage> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  late String VideoId;
  final double _volume = 100;
  final bool _muted = false;
  final bool _isPlayerReady = false;


  @override
  void initState() {
    super.initState();
    VideoId = YoutubePlayer.convertUrlToId(widget.url)!;
    _controller = YoutubePlayerController(
      initialVideoId: VideoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )
      ..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }


  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          progressColors: ProgressBarColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent
          ),
          onReady: () {
            _controller.addListener(listener);
          },),
      ),
    );
  }
}