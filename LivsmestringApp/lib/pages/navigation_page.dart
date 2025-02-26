

/*
class NavigationPage extends StatefulWidget {
  final Map<String, Datamodel> data;
  const NavigationPage({super.key, required this.data});

  @override
  State<NavigationPage> createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  int selectedTab = 0;
  late Datamodel careerData;
  late Datamodel healthData;


  late List<Widget> pages; // Declare pages variable

  @override
  void initState() {
    super.initState();
    if(widget.data.containsKey("career") && widget.data.containsKey("health")){
      pages = [ // Initialize pages inside initState
        HomePage(),

        CareerPage(
          isCareer: true,
          data: widget.data["career"]!,
        ),
        HealthPage(
          data: widget.data["health"]!,
        ),
        LanguagePageNav(),
      ];
    }

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


 */