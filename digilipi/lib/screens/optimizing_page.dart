import 'dart:io';
import 'package:flutter/material.dart';
import 'result_page.dart';

class OptimizingPage extends StatefulWidget {
  final File file;
  final Map<String, dynamic> result; // Processed result from API

  OptimizingPage({required this.file, required this.result});

  @override
  _OptimizingPageState createState() => _OptimizingPageState();
}

class _OptimizingPageState extends State<OptimizingPage> {
  @override
  void initState() {
    super.initState();
    // Simulating processing delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(file: widget.file, result: widget.result),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Processing...')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Processing your file... Please wait.'),
          ],
        ),
      ),
    );
  }
}
