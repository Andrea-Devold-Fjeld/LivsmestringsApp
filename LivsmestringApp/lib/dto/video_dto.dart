import 'task_dto.dart';

class VideoDTO {
  final int id;
  final int chapterId;
  final String title;
  final String url;
  final bool watched;
  List<TaskDTO> tasks;

  VideoDTO({required this.id, required this.chapterId, required this.title, required this.url, this.watched = false, this.tasks = const []});

  factory VideoDTO.fromMap(Map<String, dynamic> map) {
    return VideoDTO(
      id: map['id'],
      chapterId: map['chapter_id'],
      title: map['title'],
      url: map['url'],
      watched: map['watched'] == 1,
      tasks: (map['tasks'] as List<dynamic>?)
          ?.map((taskMap) => TaskDTO.fromMap(taskMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'title': title,
      'url': url,
      'watched': watched ? 1 : 0,
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }
}