import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ResultPage extends StatefulWidget {
  final File? file;
  final String? resultText;

  ResultPage({this.file, this.resultText});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController resultController;
  bool isLoading = false; // Show progress indicator

  @override
  void initState() {
    super.initState();
    resultController = TextEditingController(text: widget.resultText ?? "No result available.");
  }

void _saveResult() async {
  setState(() {
    isLoading = true;
  });

  final url = Uri.parse("http://164.92.97.108:5000/api/save_note"); // Replace with actual API URL

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"content": resultController.text}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: ${responseData["message"]}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving note: $e')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: resultController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void _shareResult() {
    Share.share(resultController.text);
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
              Center(child: Image.file(widget.file!, height: 200, fit: BoxFit.cover)),
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
                  onPressed: _saveResult, 
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  child: Text('Copy'),
                ),
                ElevatedButton(
                  onPressed: _shareResult,
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
