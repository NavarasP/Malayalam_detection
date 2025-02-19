import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Loading...";
  String email = "";


Future<void> _fetchProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
int? userId = prefs.getInt("user_id"); // ✅ Correct

  if (userId == null) {
    _showError("Unauthorized. Please log in again.");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    return;
  }

  final url = Uri.parse("http://164.92.97.108:5000/api/get_profile?user_id=$userId");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        username = data["username"] ?? "Unknown User";
        email = data["email"] ?? "No email available";
      });
    } else {
      _showError("Failed to load profile: ${response.body}");
    }
  } catch (e) {
    _showError("Error fetching profile: $e");
  }
}


  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_id");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/profile_picture.png'),
            ),
            SizedBox(height: 20),
            Text(username, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            Divider(height: 40, thickness: 1, color: Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text('Account Details'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.blue),
              title: Text('Help & Support'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Logout', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}