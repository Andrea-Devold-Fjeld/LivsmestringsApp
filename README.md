# livsmestringapp

## Retningslinjer for bruk av GitHub og git.

Andrea Først så vil jeg råde dere til å sette opp ssh og bruke dette når dere kloner repoet.

- [Forklaring om ssh og Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/about-ssh)
- [Sette opp ssh og github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?platform=mac)
Dette er standard å bruke når dere for eksempel jobber.

[En fin liten guide til å bruke git](https://rogerdudler.github.io/git-guide/)

Jeg foreslår denne flyten:

- I møtene våres så lager vi issues i Project tabben i repoet, og tildeler hvem som skal gjøre dette issuet.
    - Jeg forslår att vi nummerer disse issuene så vi starter på 1., så 2. og oppover.
- Når man da starter på dette issuet så flytter man det over til in progress
- Man lager så en branch og i starten av branchnavnet så har man nummeret til issuet.
  - Eksempel:
    - 1-lage-frontend
    - 3-bugfix-med-sertifikater
  - Altså at hver branch har nummeret til issue og en forklarende tittel på hva man gjør i denne branchen
- Når man er ferdig med branchen og vil ha denne inn i Main så forslår jeg følgende:
  - Viktig at man alltid puller main og merger main inn i sin branch slik at man slipper å skrive over noen andre sitt arbeid
  - Man pusher branchen opp til github.
  - Lager en pull request inn til main.
  - Man ber en annen titte over pull requesten og godkjenne dette.
  - Når pull requesten er godkjent så sletter man den gamle branchen.
  - Og da flytter man issuet til done.
### Noen ting jeg synes gjør det lettere å samarbeide på github

1. Man prøver å holde hver branch til ett problem/issue slik at ikke det blir altfor store forskjeller mellom branchen og main.
2. Man rutinemessig puller main og merger den inn i sin branch.
3. Hvis man selv gjør større forandringer i main så gi de andre i gruppen en heads up om at det er lurt å merge main inn i sin branch.

**Det aller viktigste å huske på er att alle gjør feil og det er helt ok.** Jeg har for eksempel vært med på at gruppemedlemmer har slettet hele main og mye annet. Så hvis noe feil skjer eller noe som dere tenker ops slik skulle det ikke være, så bare spør om hjelp og det er ofte lettere å fikse det med engang"!

## Hva som ble gjort for å få prosjektet til å kjøre
Lagd ett nytt prosjekt

Satt Gradle til å være 8.6

Fikse importing
Fra:
````
import 'package:livsmestringsapp/styles/fonts.dart';
````
Til:
````
import '../services/LocaleString.dart';
````

Cached video player som var brukt er ikke oppdatert til nyere versjoner brukte i stedet : 
````
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
````
Og forandret I lib/pages/video_player_page.dart

Fjernet:
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
Og la til:
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

La til assets mappen og la de til i pubspec.yaml

Gjorde kommandoene 
````
$ dart fix —dry-run 
````
og 
````
dart fix —apply
````
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
