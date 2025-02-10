import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Datamodel {
  @JsonKey(name: 'Chapters')
  final List<Chapter> chapters;

  Datamodel({required this.chapters});

  factory Datamodel.fromJson(Map<String, dynamic> json) {
    return Datamodel(
      chapters: (json['Chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
    );
  }
}

class Chapter {
  final String title;
  final List<Video> videos;

  Chapter({
    required this.title,
    required this.videos,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['Title'],
      videos: (json['Videos'] as List)
          .map((video) => Video.fromJson(video))
          .toList(),
    );
  }
}

class Video {
  final String title;
  final String url;
  final List<Task>? tasks;
  bool _watched = false;

  Video({
    required this.title,
    required this.url,
    this.tasks,
  });

  bool get watched => _watched;
  set watched(bool v){
    _watched = v;
  }
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['Title'],
      url: json['Url'],
      tasks: json['Tasks'] != null
          ? (json['Tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList()
          : null,
    );
  }

}

class Task {
  final String title;
  final String url;
  bool _watched = false;

  Task({
    required this.title,
    required this.url,
  });

  bool get watched => _watched;
  set watched(bool v){
    _watched = v;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['Title'],
      url: json['Url'],
    );
  }
}