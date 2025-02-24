import 'task-db.dart';

class Video {
  final int? id;
  final int chapterId;
  final String title;
  final String url;
  final bool watched;
  List<Task> tasks;

  Video({this.id, required this.chapterId, required this.title, required this.url, this.watched = false, this.tasks = const []});


  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'],
      chapterId: map['chapter_id'],
      title: map['title'],
      url: map['url'],
      watched: map['watched'] == 1,
      tasks: (map['tasks'] as List<dynamic>?)
          ?.map((taskMap) => Task.fromMap(taskMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'chapter_id': chapterId,
      'title': title,
      'url': url,
      'watched': watched ? 1 : 0,
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}