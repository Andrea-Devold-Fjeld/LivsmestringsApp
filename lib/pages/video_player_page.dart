import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/widgets.dart';
import '../models/video_item_model.dart';
import '../services/career_data.dart';
import '../services/health_data.dart';
import '../widgets/language_button.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../widgets/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';



class VideoPlayerPage extends StatefulWidget {
  final bool isCareer;
  final String title;
  final VideoItem item;
  final String? appBarTitle;

  const VideoPlayerPage({
    Key? key,
    required this.item,
    required this.isCareer,
    required this.title,
    required this.appBarTitle
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late CustomVideoPlayerController _customVideoPlayerController;
  late bool isLoading = true;
  late Duration initialDuration = Duration.zero;
  late SharedPreferences prefs;
  late CachedVideoPlayerPlusController controller;

  @override
  void initState() {
    super.initState();
    //May have to add is loading
    controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.item.url),
      invalidateCacheIfOlderThan: const Duration(days: 69),
    )..initialize().then((value) async {
      controller.play();
      setState(() {});
    });
    //initializeVideoPlayer();
  }

  @override
  void dispose(){
    print("On dispose called");
    Duration currentDuration = _customVideoPlayerController.videoPlayerController.value.position;
    //The user have watched some video:
    if(currentDuration != initialDuration){
      String title = widget.item.title;
      prefs.setBool(title, true);
      print("Watched, set the boolean: $title");
    }
    else{
      print("not Watched");
      //The user did not watch the video:
    }
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.item.title;
    String? nextTitle = widget.item.nextItem?.title;
    print("Dette er title: $title, og nextTitle: $nextTitle");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        title: AutoSizeText(
          widget.isCareer ? getVideoPlayerCareerAppBarTittle(widget.item.title) :
          getVideoPlayerHealthAppBarTittle(widget.item.title),
          style: Fonts.homePageCardLabel,
          minFontSize: 10, // Set the minimum font size
          maxFontSize: 18, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor:
        widget.isCareer ? AppColors.weakedGreen : AppColors.spaceCadet,
      ),
      body: isLoading ? const Center(
        child: LoadingIndicator(),
      ) : Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController),
            Flexible(
              child: AutoSizeText(
                widget.item.title,
                style: Fonts.header3,
                textAlign: TextAlign.center,
                minFontSize: 15, // Set the minimum font size
                maxFontSize: 15, // Set the maximum font size
                maxLines: 4,
              ),
            ),
            if (widget.item.nextItem?.title != '')
              Expanded(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   AutoSizeText(
                    'next_video'.tr,
                    style: Fonts.header3,
                    textAlign: TextAlign.center,
                     minFontSize: 15, // Set the minimum font size
                     maxFontSize: 15, // Set the maximum font size
                     maxLines: 4,
                  ),
                  LanguageButton(
                    language: widget.item.nextItem!.title,
                    active: widget.isCareer,
                    onPressed: () =>
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerPage(
                                  item: widget.item.nextItem!,
                                  isCareer: widget.isCareer,
                                  title: widget.title,
                                  appBarTitle: widget.isCareer ?
                                  getVideoPlayerCareerAppBarTittle(widget.item.nextItem!.title) :
                                  getVideoPlayerHealthAppBarTittle(widget.item.nextItem!.title),
                                ),
                          ),
                        ),
                  ),
                ],
              ),
              )
          ],
        ),
      ),
    );
  }

/*
  Future<void> initializeVideoPlayer() async{
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();

    _cachedVideoPlayerPlusController = CachedVideoPlayerPlusController.network(widget.item.url)
      ..initialize().then((_) {
        setState(() {
          // Add a listener to track video playback progress
          isLoading = false;
        });
      });
    _customVideoPlayerController
     = CustomVideoPlayerController(
     context: context, videoPlayerController: _cachedVideoPlayerController);

  }
 */
}

