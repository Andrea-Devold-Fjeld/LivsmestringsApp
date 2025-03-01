import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livsmestringapp/styles/fonts.dart';
import 'package:livsmestringapp/widgets/language_button.dart';

class LanguagePage extends StatefulWidget {
  final ValueSetter<int> selectedLanguage;
  const LanguagePage({super.key, required this.selectedLanguage});

  @override
  State<LanguagePage> createState() => _LanguagesScreenState();

  void _handleSelection(int index){
  }
}

class _LanguagesScreenState extends State<LanguagePage> {
  final List<Map<String, dynamic>> locale = [
    {'name': 'English', 'locale': Locale('en', 'UK')},
    //{'name': 'Español', 'locale': Locale('es', 'ES')},
    //{'name': 'Kiswahili', 'locale': Locale('sw', 'KE')},
    //{'name': 'Kurmancî', 'locale': Locale('ku', 'TR')},
    {'name': 'Norsk', 'locale': Locale('nb', 'NO')},
    //{'name': 'Soomaali', 'locale': Locale('so', 'SO')},
    //{'name': 'Türkçe', 'locale': Locale('tr', 'TR')},
    //{'name': 'украïнська', 'locale': Locale('uk', 'UA')},
    //{'name': 'اردو', 'locale': Locale('ur', 'PK')},
    //{'name': 'العربية', 'locale': Locale('ar', 'AR')},
    {'name': 'پښتو', 'locale': Locale('ps', 'AF')},
    //{'name': 'فارسی', 'locale': Locale('fa', 'IR')},  // Persian
    //{'name': 'தமிழ்', 'locale': Locale('ta', 'IN')}, // Tamil
    //{'name': 'ไทย', 'locale': Locale('th', 'TH')}, // Thai
    //{'name': 'አማርኛ', 'locale': Locale('am', 'ET')}, // Amharic
    //{'name': 'ትግሪኛ', 'locale': Locale('ti', 'ET')},
  ];

  late SharedPreferences prefs;
  late Future<int?> language;
  final ScrollController _scrollController = ScrollController();
  bool arrowDownClicked = true;
  int? activeItem;

  Future<int?> getSelectedLanguage() async {
    prefs = await SharedPreferences.getInstance();
    activeItem = prefs.getInt('selectedLanguage');
    return activeItem;
  }

  @override
  void initState() {
    super.initState();
    language = getSelectedLanguage();
  }

  void updateLanguage(Locale locale, int? index) {
    Get.updateLocale(locale);
    prefs.setInt('selectedLanguage', index!);
    widget._handleSelection(index);
    var homeController = Get.find<HomePageController>();
    homeController.setLocale(locale);
    Get.toNamed("/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo_black.png',
                    width: 200,
                  ),
                ],
              ),
              AutoSizeText(
                'welcome'.tr,
                style: Fonts.header1,
                minFontSize: 14,
                maxFontSize: 20,
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: FutureBuilder<int?>(
                    future: language,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: locale.length,
                          itemBuilder: (context, index) {
                            return LanguageButton(
                              language: locale[index]['name'],
                              active: activeItem == index,
                              onPressed: () {
                                setState(() {
                                  activeItem = index;
                                });
                                updateLanguage(locale[index]['locale'], index);
                              },
                            );
                          },
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ),
              arrowDownClicked
                  ? GestureDetector(
                onTap: () {
                  setState(() {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                    arrowDownClicked = false;
                  });
                },
                child: Icon(
                  Icons.arrow_downward,
                  size: 45,
                  color: Colors.purple[600],
                ),
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    _scrollController.animateTo(
                      _scrollController.position.minScrollExtent,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                    arrowDownClicked = true;
                  });
                },
                child: Icon(
                  Icons.arrow_upward,
                  size: 45,
                  color: Colors.purple[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}