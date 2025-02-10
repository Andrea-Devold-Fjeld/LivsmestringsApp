import 'package:flutter/material.dart';
import 'package:livsmestringapp/pages/career-tabs-page.dart';
import '../models/DataModel.dart';
import '../widgets/homepage_card.dart';
import '../styles/colors.dart';
import 'career_page_new.dart';
import 'health_page_new.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  final Map<String, Datamodel> data;
  const HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
      Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[ // Added explicit type here
              Image.asset(
                'assets/logo_black.png',
                width: 300,
              ),
              HomePageCard(
                key: const ValueKey('career'), // Added key for better widget identification
                progress: _calculateProgress(widget.data['career']),
                backgroundColor: AppColors.weakedGreen,
                title: 'career'.tr,
                icon: Icon(
                  Icons.work,
                  size: 40,
                  color: AppColors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CareerTabsPage(data: widget.data["career"]!)
                    //CareerPageNew(isCareer: true, data: widget.data['career']!,),
                  ));
                },
              ),
              HomePageCard(
                key: const ValueKey('health'), // Added key for better widget identification
                progress: _calculateProgress(widget.data['health']),
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
          ));
        }
  }


  double _calculateProgress(Datamodel? data) {
    if (data == null) return 0.0;
    return 0.0;
    // Implement your progress calculation logic here based on your Datamodel
    //return data.progress ?? 0.0;
  }


