import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home-page-controller.dart';
import '../../main.dart';
import '../../services/locale_set.dart';


class HomePage extends StatefulWidget {
  final String? selectedLanguage;

  const HomePage({super.key, required this.selectedLanguage});

  @override
  State<HomePage> createState() => _HomePageState();
}
/*
 * This widget is responsible for displaying the home page of the app.
 * It shows a language selection dialog if no language is selected.
 * If a language is selected, it fetches data for the home page.
 */


class _HomePageState extends State<HomePage> {
  bool _dialogShown = false;
  var homePageController = Get.find<HomePageController>();

  @override
  void initState() {
    super.initState();
    // Only show the language dialog if no language is selected
    if (widget.selectedLanguage == null) {
      // Delay to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLanguageDialog();
      });
    }else {
      homePageController.fetchAllData();

    }
  }

  Future<void> _showLanguageDialog() async {
    if (_dialogShown) return; // Prevent multiple dialogs
    _dialogShown = true;

    final selectedLocale = await buildLanguageDialog(context);

    if (selectedLocale != null) {
      // Update state or navigate as needed
      homePageController.currentLocale.value = selectedLocale;
      //homePageController.currentIndex.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigation();
  }

  Future<Locale?> buildLanguageDialog(BuildContext context) async {
    final result = await showDialog<Locale?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          child: AlertDialog(
            title: Center(child: Text('select_language'.tr)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: LocaleSet.localeSet.length,
                itemBuilder: (context, index) {
                  final locale = LocaleSet.localeSet[index]['locale'];
                  final name = LocaleSet.localeSet[index]['name'];
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(name),
                        onTap: () {
                          Navigator.pop(context, locale);
                        },
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
              ),
            ),
          ),
        );
      },
    );
    return result;
  }
}

