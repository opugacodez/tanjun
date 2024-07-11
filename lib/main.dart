import 'package:flutter/material.dart';
import 'package:yt_downloader/view/home_view.dart';

void main() {
  runApp(const MyApp());
}

/// A [MyApp] widget which is the root of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanjun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeView(),
    );
  }
}