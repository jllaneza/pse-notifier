import 'package:flutter/material.dart';

import 'package:psenotifier/models/alert_list_screen_args.dart';
import 'package:psenotifier/screens/screens.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => WatchlistScreen(),
        '/stock-list': (context) => StockListScreen(),
        '/alert-list': (context) {
          AlertListScreenArgs arguments =
              ModalRoute.of(context).settings.arguments;
          return AlertListScreen(
            price: arguments.price,
            symbol: arguments.symbol,
          );
        },
      },
    );
  }
}
