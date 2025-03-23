import 'task-db.dart';

class VideoDto {
  final int? id;
  final int chapterId;
  final String title;
  final String url;
  bool watched;
  List<TaskDto>? tasks;
  Duration? totalLength;
  Duration? watchedLength;

  VideoDto({
    this.id,
    required this.chapterId,
    required this.title,
    required this.url,
    this.watched = false,
    this.tasks,
  this.totalLength,
  this.watchedLength});


  factory VideoDto.fromMap(Map<String, dynamic> map) {
    return VideoDto(
      id: map['id'],
      chapterId: map['chapter_id'],
      title: map['title'],
      url: map['url'],
      watched: map['watched'] == 1,
      tasks: (map['tasks'] as List<dynamic>?)
          ?.map((taskMap) => TaskDto.fromMap(taskMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'chapter_id': chapterId,
      'title': title,
      'url': url,
      'watched': watched ? 1 : 0,
      'tasks': tasks?.map((task) => task.toMap()).toList(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  double getVideoProgress(){
    if(watchedLength == null || totalLength == null){
        return 0.0;
    }
    else{
      double progress = (watchedLength!.inSeconds.toDouble() / totalLength!.inSeconds.toDouble());
      if(progress >= 0.95){
        watched = true;
        return 1.0;
      }else {
        return progress;
      }
    }

  }
}