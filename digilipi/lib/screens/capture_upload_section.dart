import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'optimizing_page.dart';

class CaptureUploadSection extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              // Capture image directly from the camera
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                // Navigate to OptimizingPage with the captured file
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OptimizingPage(file: File(image.path)),
                  ),
                );
              }
            },
            child: Text('Capture File'),
          ),
        ],
      ),
    );
  }
}
