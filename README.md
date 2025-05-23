# livsmestringapp

# Livsmestringsapp
## Om prosjektet
Project is a bachelor thesis and made in collaboration with OsloMet and Oslo VO Helsfyr.
Project is made in Flutter and is a mobile app for immigrants at Oslo VO Helsfyr. 

The project consists of an app in Fluuter written in dart and a Go HTTP server that serves as a backend for the app. The app

## Run the application

1. [Install Flutter](https://docs.flutter.dev/get-started/install)
2. Clone project
3. Be in the Livsmestringsapp directory
3. Command for getting dependencies the application:
````
flutter pub get
````

I dont know avout VS Code but for Intellij you need to install the Flutter and Dart plugins.
Men man kan enten bruke [Android Studio](https://developer.android.com/studio) (Jeg gjør dette) eller man kan bruke Android Studio pluginen (kan hende det heter noe annet) til Intellij

5. I device manager make sure you have a device running.
    - I have tried runnning it on 24, 25 and iOS
6. Start device
7. Command to run:
````
flutter run
````
Så skal den starte.

## Run the server
1. [Install Go](https://go.dev/doc/install)
2. Be in server directory
3. Command for building server:
````
go build
````
4. Command for running server:
````
go run .
````
## What we did at the start to get the application running
Made new project

Upgraded Gradle to 8.13

Fix imports
From:
````
import 'package:livsmestringsapp/styles/fonts.dart';
````
To:
````
import '../services/LocaleString.dart';
````

Cached video player was deprecated so changed it to this: 
````
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
````
And changes in lib/pages/video_player_page.dart

Removed:
````
Future<void> initializeVideoPlayer() async{
    setState(() {
        isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();

    _cachedVideoPlayerPlusController = CachedVideoPlayerPlusController.network(widget.item.url)
    ..initialize().then((_) {
        setState(() {
            // Add a listener to track video playback progress
            isLoading = false;
        });
    });
    _customVideoPlayerController
    = CustomVideoPlayerController(
    context: context, videoPlayerController: _cachedVideoPlayerController);

}
````
Added:
````
@override
void initState() {
    super.initState();
    //May have to add is loading
    controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.item.url),
        invalidateCacheIfOlderThan: const Duration(days: 69),
        )..initialize().then((value) async {
            controller.play();
            setState(() {});
        });
    //initializeVideoPlayer();
}
````

Added asset folder and added it to pubspec.yaml


Did commandos:
````
$ dart fix —dry-run 
````
og 
````
dart fix —apply
````


