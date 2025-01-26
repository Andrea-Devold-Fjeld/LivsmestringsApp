
class VideoItem {
  String _title;
  String _url;
  VideoItem? _nextItem;

  VideoItem({
    required String title,
    required String url,
    required VideoItem? nextItem,
  })   : _title = title,
        _url = url,
        _nextItem = nextItem;

  String get title => _title;

  set title(String title) {
    _title = title;
  }

  String get url => _url;

  set url(String url) {
    _url = url;
  }

  VideoItem? get nextItem => _nextItem;

  set nextItem(VideoItem? nextItem) {
    _nextItem = nextItem;
  }
}
