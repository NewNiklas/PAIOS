import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine.dart';
import '../elements.dart';
import '../translator.dart';


class introPage extends StatefulWidget {
  const introPage({super.key});
  @override
  introPageState createState() => introPageState();
}

class introPageState extends State<introPage> {
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
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(scaffoldWidth/4),
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