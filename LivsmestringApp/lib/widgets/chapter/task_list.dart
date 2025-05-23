
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/database-controller.dart';
import '../../dto/task_dto.dart';
import '../video_player/youtube-video-player.dart';

class TaskList extends StatelessWidget {
  final List<TaskDto> tasks;
  final ValueSetter<bool> updateWatched;

  const TaskList({super.key, required this.tasks, required this.updateWatched});

  void _onUpdate(){
    updateWatched(true);
  }
  void _markTaskAsWatched(TaskDto task) async {
    final DatabaseController databaseController = Get.find<DatabaseController>();
    await databaseController.markTaskWatched(task.title);
    _onUpdate();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, taskIndex) {
          TaskDto task = tasks[taskIndex];
          var progress = task.getTaskProgress();
          var isComplete = progress >= 0.95 || task.watched;

          return ListTile(
            dense: true,
            title: Text(task.title.tr),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isComplete
                      ? Icon(
                    task.watched ? Icons.check_circle : Icons.circle_outlined,
                    color: task.watched ? Colors.green : Colors.grey,
                  )
                      : SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                      strokeWidth: 2.5,
                    ),
                  ),]),
            onTap: () {
              _markTaskAsWatched(task);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => YoutubePage(url: task.url, title: task.title.tr, tasks: null, updateProgress: (Duration value){_markTaskAsWatched(task);},),
                ),
              );
            },
          );
        },
      ),);
  }

}