import 'package:flutter/material.dart';
import 'pages/LoginPage.dart';
import 'pages/history_page.dart';
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
      },
    );
  }
}