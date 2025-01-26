import 'package:flutter/material.dart';
import '../pages/career_page.dart';
import 'health_page.dart';
import '../pages/home_page.dart';
import 'language_page_nav.dart';
import '../widgets/buttom_navigation.dart';

class NavigationPage extends StatefulWidget {

  const NavigationPage({Key? key});

  @override
  State<NavigationPage> createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  int selectedTab = 0;


  late List<Widget> pages; // Declare pages variable

  @override
  void initState() {
    super.initState();
    pages = [ // Initialize pages inside initState
      HomePage(),
      CareerPage(
        isCareer: true,
      ),
      HealthPage(),
      LanguagePageNav(),
    ];
  }



  void onPressed(int value) {
    setState(() {
      selectedTab = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedTab],
      bottomNavigationBar: ButtomNavigationBar(
        selectedTab: selectedTab,
        onTap: onPressed,
      ),
    );
  }
}
