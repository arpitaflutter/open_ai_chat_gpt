import 'package:flutter/material.dart';
import 'package:open_ai_chat_gpt/screens/home_screen.dart';

void main()
{
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => homeScreen(),
      },
    ),
  );
}