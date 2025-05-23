
import 'dart:developer';
/*
          var hours = int.parse(parts[0]);
          var minutes = int.parse(parts[1]);
          var seconds = int.parse(milliseconds[0]);
          var milliseconds2 = int.parse(milliseconds[1]);

          log("{parts[0]} + " " + ${parts[1]} + " " + ${parts[2]}");
 */
class ParseDuration {
  static Duration? parse(String duration) {
    try {

      final parts = duration.split(':');
      if (parts.length == 3) {
        final milliseconds = parts[2].split('.');
        if(milliseconds.length > 1) {

          return Duration(
            hours: int.parse(parts[0]),
            minutes: int.parse(parts[1]),
            seconds: int.parse(milliseconds[0]),
            microseconds: int.parse(milliseconds[1]),

          );
        }
        else {
          return Duration(
            hours: int.parse(parts[0]),
            minutes: int.parse(parts[1]),
            seconds: int.parse(parts[2]),
          );
        }
      } else if (parts.length == 2) {
        return Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      } else {
        return Duration(seconds: int.parse(duration));
      }


    } catch (e) {
      return null;
    }
  }


  static String format(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitHours = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
  }
}