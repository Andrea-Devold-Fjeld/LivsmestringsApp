import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';

import '../models/CategoryEnum.dart';
import '../models/DataModel.dart';
import '../styles/colors.dart';
import '../widgets/homepage_card.dart';

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
              // Iterating over each entry in the data map
              ...widget.data.entries.map((entry) {
                String key = entry.key;
                var value = entry.value;

                // Determine the appropriate title and icon based on the key
                String title = key.tr;
                Icon icon;
                Widget targetPage;

                switch (key) {
                  case 'career':
                    icon = Icon(
                      Icons.work,
                      size: 40,
                      color: AppColors.white,
                    );
                    targetPage = ChapterPage(data: widget.data["career"]!, category: Category.carreer);
                break;
                  case 'health':
                    icon = Icon(
                      Icons.local_hospital,
                      size: 40,
                      color: AppColors.white,
                    );
                    targetPage = ChapterPage(data: widget.data["health"]!, category: Category.health);
                    break;
                  default:
                    icon = Icon(
                      Icons.help,
                      size: 40,
                      color: AppColors.white,
                    );
                    targetPage = Container(); // Default empty container
                    break;
                }

                return HomePageCard(
                  key: ValueKey(key),
                  progress: entry.value.progress,
                  backgroundColor: key == 'career' ? AppColors.weakedGreen : AppColors.spaceCadet,
                  title: title,
                  icon: icon,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => targetPage,
                    ));
                  },
                );
              }),

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


