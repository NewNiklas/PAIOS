import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geminilocal/pages/chat.dart';
import 'package:provider/provider.dart';
import '../../engine.dart';
import 'prompt_editor.dart';

class PromptViewerPage extends StatefulWidget {
  final String promptId;
  const PromptViewerPage({super.key, required this.promptId});
  @override
  PromptViewerPageState createState() => PromptViewerPageState();
}

class PromptViewerPageState extends State<PromptViewerPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Consumer<AIEngine>(builder: (context, engine, child) {
                bool isUserPrompt = engine.promptData.userPrompts.containsKey(widget.promptId);
                String content = engine.promptData.getPromptContent(widget.promptId);
                
                return Scaffold(
                  appBar: AppBar(
                    leading: Padding(
                      padding: EdgeInsetsGeometry.only(left: 5),
                      child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_rounded)
                      ),
                    ),
                    surfaceTintColor: Colors.transparent,
                    title: Text(engine.promptData.getPromptName(widget.promptId)),
                    actions: [
                      if (isUserPrompt)
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => PromptEditorPage(promptId: widget.promptId),
                                  settings: const RouteSettings(name: 'PromptEditorPage')),
                            );
                          },
                          icon: Icon(Icons.edit_rounded),
                          tooltip: engine.dict.value("edit"),
                        )
                      else
                        IconButton(
                          onPressed: () async {
                            await engine.promptData.cloneDefaultPrompt(widget.promptId);
                            // Get the most recently cloned prompt keys
                            String clonedId = engine.promptData.userPrompts.keys.last;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => PromptEditorPage(promptId: clonedId),
                                  settings: const RouteSettings(name: 'PromptEditorPage')),
                            );
                          },
                          icon: Icon(Icons.copy_rounded),
                          tooltip: engine.dict.value("clone_prompt"),
                        ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {
                      engine.currentChat = "testing";
                      engine.contextSize = 0;
                      engine.context.clear();
                      engine.chats["testing"] = {"promptId": widget.promptId, "name": "Testing Prompt"};
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage(),
                            settings: const RouteSettings(name: 'ChatPage')),
                      );
                    },
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    label: Text(engine.dict.value("try_prompt")),
                  ),
                  body: content.isEmpty 
                    ? Center(child: Text("Empty prompt"))
                    : Markdown(
                        data: content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                           p: TextStyle(fontSize: 16),
                        ),
                      ),
                );
              });
            }
        )
    );
  }
}
