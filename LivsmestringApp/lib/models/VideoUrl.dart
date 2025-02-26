import 'dart:convert';

// Class to represent the video URL data for each video
class LanguageVideo {
  String title;
  Map<String, String> url;

  LanguageVideo({required this.title, required this.url});

  // Factory constructor to create a Video instance from a JSON map
  factory LanguageVideo.fromJson(Map<String, dynamic> json) {
    return LanguageVideo(
      title: json['Title'],
      url: Map<String, String>.from(json['Url']),
    );
  }

  // Method to convert a Video instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Url': url,
    };
  }
}

// Class to represent the overall structure containing video URLs
class VideoUrls {
  List<LanguageVideo> videoUrls;

  VideoUrls({required this.videoUrls});

  // Factory constructor to create a VideoUrls instance from a JSON map
  factory VideoUrls.fromJson(Map<String, dynamic> json) {
    var list = json['VideoUrls'] as List;
    List<LanguageVideo> videoList = list.map((i) => LanguageVideo.fromJson(i)).toList();

    return VideoUrls(videoUrls: videoList);
  }

  // Method to convert a VideoUrls instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'VideoUrls': videoUrls.map((video) => video.toJson()).toList(),
    };
  }
}

void main() {
  // Sample JSON data
  String jsonData = '''{
    "VideoUrls": [
      {
        "Title": "1.1_introduction",
        "Url": {
          "en": "https://youtu.be/henIVlCPVIY?si=EUQCwc9XdspKwg-N",
          "no": "https://youtu.be/sJzqdEmz1t0?si=wyIAEyIGpuM9qhjf",
          "es": "https://youtu.be/DcZrRRB1EhI?si=Y9NQ852IqpidNbKQ",
          "uk": "https://youtu.be/y0sF5xhGreA?si=x_cOjpG6ewcfC8Qy",
          "ur": "https://youtu.be/npXBm2nvLfI?si=InggmOcKZQV_qkvw"
        }
      },
      {
        "Title": "1.2_new_words",
        "Url": {
          "en": "https://youtu.be/henIVlCPVIY?si=EUQCwc9XdspKwg-N",
          "no": "https://youtu.be/sJzqdEmz1t0?si=wyIAEyIGpuM9qhjf",
          "es": "https://youtu.be/DcZrRRB1EhI?si=Y9NQ852IqpidNbKQ",
          "uk": "https://youtu.be/y0sF5xhGreA?si=x_cOjpG6ewcfC8Qy",
          "ur": "https://youtu.be/npXBm2nvLfI?si=InggmOcKZQV_qkvw"
        }
      }
    ]
  }''';

  // Decode the JSON string into a Map
  Map<String, dynamic> jsonMap = json.decode(jsonData);

  // Convert the JSON map to a VideoUrls instance
  VideoUrls videoUrls = VideoUrls.fromJson(jsonMap);

  // Print out the decoded data
  for (var video in videoUrls.videoUrls) {
    print('Title: ${video.title}');
    video.url.forEach((key, value) {
      print('Language: $key, URL: $value');
    });
  }

  // Convert the VideoUrls instance back to JSON
  String jsonString = json.encode(videoUrls.toJson());
  print('JSON string: $jsonString');
}
