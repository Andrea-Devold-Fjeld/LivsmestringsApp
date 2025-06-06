import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Datamodel {
  final String category;
  List<Chapter> chapters;
  late final int _totalVideos = totalVideos();
  late int _watchedVideos = initWatchedVideos();
  late double _progress = _watchedVideos/_totalVideos;

  Datamodel({required this.chapters, required this.category});

  factory Datamodel.fromJson(Map<String, dynamic> json) {
    return Datamodel(
      chapters: (json['Chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
      category: json['Category'],
    );
  }

  int totalVideos(){
    var count = 0;
    for (var c in chapters) {
      count += c.videos.length;
      for (var v in c.videos) {
        count += v.tasks?.length ?? 0;
      }
    }
    return count;
  }

  set watchedVideos(int i){
    _watchedVideos += i;
    _progress = _watchedVideos/_totalVideos;
  }

  double get progress => _progress;

  int initWatchedVideos() {
    var count = 0;
    for (var c in chapters) {
      for (var v in c.videos) {
        if(v.watched) count++;
        v.tasks?.forEach((t) {
          if(t.watched) count++;
        });
      }
    }
    return count;
  }
}

class Chapter {
  final String title;
  List<Video> videos;

  Chapter({
    required this.title,
    required this.videos,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['Title'],
      videos: (json['Videos'] as List?)
          ?.map((video) => Video.fromJson(video))
          .toList() ?? [],
    );
  }
}

class Video {
  final String title;
  final Map<String, String> languageUrls;
  final List<Task>? tasks;
  String? currentLanguage;
  Duration? totalLength;
  Duration? watchedLength;
  bool _watched = false;

  Video({
    required this.title,
    required this.languageUrls,
    this.tasks,
    this.currentLanguage,
    this.totalLength,
    this.watchedLength,
  });

  bool get watched => _watched;
  set watched(bool v){
    _watched = v;
  }

  String get url => languageUrls[currentLanguage] ?? languageUrls.values.first;

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['Title'],
      languageUrls: json['LanguageUrls'] != null
          ? Map<String, String>.from(json['LanguageUrls'])
          : {'en': json['Url'] ?? ''},
      tasks: json['Tasks'] != null
          ? (json['Tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList()
          : null,
      totalLength: null,
      watchedLength: null,
    );
  }
}

class Task {
  final String title;
  final Map<String, String> languageUrls;
  String? currentLanguage;
  bool _watched = false;

  Task({
    required this.title,
    required this.languageUrls,
    this.currentLanguage,
  });

  bool get watched => _watched;
  set watched(bool v){
    _watched = v;
  }

  String get url => languageUrls[currentLanguage] ?? languageUrls.values.first;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['Title'],
      languageUrls: json['LanguageUrls'] != null
          ? Map<String, String>.from(json['LanguageUrls'])
          : {'en': json['Url'] ?? ''},
    );
  }
}