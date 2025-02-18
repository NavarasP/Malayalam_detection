import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultPage extends StatefulWidget {
  final File? file; // Optional image file
  final String? resultText; // Processed result

  ResultPage({this.file, this.resultText});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController resultController;
  bool isLoading = false; // To show progress indicator

  @override
  void initState() {
    super.initState();
    resultController = TextEditingController(text: widget.resultText ?? "No result available.");
  }

  Future<void> _saveResult() async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = "https://127.0.0:5000/save";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"note": resultController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Result saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save result. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.file != null) ...[
              Center(
                child: Image.file(widget.file!, height: 200, fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
            ],
            Text('Processed Text:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: resultController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Editable Result',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _saveResult, // Disable button while loading
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Future Share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing not implemented yet!')),
                    );
                  },
                  child: Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
