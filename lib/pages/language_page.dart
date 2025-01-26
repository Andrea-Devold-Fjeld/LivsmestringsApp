import 'navigation_page.dart';
import '../widgets/language_button.dart';
import '../styles/fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});
  @override
  State<LanguagePage> createState() => _LanguagesScreenState();}

class _LanguagesScreenState extends State<LanguagePage> {

  final List<Map<String, dynamic>> locale = [
    {'name': 'English', 'locale': Locale('en', 'UK')},
    {'name': 'Español', 'locale': Locale('es', 'ES')},
    {'name': 'Kiswahili', 'locale': Locale('sw', 'KE')},
    {'name': 'Kurmancî', 'locale': Locale('ku', 'TR')},
    {'name': 'Norsk', 'locale': Locale('nb', 'NO')},
    {'name': 'Soomaali', 'locale': Locale('so', 'SO')},
    {'name': 'Türkçe', 'locale': Locale('tr', 'TR')},
    {'name': 'украïнська', 'locale': Locale('uk', 'UA')},
    {'name': 'اردو', 'locale': Locale('ur', 'PK')},
    {'name': 'العربية', 'locale': Locale('ar', 'AR')},
    {'name': 'پښتو', 'locale': Locale('ps', 'AF')},
    {'name': 'فارسی', 'locale': Locale('fa', 'IR')},  // Persian
    {'name': 'தமிழ்', 'locale': Locale('ta', 'IN')}, // Tamil
    {'name': 'ไทย', 'locale': Locale('th', 'TH')}, // Thai
    {'name': 'አማርኛ', 'locale': Locale('am', 'ET')}, // Amharic
    {'name': 'ትግሪኛ', 'locale': Locale('ti', 'ET')},
  ];

  late SharedPreferences prefs;
  late Future language;
  final ScrollController _scrollController = ScrollController();
  bool arrowDownClicked = true;
  int? activeItem;


  /*
  final List<Map<String, dynamic>> locale = [

    //   {'name': 'دری', 'locale': Locale('prs', 'AF')},
   // {'name': 'فارسی', 'locale': Locale('fa', 'IR')},
    {'name': 'English', 'locale': Locale('en', 'UK')},
    {'name': 'Español', 'locale': Locale('es', 'ES')},
    {'name': 'Kiswahili', 'locale': Locale('sw', 'KE')},
    {'name': 'Kurmancî', 'locale': Locale('ku', 'TR')},
    {'name': 'Norsk', 'locale': Locale('nb', 'NO')},
    {'name': 'Soomaali', 'locale': Locale('so', 'SO')},
    {'name': 'Türkçe', 'locale': Locale('tr', 'TR')},
    {'name': 'عربي', 'locale': Locale('ar', 'AR')},
    {'name': 'پښتو', 'locale': Locale('ps', 'AF')},
    {'name': 'ትግሪኛ', 'locale': Locale('ti', 'ET')},
    {'name': 'украïнська', 'locale': Locale('uk', 'UA')},
    {'name': 'اردو', 'locale': Locale('ur', 'PK')},

    ];

   */








  Future<int?> getSelectedLanguage() async {
    prefs = await SharedPreferences.getInstance();
    activeItem = prefs.getInt('selectedLanguage');
    return null;
  }

  @override
  void initState() {
    super.initState();
    language = getSelectedLanguage();
  }

  void updateLanguage(Locale locale, int? index) {
    Get.updateLocale(locale);
    prefs.setInt('selectedLanguage', index!);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => NavigationPage(),
    ));
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
              AutoSizeText('welcome'.tr,
                  style: Fonts.header1,

                minFontSize: 14, // Set the minimum font size
                maxFontSize: 20, // Set the maximum font size
                maxLines: 2, // Limit the text to a single line
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: FutureBuilder(
                    future: language,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: locale.length,
                          itemBuilder: (context, index) {
                            return LanguageButton(
                              language: locale[index]['name'],
                              active: activeItem == index ? true : false,
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
                        return Container(
                          child: CircularProgressIndicator(),
                        );
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
