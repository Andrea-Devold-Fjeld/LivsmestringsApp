import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../widgets/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/career_data.dart';
import '../services/health_data.dart';
import '../widgets/homepage_card.dart';
import '../styles/colors.dart';
import 'career_page_new.dart';
import 'health_page_new.dart';


import 'package:get/get.dart';



class HomePage extends StatefulWidget {

  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double careerProgress;
  late double healthProgress = 0.0;
  late SharedPreferences prefs;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: isLoading ? const Center(
        child: LoadingIndicator(),
      ) :Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              'assets/logo_black.png',
              width: 300,
            ),
          ),
          HomePageCard(
            progress: careerProgress.isFinite ? careerProgress : 0.0,
            backgroundColor: AppColors.weakedGreen,
            title: 'career'.tr,
            icon: Icon(
              Icons.work,
              size: 40,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CareerPageNew(
                  isCareer: true,
                ),
              ));
            },
          ),
          HomePageCard(
            progress: healthProgress,
            backgroundColor: AppColors.spaceCadet,
            title: 'health'.tr,
            icon: Icon(
              Icons.local_hospital,
              size: 40,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HealthPageNew(),
              ));
            },
          ),
        ],
      ),
    );
  }

  Future<void> getProgress() async {
    Completer<void> completer = Completer<void>();

    getCareerProgress().then((result) {
      setState(() {
        careerProgress = result;

        getHealthProgress().then((result) {
          setState(() {
            healthProgress = result;
            setState(() {
              isLoading = false;
            });
            completer.complete(); // Complete the Future when both progress are fetched successfully
          });
        }).catchError((onError) {
          print("This is error in getHealthProgress(): $onError");
          completer.completeError(onError); // Complete the Future with error
        });
      });
    }).catchError((onError) {
      print("This is error in getCareerProgress(): $onError");
      completer.completeError(onError); // Complete the Future with error
    });

    return completer.future; // Return the Future
  }

}
