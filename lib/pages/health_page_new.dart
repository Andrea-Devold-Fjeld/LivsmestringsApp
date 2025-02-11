import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'health_details_page_new.dart';
import '../services/health_data.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/loading_indicator.dart';


class HealthPageNew extends StatefulWidget {

  const HealthPageNew({super.key,});

  @override
  State<HealthPageNew> createState() => _HealthPageNewState();
}

class _HealthPageNewState extends State<HealthPageNew> {
 // late List<String> healthItems;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
  //  healthItems = getHealthModulesTittles();
    initializeLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
/*
        title:  AutoSizeText(
          'health'.tr,
          style: Fonts.homePageCardLabel,

          minFontSize: 10, // Set the minimum font size
          maxFontSize: 20, // Set the maximum font size
          maxLines: 2,
        ),
        backgroundColor: AppColors.spaceCadet,
      ),
      body: isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : ListView.builder(
        itemCount: getHealthModulesTittles().length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(8.0),
            child: ExpansionTile(
              title:  AutoSizeText(
                getHealthModulesTittles()[index],
                style: TextStyle(
            //      fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 15, // Set the minimum font size
                maxFontSize: 15, // Set the maximum font size
                maxLines: 4,
              ),
              textColor: Colors.purple[600],
                children: [
            SingleChildScrollView(
            child: Column(
            children: [
                ... getHealthSubModuleTittles(index, "").map(
                      (item) => ListTile(
                    title:  AutoSizeText(
                      item,
                      style: TextStyle(
                  //      fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                      minFontSize: 14, // Set the minimum font size
                      maxFontSize: 14, // Set the maximum font size
                      maxLines: 4,
                    ),
                    textColor: Colors.blue[900],
                    onTap: () {
                      print('Item is $item with index getHealthItemDetails(index), '
                          'Index is $index, healthItems er ${ getHealthSubModuleTittles(index, "")}');
                      print('Items to be displayed are ${getSubModuleIndexAndVideosTittle( getHealthSubModuleTittles(index, ""),  item, index)}');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HealthDetailsPageNew(
                            subModuleTittle: item,
                            moduleTittle: getHealthModulesTittles()[index],
                            moduleIndex: index,
                            subModulesTittles:  getHealthSubModuleTittles(index, ""),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ],
          ),
          );
        },
      ),

 */
    ));
  }

  Future<void> initializeLists() async {
    setState(() {
      isLoading = true;
    });
    // Perform any asynchronous operations here
    setState(() {
      isLoading = false;
    });
  }
}
