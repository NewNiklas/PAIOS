import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:geminilocal/pages/settings.dart';
import 'package:provider/provider.dart';
import '../engine.dart';
import '../elements.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class chatPage extends StatefulWidget {
  const chatPage({super.key});
  @override
  chatPageState createState() => chatPageState();
}

class chatPageState extends State<chatPage> {
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
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.settings_rounded),
                      onPressed: (){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const settingsPage()),
                        );
                      },
                    ),
                    body: SafeArea(
                      child: Column(
                        children: [
                          cards.cardGroup([
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
                            cardContents.addretract(
                                title: engine.dict.value("temperature"),
                                subtitle: engine.temperature.toStringAsFixed(1),
                                actionAdd: (){
                                  if(engine.temperature < 0.9){
                                    setState(() {
                                      engine.temperature = engine.temperature + 0.1;
                                    });
                                  }
                                },
                                actionRetract: (){
                                  if(engine.temperature > 0.1){
                                    setState(() {
                                      engine.temperature = engine.temperature - 0.1;
                                    });
                                  }
                                }
                            ),
                            cardContents.addretract(
                                title: engine.dict.value("tokens"),
                                subtitle: engine.tokens.toString(),
                                actionAdd: engine.tokens > 225?(){}:(){
                                  setState(() {
                                    engine.tokens = engine.tokens + 32;
                                  });
                                },
                                actionRetract: engine.tokens < 63?(){}:(){
                                  setState(() {
                                    engine.tokens = engine.tokens - 32;
                                  });
                                }
                            )
                          ]),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20
                            ),
                            child: TextField(
                              controller: engine.instructions,
                              decoration: InputDecoration(
                                labelText: engine.dict.value("instructions"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                hintText: engine.dict.value("instructions_hint"),
                                helperText: engine.dict.value("ai_may_not_differ_prompt_and_instructions"),
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20
                            ),
                            child: TextField(
                              controller: engine.prompt,
                              onChanged: (text){setState(() {});},
                              decoration: InputDecoration(
                                labelText: engine.dict.value("prompt"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                hintText: engine.dict.value("prompt_hint"),
                                helperText: engine.dict.value("no_context_yet"),
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),
                          engine.isLoading
                              ? cards.cardGroup([cardContents.tap(
                            title: engine.dict.value("cancel_generate"),
                            subtitle: engine.isInitialized
                                ? engine.responseText==""
                                  ? ""
                                  : engine.isError
                                    ? ""
                                    : engine.dict.value("generating_hint").replaceAll("%seconds%", ((engine.response.generationTimeMs??10)/1000).toStringAsFixed(2)).replaceAll("%tokens%", engine.response.tokenCount.toString()).replaceAll("%tokenspersec%", (engine.response.tokenCount!.toInt()/((engine.response.generationTimeMs??10)/1000)).toStringAsFixed(2))
                                : "",
                            action: (){engine.cancelGeneration();}
                          )])
                              : engine.prompt.text.isEmpty?Container():cards.cardGroup([
                            cardContents.tap(
                              title: engine.dict.value("generate"),
                              subtitle: engine.isInitialized
                                  ? engine.responseText==""
                                    ? ""
                                    : engine.isError
                                      ? ""
                                      : engine.dict.value("generated_hint").replaceAll("%seconds%", ((engine.response.generationTimeMs??10)/1000).toStringAsFixed(2)).replaceAll("%tokens%", engine.response.tokenCount.toString()).replaceAll("%tokenspersec%", (engine.response.tokenCount!.toInt()/((engine.response.generationTimeMs??10)/1000)).toStringAsFixed(2))
                                  : "",
                              action: (){engine.generateStream();},
                            )
                          ]),
                          if (engine.responseText.isNotEmpty)
                            Expanded(
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(30)
                                  ),
                                ),
                                color: Theme.of(context).colorScheme.onPrimaryFixed,
                                child: Container(
                                  width: scaffoldWidth - 30,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                          horizontal: 20
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          MarkdownBody(
                                            data: engine.responseText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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