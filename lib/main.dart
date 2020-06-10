import 'package:flutter/material.dart';
import 'package:psenotifier/screens/watchlist_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black87,
        appBarTheme: AppBarTheme(
          color: Colors.black87,
        ),
      ),
      home: WatchlistScreen(title: 'PSE Notifier'),
//      home: WatchlistScreen(title: 'PSE Notifier'),
    );
  }
}
