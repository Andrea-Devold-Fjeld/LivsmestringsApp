
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'dart:developer';



final dio = Dio();

Future<Datamodel> fetchData(String category) async {
  log.printInfo(info: "Category: $category");
  try {
    final response = await dio.get('https://testhttp.fly.dev/$category');
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


