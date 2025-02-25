// Define model classes for the JSON structure
import 'dart:convert';

class VideoUrlsResponse {
  final List<VideoUrl> videoUrls;

  VideoUrlsResponse({required this.videoUrls});

  factory VideoUrlsResponse.fromJson(Map<String, dynamic> json) {
    return VideoUrlsResponse(
      videoUrls: (json['VideoUrls'] as List)
          .map((item) => VideoUrl.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VideoUrls': videoUrls.map((video) => video.toJson()).toList(),
    };
  }
}

class VideoUrl {
  final String title;
  final List<LanguageUrl> languages;

  VideoUrl({required this.title, required this.languages});

  factory VideoUrl.fromJson(Map<String, dynamic> json) {
    return VideoUrl(
      title: json['Title'],
      languages: (json['Language'] as List)
          .map((item) => LanguageUrl.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Language': languages.map((lang) => lang.toJson()).toList(),
    };
  }
}

class LanguageUrl {
  final String language;
  final String url;

  LanguageUrl({required this.language, required this.url});

  factory LanguageUrl.fromJson(Map<String, dynamic> json) {
    return LanguageUrl(
      language: json['Language'],
      url: json['Url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Language': language,
      'Url': url,
    };
  }
}

// Example usage
void exampleUsage() {
  /*
  // Parse JSON string to model objects
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  final response = VideoUrlsResponse.fromJson(jsonMap);

  // Access data
  for (var video in response.videoUrls) {
    print('Video title: ${video.title}');
    for (var lang in video.languages) {
      print('  Language: ${lang.language}, URL: ${lang.url}');
    }
  }

  // Convert model objects back to JSON
  final jsonOutput = jsonEncode(response.toJson());

   */
}