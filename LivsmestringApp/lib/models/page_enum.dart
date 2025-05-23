

enum Pages{
  home,
  career,
  health,
  language,
}

extension PageIndexExtension on Pages {
  int get index {
    switch (this) {
      case Pages.home:
        return 0;
      case Pages.career:
        return 1;
      case Pages.health:
        return 2;
      case Pages.language:
        return 3;
    }
  }

  set index(int index) {
    switch (index) {
      case 0:
        Pages.home;
        break;
      case 1:
        Pages.career;
        break;
      case 2:
        Pages.health;
        break;
      case 3:
        Pages.language;
        break;
    }
  }

  String get name {
    switch (this) {
      case Pages.home:
        return 'home';
      case Pages.career:
        return 'career';
      case Pages.health:
        return 'health';
      case Pages.language:
        return 'language';
    }
  }

}