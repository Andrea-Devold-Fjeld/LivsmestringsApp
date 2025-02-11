import 'dart:async';

import 'package:flutter/material.dart';
import 'video_player_page.dart';
import '../services/health_data.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/loading_indicator.dart';
import 'package:get/get.dart';
import '../models/video_item_model.dart';
import '../services/career_data.dart';


class HealthDetailsPageNew extends StatefulWidget {
  final int moduleIndex;
  final String subModuleTittle;
  final List<String> subModulesTittles;
  final String moduleTittle;

  const HealthDetailsPageNew({
    super.key,
    required this.subModuleTittle,
    required this.moduleTittle,
    required this.moduleIndex,
    required this.subModulesTittles,
  });

  @override
  State<HealthDetailsPageNew> createState() => _HealthDetailsPageNewState();
}

class _HealthDetailsPageNewState extends State<HealthDetailsPageNew> {
  late List<String> healthItemIndexList;
  late List<String> healthItemIndexListNotTranslated;
  late List<String> videoUrlList;
  late List<VideoItem> nextVideosList;
  late List<bool> haveSeenVideo;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initializeLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        /*
        title: AutoSizeText(
          getHealthModulesTittles()[widget.moduleIndex],
          style: Fonts.homePageCardLabel,
          minFontSize: 10, // Set the minimum font size
          maxFontSize: 18, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor: AppColors.spaceCadet,
      ),
      body: isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : nextVideosList.isEmpty ?
      Center(
        child: Text(
          'videos_not_added'.tr,
        ),
      )
          : ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: AutoSizeText(
                widget.subModuleTittle,
                style: TextStyle(
             //     fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 15, // Set the minimum font size
                maxFontSize: 15, // Set the maximum font size
                maxLines: 4,
              ),
              textColor: Colors.purple[600],
              children: _buildExpansionChildren(healthItemIndexList),
            ),
          );
        },

         */
      ),
    );
  }

  List<Widget> _buildExpansionChildren(List<String> translatedItems) {
    List<Widget> expansionChildren = [];

    for (int i = 0; i < translatedItems.length; i++) {

      ListTile listItem = ListTile(
        title: Row(
          children: [
            Expanded(child:
              AutoSizeText(
                translatedItems[i],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
                minFontSize: 14,
                maxFontSize: 14,
                maxLines: 4,
              ),
            ),
            if (haveSeenVideo[i] == true)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.check,
                  color: Colors.green[900],
                ),
              ),
          ],
        ),
        onTap: () {
          /*
          Navigator.of(context).push(
            MaterialPageRoute(

              builder: (context) => VideoPlayerPage(
                isCareer: false,
                item: VideoItem(
                  title: translatedItems[i],
                  url: videoUrlList[i],
                  nextItem: nextVideosList[i],
                ),
                title: translatedItems[i],
                appBarTitle: widget.subModuleTittle,
              ),
            ),
          );

           */
        },
      );

      expansionChildren.add(listItem);
    }

    return expansionChildren;
  }

  Future<void> initializeLists() async {
    /*
    List<String> result = getSubModuleIndexAndVideosTittle(
      getHealthSubModuleTittles(widget.moduleIndex, ""),
      widget.subModuleTittle,
      widget.moduleIndex,
    );

    List<String> resultUntranslated =  getHealthSubModuleTittles(widget.moduleIndex, "Not_Translate");

    setState(() {
      healthItemIndexList = result;
      healthItemIndexListNotTranslated = resultUntranslated;
      String notTranslatedHeading = getHeadlineNotTranslatedHealth(widget.subModulesTittles, widget.subModuleTittle, healthItemIndexListNotTranslated);
      print("This is notTranslateHeading: $notTranslatedHeading");
      getVideoUrlsHealth(notTranslatedHeading).then((videoUrls){
        setState(() {
          videoUrlList = videoUrls;

          nextVideoItems(videoUrls, healthItemIndexList).then((nextVideos){
            setState(() {
              nextVideosList = nextVideos;
              setState(() {

                getDataAboutUserHaveSeenVideosHealth(healthItemIndexList).then((haveUserSeenVideos) {
                  setState(() {
                    haveSeenVideo = haveUserSeenVideos;
                    isLoading = false;
                  });
                }).catchError((onError){
                  setState(() {
                    print("This is the error in getDataAboutUserHaveSeenVideosHealth(): $onError");
                  });
                });
              });
            });
          }).catchError((error) {
            setState(() {
              print("This is the error in nextVideoItems: $error");
            });
          });
        });
      }).catchError((onError){
        setState(() {
          print("This is error in  getVideoUrlsHealth(): $onError");
        });
      });
    });

     */
  }
}
