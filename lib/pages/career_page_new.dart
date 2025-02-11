import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/DataModel.dart';
import '../services/career_data.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../models/video_item_model.dart';
import 'video_player_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/loading_indicator.dart';

class CareerPageNew extends StatefulWidget {
  final bool isCareer;
  final Datamodel data;

  const CareerPageNew({super.key,
        required this.isCareer,
        required this.data
  });

  @override
  State<CareerPageNew> createState() => _CareerPageNewState();
}

class _CareerPageNewState extends State<CareerPageNew> {
  late List<String> careerItems;
  late List<String> fetchedItems;
  late List<String> videoUrls;
  late List<List<String>> videoUrlsMap;
  late List<VideoItem> nextVideo;
  late List<List<VideoItem>> nextVideoMap;
  late List<List<bool>> haveSeenVideo;
  late bool isLoading = true;
  List<int> expandedIndices = []; // Maintain a list of expanded indices
  int selectedIndex = 0;
  late Datamodel careerData;

  @override
  void initState() {
    super.initState();
    careerItems = getCareerModulesTitles("", widget.data);
    careerData = findAndReplaceAndTranslate(widget.data);
    print("careerItems: $careerItems");
    initializeLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
/*
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
          widget.isCareer ? 'career'.tr : 'health'.tr,
          style: Fonts.homePageCardLabel,

          minFontSize: 10, // Set the minimum font size
          maxFontSize: 20, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor:
        widget.isCareer ? AppColors.weakedGreen : AppColors.spaceCadet,
      ),
      body: isLoading
          ? const Center(
        child: LoadingIndicator(),
      ) : nextVideo.isEmpty ?
          Center(
            child: Text(
              'videos_not_added'.tr,
            ),
          )
          :  ListView.builder(
        itemCount: careerItems.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey), // Add border
              borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius
            ),
            margin: EdgeInsets.all(8.0), // Optional: Add margin
            child: ExpansionTile(
              title:  AutoSizeText(
                careerItems[index],
                style: TextStyle(
                  // fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 15, // Set the minimum font size
                maxFontSize: 15, // Set the maximum font size
                maxLines: 4,
              ),
              textColor: Colors.purple[600],
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ...getCareerModulesVideosTittle(index, "", widget.data).asMap().entries.map(
                            (entry) {
                          final int subIndex = entry.key;
                          final String item = entry.value;

                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    item,
                                    style: TextStyle(
                                      //  fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900]
                                    ),
                                    minFontSize: 14, // Set the minimum font size
                                    maxFontSize: 14, // Set the maximum font size
                                    maxLines: 4,
                                  ),
                                ),
                                if (haveSeenVideo[index][subIndex] == true)
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerPage(
                                    isCareer: widget.isCareer,
                                    item: VideoItem(
                                      title: item,
                                      url: videoUrlsMap[index][subIndex],
                                      nextItem: nextVideoMap[index][subIndex],
                                    ),
                                    title: item,
                                    appBarTitle: careerItems[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

 */
    ));


  }

  Future<void> initializeLists() async{

    /*
    setState(() {
      isLoading = true;
    });



    List<String> items = await groupAndTranslateWithoutHeadlinesCareer();
    print("This is items: $items");

    getAllVideoUrls().then((urls) {
      setState(() {
        videoUrls = urls;

        nextVideoItems(videoUrls, items).then((nextVideos){
          setState(() {
            nextVideo = nextVideos;

            nextVideoItemsNested(nextVideo, careerItems, widget.data).then((nextVideosMapped){
              setState(() {
                nextVideoMap = nextVideosMapped;

                getAllVideoUrlsNested(nextVideoMap, videoUrls).then( (urlsMapped){
                  setState(() {
                    videoUrlsMap = urlsMapped;

                    getDataAboutUserHaveSeenVideos(careerItems, widget.data).then((haveUserSeenVideos) {
                      setState(() {

                        haveSeenVideo = haveUserSeenVideos;
                        print("This is haveSeenVideo: $haveSeenVideo");
                        isLoading = false;
                      });
                    }).catchError((error) {
                      setState(() {
                        print("This is the error in getDataAboutUserHaveSeenVideos(): $error");
                      });
                    });

                  });
                }).catchError((onError){
                  setState(() {
                    print("This is the error in getAllVideoUrlsMapped(): $onError");
                  });
                });

            });
            }).catchError((error) {
              setState(() {
                print("This is the error in nextVideoItemsMap(): $error");
              });
            });
          });
        }).catchError((error) {
          setState(() {
            print("This is the error in nextVideoItems(): $error");
          });
        });

      });
    }).catchError((error) {
      setState(() {
        print("This is the error in getVideoUrls(): $error");
      });
    });
    */
  }


}
