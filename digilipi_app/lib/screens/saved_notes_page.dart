import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'capture_upload_section.dart'; 

class SavedNotesPage extends StatefulWidget {
  @override
  _SavedNotesPageState createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  List<String> notes = [
    "പ്രിയരേ",
    "ഇതിനോടനുബന്ധിച്ച് ",
  ];

  // Remove the _captureImage method if not needed anymore

  void _editNoteDialog(int index) {
    TextEditingController noteController =
        TextEditingController(text: notes[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Note"),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Edit your note here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  notes[index] = noteController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Notes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  notes[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editNoteDialog(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to CaptureUploadSection to handle image capture and upload
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaptureUploadSection(),
            ),
          );
        },
        child: Icon(Icons.camera_alt),
        tooltip: 'Capture & Upload',
      ),
    );
  }
}
