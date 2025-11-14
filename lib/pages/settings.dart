import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../engine.dart';
import '../elements.dart';


class settingsPage extends StatefulWidget {
  const settingsPage({super.key});
  @override
  settingsPageState createState() => settingsPageState();
}

class settingsPageState extends State<settingsPage> {
  @override
  @override
  void initState() {
    super.initState();
  }
  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  @override
  Widget build(BuildContext context) {
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    ThemeData _themeData (colorSheme){
      return ThemeData(
        colorScheme: colorSheme,
        cardTheme: CardThemeData(
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.hardEdge
        ),
        useMaterial3: true,
      );
    }
    TextStyle blacker = const TextStyle(
        color: Colors.black
    );
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
          theme: _themeData(lightColorScheme ?? _defaultLightColorScheme).copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  // Use PredictiveBackPageTransitionsBuilder to get the predictive back route transition!
                  TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                },
              ),
              cardColor: Colors.grey,
              iconTheme: const IconThemeData(
                  color: Colors.black
              ),
              textTheme: TextTheme(
                  displayLarge: blacker,
                  displayMedium: blacker,
                  displaySmall: blacker,
                  headlineLarge: blacker,
                  headlineMedium: blacker,
                  headlineSmall: blacker,
                  titleLarge: blacker,
                  titleMedium: blacker,
                  titleSmall: blacker,
                  bodyLarge: blacker,
                  bodyMedium: blacker,
                  bodySmall: blacker,
                  labelLarge: blacker,
                  labelMedium: blacker,
                  labelSmall: blacker
              )
          ),
          darkTheme: _themeData(darkColorScheme ?? _defaultDarkColorScheme),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scaffoldHeight = constraints.maxHeight;
                double scaffoldWidth = constraints.maxWidth;
                Cards cards = Cards(context: context);
                return Consumer<aiEngine>(builder: (context, engine, child) {
                  return Scaffold(
                    body: CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar.large(
                          surfaceTintColor: Colors.transparent,
                          title: Text(engine.dict.value("settings")),
                          pinned: true,
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              cards.cardGroup([
                                cardContents.static(
                                    title: "Gemini Nano ${
                                        engine.modelInfo["version"] == null
                                            ? engine.dict.value("unavailable")
                                            : engine.modelInfo["version"] == "Unknown"
                                            ? engine.dict.value("unavailable")
                                            : engine.dict.value("available")
                                    }",
                                    subtitle: engine.modelInfo["version"] == null
                                        ? ""
                                        : engine.modelInfo["version"] == "Unknown"
                                        ? ""
                                        : engine.dict.value("model_available").replaceAll("%s", engine.modelInfo["version"])
                                ),
                                cardContents.longTap(
                                    title: engine.dict.value("select_language"),
                                    subtitle: engine.dict.value("select_language_auto_long"),
                                    action: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext dialogContext) =>
                                            AlertDialog(
                                              contentPadding: EdgeInsets.only(
                                                top: 10,
                                                bottom: 15,
                                              ),
                                              titlePadding: EdgeInsets.only(
                                                  top: 20,
                                                  right: 20,
                                                  left: 20
                                              ),
                                              title: Text(engine.dict.value("select_language")),
                                              content: SingleChildScrollView(
                                                  child: cards.cardGroup(
                                                      engine.dict.languages.map((language) {
                                                        return cardContents.tap(
                                                            title: language["origin"],
                                                            subtitle: language["name"] == language["origin"] ? "" : language["name"],
                                                            action: () async {
                                                              setState(() {
                                                                engine.dict.locale = language["id"];
                                                              });
                                                              Navigator.of(dialogContext).pop();
                                                            }
                                                        );
                                                      }).toList().cast<Widget>()
                                                  )
                                              ),
                                            ),
                                      );
                                    },
                                    longAction: (){
                                      setState(() {
                                        engine.dict.setSystemLanguage();
                                      });
                                    }
                                ),
                                cardContents.tap(
                                    title: engine.dict.value("open_aicore_settings"),
                                    subtitle: engine.dict.value("in_play_store"),
                                    action: () async {
                                      engine.checkAICore();
                                    }
                                ),
                                cardContents.tap(
                                    title: engine.dict.value("gh_repo"),
                                    subtitle: engine.dict.value("tap_to_open"),
                                    action: () async {
                                      await launchUrl(
                                          Uri.parse('https://github.com/Puzzaks/geminilocal'),
                                          mode: LaunchMode.externalApplication
                                      );
                                    }
                                ),
                                cardContents.tap(
                                    title: engine.dict.value("documentation"),
                                    subtitle: engine.dict.value("tap_to_open"),
                                    action: () async {
                                      await launchUrl(
                                          Uri.parse('https://developers.google.com/ml-kit/genai#prompt-device')
                                      );
                                    }
                                )
                              ]),
                              Padding(
                                padding: EdgeInsetsGeometry.only(
                                    bottom: 50,
                                    left: 20,
                                    right: 20,
                                    top: 10
                                ),
                                child: Container(
                                  width: scaffoldWidth - 40,
                                  child: engine.modelInfo["version"] == null
                                      ? Text(engine.dict.value("welcome_unavailable"))
                                      : engine.modelInfo["version"] == "Unknown"
                                      ? Text(engine.dict.value("welcome_unavailable"))
                                      : Text(engine.dict.value("welcome_available")),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                    ),
                  );
                  return Scaffold(
                    body: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all((scaffoldWidth - scaffoldWidth/4)/2),
                              child: Icon(
                                Icons.assistant_rounded,
                                size: scaffoldWidth/4,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 30
                              ),
                              child: Container(
                                width: scaffoldWidth - 60,
                                child: engine.modelInfo["version"] == null
                                    ? Text(
                                    "This application allows you have conversations with your on-device model of Gemini Nano. It is free and offline, but Gemini Nano is the smallest of Gemini family. Unfortunately either your device doesn't support Gemini Nano or the Google AICore is unavailable to the app. This may be because your device has it's bootloader unlocked or the app"
                                )
                                    : Text(
                                    "Your on-device AI is here."
                                ),
                              ),
                            ),
                            Text(engine.dict.value("welcome_desc")),
                            cards.cardGroup([
                              cardContents.static(
                                  title: "Gemini ${engine.modelInfo["version"] == null?"is unavailable":engine.modelInfo["version"]}",
                                  subtitle: "Google AICore reports it is ${engine.modelInfo["status"] == null?"Unavailable":engine.modelInfo["status"].toString().toLowerCase()}"
                              )
                            ])
                          ],
                        ),
                      ),
                    ),
                  );
                });
              }
          )
      );
    });
  }
}