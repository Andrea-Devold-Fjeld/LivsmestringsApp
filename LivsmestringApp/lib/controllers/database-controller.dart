import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqflite/sqflite.dart';

import '../databse/database_operation.dart';
import '../models/DataModel.dart';

class DatabaseController extends GetxController {
  final Future<Database> db;

  DatabaseController(this.db);

  Future<void> insertDatamodel(Datamodel data) async {
    await insertDataModel(db, data);
  }
  Future<void> markVideoWatched(String videoUrl) async {
    await updateVideoWatchStatus(db, videoUrl, true);
  }

  Future<void> markTaskWatched(String taskUrl) async {
    await updateTaskWatchStatus(db, taskUrl, true);
  }

  Future<Map<String, dynamic>> getVideoProgress() async {
    return await getProgress(db);
  }

  getChapters(String category) async {
    await getChaptersWithCategory(db);
  }
}