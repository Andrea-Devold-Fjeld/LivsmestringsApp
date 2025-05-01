
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'dart:developer';

import 'package:livsmestringapp/models/VideoUrl.dart';


final dio = Dio();

Future<Datamodel> fetchData(String category) async {
  log.printInfo(info: "Category: $category");
  var dbController = Get.find<DatabaseController>();
  try {
    final response = await dio.get('https://testhttp.fly.dev/$category');
    //final response = await dio.get('http://localhost:8080/$category');
    if(response.statusCode == 200) {
      log("After response: $response ");
      return Datamodel.fromJson(response.data);
    }
    if (response.statusCode != 200){
      log(response.statusCode as String);
      log(response.headers as String);
      return Datamodel.fromJson(response.data);
    }
  }catch (e){
    throw Exception('Failed to load data from $category: $e');
  }
  throw Exception();
}

Future<VideoUrls> fetchVideoUrls() async {
  log.printInfo(info: "fetch video urls");
  try {
    final response = await dio.get('https://testhttp.fly.dev/video');
    //final response = await dio.get('http://localhost:8080/video');
    if(response.statusCode == 200) {
      log("After response: $response ");
      return VideoUrls.fromJson(response.data);
    }
    if (response.statusCode != 200){
      log(response.statusCode as String);
      log(response.headers as String);
      return VideoUrls.fromJson(response.data);
    }
  }catch (e){
    throw Exception('Failed to load data from : $e');
  }
  throw Exception();
}

