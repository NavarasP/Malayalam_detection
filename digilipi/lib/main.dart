import 'package:flutter/material.dart';
import 'screens/front_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Name',
      theme: ThemeData(
        primaryColor: Color(0xFF264653), 
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A9D8F),
          elevation: 0,
        ),
      ),
      home: FrontPage(),
    );
  }
}
