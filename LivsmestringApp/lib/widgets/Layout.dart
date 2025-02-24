import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import '../pages/home_page.dart';
import 'buttom_navigation.dart';


class Layout extends StatefulWidget {
  final Future<List> categories;
  const Layout({
    super.key,
    required this.categories,
  });

  @override
  State createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedTab = 0;
  final DatabaseController _databaseController = Get.find();
  final HomePageController _homePageController = Get.find();
  void _handleNavigation(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: widget.categories, // Fetch categories asynchronously
      builder: (context, snapshot) {
        // Check if the future is still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error if there's any
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // If data is available, proceed with building the navigation
        List categories = snapshot.data ?? [];
        List<Widget> nav = [];
        nav.add(HomePage());
        for (var v in categories) {
          nav.add(ChapterPage(category: v, updateProgress: (bool value) {  },));
        }
        nav.add(LanguagePageNav());

        return Scaffold(
          body: IndexedStack(
            index: _selectedTab,
            children: nav,
          ),
          bottomNavigationBar: ButtomNavigationBar(
            selectedTab: _selectedTab,
            onTap: _handleNavigation,
          ),
        );
      },
    );
  }
}


