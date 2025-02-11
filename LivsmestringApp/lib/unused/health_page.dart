import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/DataModel.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../widgets/list_button.dart';
import 'health_details_page.dart';
import '../pages/navigation_page.dart';


class HealthPage extends StatefulWidget {
  final Datamodel data;

  const HealthPage({super.key, required this.data});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  int activeItem = -1;

  @override
  Widget build(BuildContext context) {
    //List<String> fetchedItems = getHealthModulesTittles();
    List<String> fetchedItems = [];

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
                if (Navigator.of(context).canPop()) {
                  // If there's more than one route on the stack, pop the current route
                  Navigator.of(context).pop();
                }
                else {
                  // If the current page is the only one on the stack, navigate to the home page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NavigationPage(data: {},)),
                        (route) => false, // Remove all routes from the stack
                  );
                }
              },
            ),
          ],
        ),
        title:  AutoSizeText(
         'health'.tr,
          style: Fonts.homePageCardLabel,

          minFontSize: 10, // Set the minimum font size
          maxFontSize: 20, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor:
         AppColors.spaceCadet,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: fetchedItems.length, // Use fetchedItems instead of hardcodedItems
              itemBuilder: (context, index) {
                return ListButton(
                  content: fetchedItems[index], // Use fetchedItems instead of hardcodedItems
                  active: activeItem == index ? true : false,
                //  buttonsLength: fetchedItems.length,
                  activeColor:
                   AppColors.spaceCadetComplementary,
                  inactiveColor:
                   AppColors.spindle,
                  onPressed: () {
                    setState(() {
                      activeItem = index;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HealthDetailsPage(
                          index: index,
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
}
