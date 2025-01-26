import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/pages/video_player_page.dart';

import '../models/video_item_model.dart';
import '../services/career_data.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../widgets/list_button.dart';
import '../widgets/loading_indicator.dart';


/*
import 'package:livsmestringapp/models';
import 'package:livsmestringsapp/models/video_item_model.dart';
import 'package:livsmestringsapp/widgets/list_button.dart';
import 'package:livsmestringsapp/styles/colors.dart';
import 'package:livsmestringsapp/styles/fonts.dart';
import 'package:livsmestringsapp/pages/video_player_page.dart';
import 'package:livsmestringsapp/services/career_data.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:livsmestringsapp/widgets/loading_indicator.dart';
import 'package:get/get.dart';

 */


class CarrerDetailesPage extends StatefulWidget {
  bool isCareer;
  final int index;

  CarrerDetailesPage({super.key, required this.index,
    required this.isCareer,
  });

  @override
  State<CarrerDetailesPage> createState() => _CarrerDetailesPageState();
}

class _CarrerDetailesPageState extends State<CarrerDetailesPage> {
  late List<String> fetchedItems;
  List<String> videoUrls = [];
  late List<VideoItem> nextVideo;
  late bool isLoading = true;
  int activeItem = -1; // Initialize activeItem to -1

  @override
  void initState() {
    super.initState();
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
        title: AutoSizeText(
          getCareerModulesTittles("")[widget.index],
          style: Fonts.homePageCardLabel,

          minFontSize: 10, // Set the minimum font size
          maxFontSize: 18, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor: widget.isCareer
            ? AppColors.weakedGreen
            : AppColors.spaceCadet,
      ),
      body: isLoading ? const Center(
        child: LoadingIndicator(),
      ): nextVideo.isEmpty ?
      Center(
        child: Text(
          'videos_not_added'.tr,
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: fetchedItems.length,
              itemBuilder: (context, index) {
                return ListButton(
                  content:  fetchedItems[index],
                //  buttonsLength: fetchedItems.length,
                  active: activeItem == index ? true : false, // Adjust active condition
                  activeColor: AppColors.weakedGreenComplementary,
                  inactiveColor: AppColors.GreenLeave,
                  onPressed: () {
                    setState(() {
                      activeItem = index; // Update activeItem without subtracting 1
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          isCareer: widget.isCareer,
                          item: VideoItem(title: fetchedItems[index], url: videoUrls[index], nextItem: nextVideo[index]), // Adjust index
                          title: fetchedItems[index],
                          appBarTitle: getCareerModulesTittles("")[widget.index],
                        ),
                      ));
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initializeLists() async{
    setState(() {
      isLoading = true;
    });

    List<String> oneUntranslatedTitle = getCareerModulesVideosTittle(widget.index, "Not_Translate");

    fetchedItems = getCareerModulesVideosTittle(widget.index, "");
    print("This is fetched items: $fetchedItems");

    print("This is oneUntranslatedTitle: $oneUntranslatedTitle");

    getVideoUrlsCareer(oneUntranslatedTitle).then((urls) {
      setState(() {
        videoUrls = urls;

        nextVideoItems(videoUrls, fetchedItems).then((nextVideos){
          setState(() {
            nextVideo = nextVideos;
            isLoading = false;
          });
        }).catchError((error) {
          setState(() {
            print("This is the error in nextVideoItems: $error");
          });
        });

      });
    }).catchError((error) {
      setState(() {
        print("This is the error in getVideoUrls: $error");
      });
    });
  }
}
