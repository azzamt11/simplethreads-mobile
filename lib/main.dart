import 'package:flutter/material.dart';
import 'package:simple_threads/pages/home/screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}