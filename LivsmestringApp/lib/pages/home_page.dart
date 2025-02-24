import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/databse/database_operation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import '../controllers/database-controller.dart';
import '../models/DataModel.dart';
import '../styles/colors.dart';
import '../widgets/buttom_navigation.dart';
import '../widgets/homepage_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CategoryDTO> _categories = [];
  late final Map<int, ProgressModel> _progress = {};
  late Map<String, Datamodel> _data;
  final DatabaseController _databaseController = Get.find<DatabaseController>();
  int _selectedTab = 0;

  Object _handleNavigation(int index) {
    if(index == 0){
      return Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => HomePage()));
    }else if(index == 1){
      return Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => ChapterPage(category: _categories[0],updateProgress: (bool value) {_loadData();} ,)));
    }else if(index == 2){
      return Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => ChapterPage(category: _categories[1], updateProgress: (bool value){_loadData();},)));
    }else if(index == 3){
      return Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => LanguagePageNav()));
    }else {
      return Text("Feil");
    }
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }



  Future<void> _loadData() async {
    var categories = await _databaseController.getCategories();
    setState(() {
      _categories = categories;
    });
    for (var c in _categories) {
      _progress[c.id] = await _databaseController.getVideoProgress(c.id);
    }
  }

  Future<Datamodel> _getData(String category) async {
    return await _databaseController.getDatamodel(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          HomePageContent(categories: _categories, progress: _progress, updateProgress: (bool value){_loadData();} ),
          ChapterPage(category: _categories[0], updateProgress:  (bool value){_loadData();}),
          ChapterPage(category: _categories[1], updateProgress:  (bool value){_loadData();}),
          LanguagePageNav()
        ],
      ),
      bottomNavigationBar: ButtomNavigationBar(
        selectedTab: _selectedTab,
        onTap: _handleNavigation,
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final List<CategoryDTO> categories;
  final Map<int, ProgressModel> progress;
  final ValueSetter<bool> updateProgress;

  const HomePageContent({super.key, required this.categories, required this.progress, required this.updateProgress});



  @override
  State<StatefulWidget> createState() => _HomePageContent();
  }

class _HomePageContent extends State<HomePageContent> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/logo_black.png',
            width: 300,
          ),
          ...widget.categories.map((entry) {
            int id = entry.id;
            String name = entry.name;

            String title = name.tr;
            Icon icon;
            Color backgroundColor;

            switch (name) {
              case 'career':
                icon = Icon(
                  Icons.work,
                  size: 40,
                  color: AppColors.white,
                );
                backgroundColor = AppColors.weakedGreen;
                break;
              case 'health':
                icon = Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: AppColors.white,
                );
                backgroundColor = AppColors.spaceCadet;
                break;
              default:
                icon = Icon(
                  Icons.help,
                  size: 40,
                  color: AppColors.white,
                );
                backgroundColor = Colors.grey; // Default background color
                break;
            }
            return HomePageCard(
              key: ValueKey(name),
              progress: widget.progress[id]?.progress ?? 0.0,
              backgroundColor: backgroundColor,
              title: title,
              icon: icon,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ChapterPage( category: entry, updateProgress: widget.updateProgress),
                  ),
                );
              },
            );
          })

        ],
      ),
    );
  }

}






