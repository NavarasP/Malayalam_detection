import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  TextEditingController resultController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add prefilled result text
    resultController.text = "ഇതിനോടനുബന്ധിച്ച് വസതിയിൽ വച്ചു നടത്തുന്ന...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: resultController,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Editable Result',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add save functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Result saved!')),
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
