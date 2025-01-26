// main.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:get/get.dart';
import '../services/LocaleString.dart';
import '../pages/language_page_nav.dart';

import '../firebase_options.dart';
import '../pages/splash_screen.dart';
import '../styles/theme.dart';
import 'package:firebase_core/firebase_core.dart';


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
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
    _locale = widget.locale;
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
      home: SplashScreen(
        selectedLanguage: _selectedLanguage,
      ),
    );
  }
}
