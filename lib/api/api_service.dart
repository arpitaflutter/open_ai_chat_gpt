import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_ai_chat_gpt/apiKey.dart';

class APIservice {
  Future<http.Response> requestOpenAi(
      String userInput, String mode, int maximumTokens) async {
    const String url = "https://api.openai.com/";
    final String OpenAiApiUrl =
        mode == "chat" ? "v1/completions" : "v1/images/generations";

    final body = mode == "chat"
        ? {
            "model": "text-davinci-003",
            "prompt": userInput,
            "max_tokens": 2000,
            "temperature": 0.9,
            "n": 1
          }
        : {
            "prompt": userInput,
          };

    final responseFromOpenAi = await http.post(Uri.parse(url + OpenAiApiUrl),
      headers: {
      "Content-Type": "application/json",
          "Authorization":"Bearer $apiKey"
      },
      body: jsonEncode(body),
    );

    return responseFromOpenAi;
  }
}
