import 'dart:io';
import 'package:flutter/material.dart';
import 'result_page.dart';

class OptimizingPage extends StatefulWidget {
  final File file; // Add a file parameter

  // Constructor to accept a file
  OptimizingPage({required this.file});

  @override
  _OptimizingPageState createState() => _OptimizingPageState();
}

class _OptimizingPageState extends State<OptimizingPage> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds and navigate to the ResultPage
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Optimizing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Optimizing your file...'),
          ],
        ),
      ),
    );
  }
}
