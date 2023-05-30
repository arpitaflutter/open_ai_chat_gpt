import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_ai_chat_gpt/api/api_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({Key? key}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController txtuser = TextEditingController();
  final SpeechToText speechToTextInstance = SpeechToText();
  String recordedAudioString = "";
  bool isLoading = false;
  bool speak = true;
  String modeOpenAI = "chat";
  String imageUrlFromOpenAi = "";
  String answerTextFromOpenAi = "";
  final TextToSpeech textToSpeechInstance = TextToSpeech();

  void initializeSpeechToText() async {
    await speechToTextInstance.initialize();

    setState(() {});
  }

  void startListeningNow() async {
    FocusScope.of(context).unfocus();
    await speechToTextInstance.listen(onResult: onSpeechToTextResult);

    setState(() {});
  }

  void stopListeningNow() async {
    await speechToTextInstance.stop();
    setState(() {});
  }

  void onSpeechToTextResult(SpeechRecognitionResult recognitionResult) {
    recordedAudioString = recognitionResult.recognizedWords;

    speechToTextInstance.isListening
        ? Null
        : sendRequestToOpenAi(recordedAudioString);
    print("record speech:");
    print(recordedAudioString);
  }

  Future<void> sendRequestToOpenAi(String userInput) async {
    stopListeningNow();

    setState(() {
      isLoading = true;
    });

    await APIservice().requestOpenAi(userInput, modeOpenAI, 2000).then((value) {
      setState(() {
        isLoading = false;
      });

      if (value.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Api key you are?were using expired or it is not working anymore.")));
      }

      txtuser.clear();

      final responseAvailable = jsonDecode(value.body);

      if (modeOpenAI == "chat") {
        setState(() {
          answerTextFromOpenAi = utf8.decode(
              responseAvailable["choices"][0]["text"].toString().codeUnits);

          print("ChatGpt Chatbot");
          print(answerTextFromOpenAi);
        });

        if(speak == true)
          {
            textToSpeechInstance.speak(answerTextFromOpenAi);
          }
      } else {
        setState(() {
          imageUrlFromOpenAi = responseAvailable["data"][0]["url"];

          print("Generate Dale E image:");
          print(imageUrlFromOpenAi);
        });
      }
    }).catchError((errorMessege) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: " + errorMessege.toString())));
    });
  }

  @override
  void initState() {
    super.initState();

    initializeSpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            if(!isLoading)
              {
                setState(() {
                  speak = !speak;
                });
              }

            textToSpeechInstance.stop();
          },
          child: speak ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset("assets/images/sound.png",
                width: 40, color: Colors.cyan.shade700),
          ) : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset("assets/images/mute.png",
                width: 40, color: Colors.cyan.shade700),
          ),
        ),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.shade200,
                  Colors.cyan.shade500,
                  Colors.cyan.shade600,
                ],
              ),
            ),
          ),
          title: Image.asset("assets/images/openAI.png", width: 140),
          elevation: 4,
          titleSpacing: 2,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  modeOpenAI = "chat";
                });
              },
              icon: Icon(
                Icons.chat,
                size: 30,
                color: modeOpenAI == "chat" ? Colors.white : Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  modeOpenAI = "image";
                });
              },
              icon: Icon(Icons.image,
                  size: 30,
                  color: modeOpenAI == "image" ? Colors.white : Colors.grey),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      speechToTextInstance.isListening
                          ? stopListeningNow()
                          : startListeningNow();
                    },
                    child: speechToTextInstance.isListening
                        ? Center(
                            child: LoadingAnimationWidget.beat(
                              size: 300,
                              color: speechToTextInstance.isListening
                                  ? Colors.cyan.shade800
                                  : isLoading
                                      ? Colors.cyan.shade900
                                      : Colors.cyan.shade700,
                            ),
                          )
                        : Image.asset(
                            "assets/images/assistant_icon.png",
                            width: 300,
                            height: 300,
                          ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: txtuser,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("How can I help you?")),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        if (txtuser.text.isNotEmpty) {
                          sendRequestToOpenAi(txtuser.text.toString());
                        }
                      },
                      child: AnimatedContainer(
                        height: 60,
                        width: 60,
                        duration: Duration(microseconds: 1000),
                        curve: Curves.bounceInOut,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.cyan.shade800,
                          shape: BoxShape.rectangle,
                        ),
                        child: Icon(Icons.send, size: 30, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                modeOpenAI == "chat"
                    ? SelectableText(
                        answerTextFromOpenAi,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )
                    : modeOpenAI == "image" && imageUrlFromOpenAi.isNotEmpty
                        ? Column(
                            children: [
                              SizedBox(height: 10,),
                              Image.network(imageUrlFromOpenAi),
                              SizedBox(
                                height: 15,
                              ),
                              // ElevatedButton(
                              //   onPressed: () async {
                              //     String? imageStatus= await ImageDownloader.downloadImage(imageUrlFromOpenAi);
                              //
                              //     if(imageStatus != null)
                              //       {
                              //         ScaffoldMessenger.of(context).showSnackBar(
                              //           SnackBar(content: Text("Image downloaded successfully."))
                              //         );
                              //       }
                              //
                              //     },
                              //   child: Text("Download this image",
                              //       style: TextStyle(color: Colors.white)),
                              //   style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.cyan.shade700),
                              // )
                            ],
                          )
                        : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
