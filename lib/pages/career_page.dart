import 'package:flutter/material.dart';
import 'career_details_page.dart';
import '../services/career_data.dart';
import '../widgets/list_button.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'navigation_page.dart';
import 'package:get/get.dart';

import 'package:auto_size_text/auto_size_text.dart';


class CareerPage extends StatefulWidget {

  final bool isCareer;

   CareerPage(
      {super.key, required this.isCareer,});

  @override
  State<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {
  int activeItem = -1;

  @override
  Widget build(BuildContext context) {


    List<String> fetchedItems = getCareerModulesTittles("");

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
                  //Todo: Might be the only viable option if the progress bar is to be updated every time the user returns tot he Home Page:
                  // If the current page is the only one on the stack, navigate to the home page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NavigationPage()),
                        (route) => false, // Remove all routes from the stack
                  );
                }
              },
            ),
          ],
        ),
        title:  AutoSizeText(
          widget.isCareer ? 'career'.tr : 'health'.tr,
          style: Fonts.homePageCardLabel,

          minFontSize: 10, // Set the minimum font size
          maxFontSize: 20, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor:
        widget.isCareer ? AppColors.weakedGreen : AppColors.tune,
      ),
      body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ListView.builder(
            itemCount: fetchedItems.length,
            itemBuilder: (context, index) {
              return ListButton(
                content: fetchedItems[index],
              //  buttonsLength: fetchedItems.length,
                active: activeItem == index ? true : false, // Adjust active condition
                activeColor: AppColors.weakedGreenComplementary,
                inactiveColor: AppColors.GreenLeave,
                onPressed: () {
                  setState(() {
                    activeItem = index;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CarrerDetailesPage(
                        isCareer: widget.isCareer,
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
