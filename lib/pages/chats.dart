import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geminilocal/pages/chat.dart';
import 'package:geminilocal/pages/settings/model.dart';
import 'package:geminilocal/pages/settings/resources.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../engine.dart';
import 'support/elements.dart';
import 'package:intl/intl.dart';


class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});
  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              Cards cards = Cards(context: context);
              return Consumer<AIEngine>(builder: (context, engine, child) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add_rounded),
                    tooltip: engine.dict.value("start_chat"),
                    onPressed: (){
                      engine.currentChat = "0";
                      engine.context.clear();
                      engine.contextSize = 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
                  ),
                  body: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar.large(
                        surfaceTintColor: Colors.transparent,
                        leading: Padding(
                          padding: EdgeInsetsGeometry.only(left: 5),
                          child: IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_rounded)
                          ),
                        ),
                        title: Text(engine.dict.value("chats")),
                        pinned: true,
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            divider.settings(
                                title: engine.dict.value("your_chats"),
                                context: context
                            ),
                            cards.cardGroup(
                                engine.chats.keys.toList().map((key){
                                  Map chat = engine.chats[key]??{
                                    "name": "Nonameyet",
                                    "history": {},
                                    "created": DateTime.now().millisecondsSinceEpoch.toString(),
                                    "updated": DateTime.now().millisecondsSinceEpoch.toString()
                                  };
                                  return CardContents.tap(
                                      title: chat["name"]??"Loading...",
                                      subtitle: chat["updated"],
                                      action: () async {
                                        print("I have chats: ${engine.chats.keys}");
                                        engine.isLoading = false;
                                        engine.context.clear();
                                        engine.contextSize = 0;
                                        engine.context = jsonDecode(chat["history"]);
                                        engine.currentChat = key;
                                        print("Loading chat $key: $chat");
                                        print("Context: ${engine.context}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ChatPage()),
                                        );
                                      }
                                  );
                                }).toList().cast<Widget>()
                            )
                          ],
                        ),
                      ),
                    ],

                  ),
                );
              });
            }
        )
    );
  }
}