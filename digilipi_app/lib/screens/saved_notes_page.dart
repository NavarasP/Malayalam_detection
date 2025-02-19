import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digilipi_app/screens/result_page.dart';

class SavedNotesPage extends StatefulWidget {
  @override
  _SavedNotesPageState createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  List<Map<String, dynamic>> notes = [];
  final ImagePicker _picker = ImagePicker();
  String apiUrl = 'http://164.92.97.108:5000/api';
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
    if (userId != null) {
      _fetchNotes();
    }
  }

  Future<void> _fetchNotes() async {
    if (userId == null) return;

    final response = await http.get(Uri.parse('$apiUrl/get_notes'));
    
    if (response.statusCode == 200) {
      setState(() {
        notes = List<Map<String, dynamic>>.from(json.decode(response.body)['notes']);
      });
    } else {
      _showErrorDialog('Failed to fetch notes');
    }
  }

  void _editNoteDialog(int index) {
    TextEditingController noteController = TextEditingController(text: notes[index]['content']);

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
              onPressed: () async {
                await _updateNote(notes[index]['id'], noteController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNote(int noteId, String content) async {
    final response = await http.post(
      Uri.parse('$apiUrl/save_note'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': noteId, 'content': content}),
    );
    
    if (response.statusCode == 200) {
      _fetchNotes();
    } else {
      _showErrorDialog('Failed to update note');
    }
  }
Future<void> _captureAndUploadImage(BuildContext context) async {
  final ImageSource? source = await _showImageSourceDialog(context);
  if (source == null) return; 

  final XFile? image = await _picker.pickImage(source: source);
  if (image == null) {
    print("No image selected.");
    return;
  }

  File file = File(image.path);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  try {
    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/predict_text'));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseBody);
    

    Navigator.pop(context);

    if (response.statusCode == 200) {
  String extractedText = jsonResponse["text"] ?? "No text extracted.";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(file: file, resultText: extractedText),
        ),
      );
    } else {
      _showErrorDialog('Processing failed');
    }
  } catch (e) {
    Navigator.pop(context);
    _showErrorDialog('Error uploading file: $e');
  }
}

Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}


  void _showErrorDialog(String message) {
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
      appBar: AppBar(title: Text('Saved Notes'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  notes[index]['content'],
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
        onPressed: () => _captureAndUploadImage(context),
        child: Icon(Icons.camera_alt),
        tooltip: 'Capture & Upload',
      ),
    );
  }
}
