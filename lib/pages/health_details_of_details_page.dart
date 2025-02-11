import 'package:flutter/material.dart';
import '../models/video_item_model.dart';
import '../widgets/list_button.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'video_player_page.dart';
import '../services/health_data.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../services/career_data.dart';
import '../widgets/loading_indicator.dart';
import 'package:get/get.dart';

class HealthDetailsOfDetailsPage extends StatefulWidget {
  final int index;
  final int prevIndex;
  final String appBarTittle;

  const HealthDetailsOfDetailsPage({
    super.key,
    required this.prevIndex,
    required this.index,
    required this.appBarTittle,
  });

  @override
  State<HealthDetailsOfDetailsPage> createState() => _HealthDetailsOfDetailsPageState();
}

class _HealthDetailsOfDetailsPageState extends State<HealthDetailsOfDetailsPage> {
  int activeItem = -1; // Initialize activeItem to -1
  late String title;
  late List<String> videoUrlList;
  late List<String> fetchedItems;
  late List<VideoItem> nextVideosList;
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
        title:  AutoSizeText(
          widget.appBarTittle,
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
      ):
      nextVideosList.isEmpty ?
      Center(
        child: Text(
          'videos_not_added'.tr,
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: fetchedItems.length,
              itemBuilder: (context, index) {
                return ListButton(
                  content: fetchedItems[index],
                //    buttonsLength: fetchedItems.length,
                  active: activeItem == index ? true : false, // Adjust active condition
                  activeColor:
                  AppColors.spaceCadetComplementary,
                  inactiveColor:
                  AppColors.spindle,
                  onPressed: () {
                    setState(() {
                      activeItem =
                          index; // Update activeItem without subtracting 1
                      /*
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerPage(
                              isCareer: false,
                              item: VideoItem(title: fetchedItems[index], url: videoUrlList[index], nextItem: nextVideosList[index]),
                              // Adjust index
                              title: fetchedItems[index],
                              appBarTitle:  title,
                            ),
                      ));

                       */
                    });
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initializeLists() async {

    /*
    List<String> result = getHealthSubModulesVideosTittle(widget.prevIndex, widget.index);
    String titleNotTranslated =  getHealthSubModuleTittles(widget.prevIndex, "Not_Translate")[widget.index];
    String titleResult = getHealthSubModuleTittles(widget.prevIndex, "")[widget.index];

    setState(() {
      fetchedItems = result;
      title = titleResult;

      getVideoUrlsHealth(titleNotTranslated).then((videoUrls){
        setState(() {
          videoUrlList = videoUrls;

          nextVideoItems(videoUrls, fetchedItems).then((nextVideos){
            setState(() {
              nextVideosList = nextVideos;
              setState(() {
                isLoading = false;
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

