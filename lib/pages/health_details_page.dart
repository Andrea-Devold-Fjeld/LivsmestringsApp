import 'package:flutter/material.dart';
import '../widgets/list_button.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../services/health_data.dart';
import 'health_details_of_details_page.dart';
import 'package:auto_size_text/auto_size_text.dart';


class HealthDetailsPage extends StatefulWidget {
  final int index;

  const HealthDetailsPage({
    super.key,
    required this.index,
  });

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
  int activeItem = -1; // Initialize activeItem to -1


  @override
  Widget build(BuildContext context) {

    print('Current Index is: ${widget.index}');
    print('Type of widget.index: ${widget.index.runtimeType}');
 //   print('Health Items Length: ${widget.healthItems.length}');
    List<String> fetchedItems = getHealthSubModuleTittles(widget.index, "");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title:  AutoSizeText(
          getHealthModulesTittles()[widget.index],
          style: Fonts.homePageCardLabel,

          minFontSize: 10, // Set the minimum font size
          maxFontSize: 18, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor: AppColors.spaceCadet,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: fetchedItems.length,
              itemBuilder: (context, index) {
                return ListButton(
                  content: fetchedItems[index],
                //  buttonsLength: fetchedItems.length,
                  active: activeItem == index ? true : false, // Adjust active condition
                  activeColor:
                  AppColors.spaceCadetComplementary,
                  inactiveColor:
                  AppColors.spindle,
                  onPressed: () {
                    setState(() {
                      activeItem = index;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HealthDetailsOfDetailsPage(
                          prevIndex: widget.index,
                          index: index,
                          appBarTittle: fetchedItems[index],
                        ),
                      ));
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
