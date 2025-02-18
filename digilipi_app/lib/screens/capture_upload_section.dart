import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'result_page.dart'; 

class CaptureUploadSection extends StatefulWidget {
  @override
  _CaptureUploadSectionState createState() => _CaptureUploadSectionState();
}

class _CaptureUploadSectionState extends State<CaptureUploadSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureAndUploadImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return; // User canceled the capture

    File file = File(image.path);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Upload image to API
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://164.92.97.108:5000/api/upload'), 
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Navigate to ResultPage with the result from API
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              file: file, 
              resultText: jsonResponse["string"], // Pass the processed result text
            ),
          ),
        );
      } else {
        _showErrorDialog(context, 'Processing failed');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, 'Error uploading file: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture & Upload'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _captureAndUploadImage(context),
          child: Text('Capture & Upload'),
        ),
      ),
    );
  }
}
