class VideoUrls {
  final List<LanguageVideo> videoUrls;

  VideoUrls({required this.videoUrls});

  factory VideoUrls.fromJson(Map<String, dynamic> json) {
    return VideoUrls(
      videoUrls: (json['VideoUrls'] as List)
          .map((video) => LanguageVideo.fromJson(video))
          .toList(),
    );
  }
}

class LanguageVideo {
  final String title;
  final Map<String, String> url;
  final TaskMap? tasks;

  LanguageVideo({required this.title, required this.url, this.tasks});

  factory LanguageVideo.fromJson(Map<String, dynamic> json) {
    return LanguageVideo(
      title: json['Title'],
      url: Map<String, String>.from(json['Url']),
      tasks: json['Tasks'] != null ? TaskMap.fromJson(json['Tasks']) : null,
    );
  }
}

class TaskMap {
  final String title;
  final Map<String, String> url;

  TaskMap({required this.title, required this.url});

  factory TaskMap.fromJson(Map<String, dynamic> json) {
    return TaskMap(
      title: json['Title'],
      url: Map<String, String>.from(json['Url']),
    );
  }
}