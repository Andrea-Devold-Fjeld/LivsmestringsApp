// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/pages/language_page.dart';
import 'package:livsmestringapp/widgets/Layout.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unused/firebase_options.dart';
import '../pages/language_page_nav.dart';
import '../pages/splash_screen.dart';
import 'services/LocaleString.dart';
import '../styles/theme.dart';
import 'consumer/FetchData.dart';
import 'models/DataModel.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );

   //Prevents the application from changing orientation to horizontal at any point:
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? getLanguage = prefs.getInt('selectedLanguage');
  Locale locale = getLanguage != null
      ? LanguagePageNav.localeSet[getLanguage]['locale']
      : Locale('nb', 'NO');

  runApp(MyApp(
    selectedLanguage: getLanguage,
    locale: locale,
  ));
}

class MyApp extends StatefulWidget {
  final int? selectedLanguage;
  final Locale locale;

  const MyApp({super.key, required this.selectedLanguage, required this.locale});

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  late int? _selectedLanguage;
  late Future<Map<String, Datamodel>> _dataFuture;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchAllData();
    _selectedLanguage = widget.selectedLanguage;
    _locale = widget.locale;
    Logger.root.level = Level.ALL; // defaults to Level.INFO

  }

  Future<Map<String, Datamodel>> _fetchAllData() async {
    final results = await Future.wait([
      fetchData('career'),
      fetchData('health')
    ]);

    return {
      'career': results[0],
      'health': results[1],
    };
  }
  void updateLocale(Locale newLocale, int? newIndex) {
    setState(() {
      _locale = newLocale;
      _selectedLanguage = newIndex;
    });
    // Re-run the app with the updated locale
    runApp(MyApp(selectedLanguage: newIndex, locale: newLocale));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocaleString(),
      locale: _locale,
      title: 'life_mastery_app'.tr,
      theme: lightMode,
      darkTheme: darkMode,
      home: FutureBuilder(
          future: _dataFuture,
          builder: (context, snapshot){

            if (snapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen(selectedLanguage: _selectedLanguage, );
            }
            else if (snapshot.hasData){
              if(_selectedLanguage == null){
                return LanguagePage();
              }
              else {
                return Layout(data: snapshot.requireData);

              }
              /*
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) {
                          if (_selectedLanguage == null){
                            return LanguagePage();
                          }
                          return HomePage(data: snapshot.requireData,);
                        }
                    ),
                  )
              );


               */
            }
            else if (snapshot.hasError){
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            else {
              return Center(child: Text("No data available"));
            }
          })
      //home: SplashScreen(
      //  selectedLanguage: _selectedLanguage,
      //),
    );
  }
}

/*
_selectedLanguage == null
                          ?  LanguagePage()
                          :  NavigationPage()),
 */