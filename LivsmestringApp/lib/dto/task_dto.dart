class TaskDTO {
  final int id;
  final int videoId;
  final String title;
  final String url;
  final bool watched;

  TaskDTO({required this.id, required this.videoId, required this.title, required this.url, this.watched = false});

  factory TaskDTO.fromMap(Map<String, dynamic> map) {
    return TaskDTO(
      id: map['id'],
      videoId: map['video_id'],
      title: map['title'],
      url: map['url'],
      watched: map['watched'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video_id': videoId,
      'title': title,
      'url': url,
      'watched': watched ? 1 : 0,
    };
  }
}