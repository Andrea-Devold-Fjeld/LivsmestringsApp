
class TaskDto {
  final int? id;
  final int videoId;
  final String title;
  final String url;
  late final bool watched;

  TaskDto({this.id, required this.videoId, required this.title, required this.url, this.watched = false});


  factory TaskDto.fromMap(Map<String, dynamic> map) {
    return TaskDto(
      id: map['id'],
      videoId: map['video_id'],
      title: map['title'],
      url: map['url'],
      watched: map['watched'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'video_id': videoId,
      'title': title,
      'url': url,
      'watched': watched ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}