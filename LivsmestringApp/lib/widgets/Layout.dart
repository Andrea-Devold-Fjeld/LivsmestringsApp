import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:livsmestringapp/models/CategoryEnum.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import '../databse/database_operation.dart';
import '../models/DataModel.dart';
import '../pages/home_page.dart';
import 'buttom_navigation.dart';

class Layout extends StatefulWidget {
  final Map<String, Datamodel> data;

  const Layout({
    super.key,
    required this.data,
  });



  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedTab = 0;

  void _handleNavigation(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbController = Get.find<DatabaseController>();
    dbController.getChapters("category");
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          HomePage(data: widget.data),
          ChapterPage(data: widget.data["career"]!, category: Category.carreer),
          ChapterPage(data: widget.data["health"]!, category: Category.health),
          LanguagePageNav(),
        ],
      ),
      bottomNavigationBar: ButtomNavigationBar(
        selectedTab: _selectedTab,
        onTap: _handleNavigation,
      ),
    );
  }
}