import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'optimizing_page.dart';

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
        Uri.parse('http://127.0.0.1:5000/process'), // Change to your actual API URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      // Close loading screen before navigating
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Navigate to OptimizingPage with result
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OptimizingPage(file: file, result: jsonResponse),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _captureAndUploadImage(context),
            child: Text('Capture & Upload'),
          ),
        ],
      ),
    );
  }
}
