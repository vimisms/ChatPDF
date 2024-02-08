import 'dart:convert';
import 'dart:typed_data';
import 'package:documenthelper/Message.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lean_file_picker/lean_file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:documenthelper/prompts.dart';
import 'package:azstore/azstore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;
  // FilePickerResult? result;

  void sendMsg() async {
    String text = controller.text;
    print(text);
    String apiKey = "[HIDDEN]";
    controller.clear();
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
        //scrollController.jumpTo(scrollController.position.maxScrollExtent);
        var response = await http.post(
            Uri.parse("https://neo-ai-test.openai.azure.com/openai/deployments/neo-gpt-16k-test/extensions/chat/completions?api-version=2023-07-01-preview&api-key=[HIDDEN]"),
            headers: {
              "Content-Type": "application/json"
            },
            body: jsonEncode({
              "temperature": 0,
              "max_tokens": 100,
              "top_p": 1.0,
              "dataSources": [
                {
                  "type": "AzureCognitiveSearch",
                  "parameters": {
                    "endpoint": "https://neo-hackapp-search.search.windows.net",
                    "key": "[HIDDEN]",
                    "indexName": "vector-1707291805588",
                    "queryType": "vectorSemanticHybrid",
                    "inScope": true,
                    "roleInformation": "You are an intelligent bot who provides response in summarized way.",
                    "filter": null,
                    "strictness": 3,
                    "topNDocuments": 5,
                    "embeddingDeploymentName": "neo-embedding",
                    "semanticConfiguration": "vector-1707291805588-semantic-configuration",
                    "fieldsMapping": {
                      "contentFieldsSeparator": "\n",
                      "contentFields": [
                        "chunk"
                      ],
                      "filepathField": null,
                      "titleField": "title",
                      "urlField": null,
                      "vectorFields": [
                        "vector"
                      ]
                    },
                  }
                }
              ],
              "messages": [
                prompts[0],
                prompts[1],
                prompts[2],
                prompts[3],
                prompts[4],
                prompts[5],
                prompts[6],
                {
                  "role": "user",
                  "content": text
                }
              ]
            }));
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          print(json);
          print(prompts[0]);
          setState(() {
            isTyping = false;
            msgs.insert(
                0,
                Message(
                    false,
                    json["choices"][0]["messages"][1]["content"].toString().trimLeft()));
          });
          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred, please try again!")));
    }
  }

  void showReport() async {
    showModalBottomSheet(
        context: context,
        builder: (context){
          return SfPdfViewer.network(
            'https://neohackappstg.blob.core.windows.net/searchapipdf/apidocument.pdf?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2024-12-31T17:08:38Z&st=2024-02-06T09:08:38Z&spr=https&sig=Zqs3kFS%2Bew%2Fe7JUyIIBGtxTa4VmWhG%2BZRrpjwIXDVns{SKEWED}',
            key: _pdfViewerKey,
          );
        }
    );
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text("ChatPDF"),
        actions: [
          ElevatedButton(
              onPressed: () async {
                final result = await pickFile(
                allowedExtensions: ['pdf'],
                    allowedMimeTypes: ['application/pdf']
            );
            if (result == null) {
              print("No file selected");
            }
         else {
              setState(() {});
              try {
                var storage = AzureStorage.parse(
                    'DefaultEndpointsProtocol=https;AccountName=neohackappstg;AccountKey=LtNM861q1FaYha/rUlFzzQ/boF9fhaYn0OMNgfqUYuEhtSQdhB6XLu0QWGUGvFysyGmEzeM6GiU4+AStm1i{SKEWED}');
                print(storage);
                String container = "searchapipdf";
                String contentType = 'application/pdf';
                String filePath = result.path;
                String fileName = 'apidocument.pdf';
                print(fileName);
                Uint8List content = await result.readAsBytes();

                //First delete the exisiting BLOBs
                try {
                  await storage.deleteBlob('/searchapipdf/$fileName');
                  print('done deleting');
                }catch(e){
                  print('exception: $e');
                }
                await storage.putBlob(
                    '/$container/$fileName', bodyBytes: content,
                    contentType: contentType,
                    type: BlobType.blockBlob);
                print("done");
              }on AzureStorageException catch(ex){
                print(ex.message);
              }catch(err){
                print(err);
              }

              //Run the indexer

              var indres = await http.post(
                  Uri.parse("https://neo-hackapp-search.search.windows.net/indexers('vector-1707291805588-indexer')/search.run?api-version=2023-11-01"),
                  headers: {"api-key": "[HIDDEN]"},
              );
              print('Running the indexer');
              print(indres.statusCode);

            }
          }, child: Icon(Icons.add)),
          ElevatedButton(
              onPressed:showReport,
              child: const Icon(Icons.remove_red_eye))
        ],
      ),
      body: Container(
        color: Colors.grey.shade800,
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: msgs.length,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: isTyping && index == 0
                            ? Column(
                          children: [
                            BubbleNormal(
                              text: msgs[0].msg,
                              isSender: true,
                              color: Colors.blue,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 4),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Gathering details...",
                                  style: TextStyle(
                                    color: Colors.pinkAccent,
                                    fontSize: 20.0,
                                  ),
                                  )),
                            )
                          ],
                        )
                            : BubbleNormal(
                          text: msgs[index].msg,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          isSender: msgs[index].isSender,
                          color: msgs[index].isSender
                              ? Colors.blueAccent
                              : Colors.green
                        ));
                  }),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: controller,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (value) {
                            sendMsg();
                          },
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          showCursor: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Type a question related to uplaoded PDF"),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    sendMsg();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
