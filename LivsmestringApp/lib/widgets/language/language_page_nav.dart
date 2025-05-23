import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/services/locale_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home-page-controller.dart';
import '../../models/page_enum.dart';

class LanguagePageNav extends StatefulWidget {

  const LanguagePageNav({super.key});

  @override
  State<LanguagePageNav> createState() => _LanguagePageNavState();
}

class _LanguagePageNavState extends State<LanguagePageNav> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateLanguage(Locale locale, int index) async {
    Get.updateLocale(locale);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedLanguage', index); // Store selected language index
    var homeController = Get.find<HomePageController>();
    homeController.setLocale(locale);
    Get.toNamed("/home");
    }


  Future<Locale?> buildLanguageDialog(BuildContext context) async {
    final result = await showDialog<Locale?>(
      context: context,
      builder: (builder) {
        return AlertDialog(
          //   backgroundColor: Colors.white54,
          title: Center(
            child: Text('select_language'.tr,

            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      child: Text(LocaleSet.localeSet[index]['name']),
                      onTap: () {
                        updateLanguage(
                            LocaleSet.localeSet[index]['locale'], index);
                        Navigator.pop(
                            context,
                            LocaleSet.localeSet[index]['locale']);
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.grey[800],
                );
              },
              itemCount: LocaleSet.localeSet.length,
            ),
          ),
        );
      },
    );
    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title:   AutoSizeText(
            'language_up'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            minFontSize: 10, // Set the minimum font size
            maxFontSize: 20, // Set the maximum font size
            maxLines: 1, // Limit the text to a single line
          ),
          ),
        ),

      body: Column(
        children: [
          Divider(
            thickness: 2, // Adjust the thickness of the divider
            color: Colors.black26, // Set the color of the divider
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () async {
             await buildLanguageDialog(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.grey[300], // Set the background color of the button
                  border: Border.all(color: Colors.black87), // Add border
                ),
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, color: Colors.blue[800], size: 30),
                    SizedBox(width: 15),
                    AutoSizeText(
                      'language'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                      minFontSize: 12, // Set the minimum font size
                      maxFontSize: 12, // Set the maximum font size
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
