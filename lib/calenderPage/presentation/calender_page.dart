import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/config.dart';
import 'package:reminder_calender_app/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  String? username;

  @override
  void initState() {
    super.initState();
    getUserNameAndSignIn();
  }

  Future<void> getUserNameAndSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('$getData/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('User data response: $data');
        }

        if (data["status"] == true) {
          final user = data["user"];

          // Save user details locally
          await prefs.setString("userId", user["id"]);
          await prefs.setString("username", user["username"]);
          await prefs.setString("email", user["email"]);

          // Update state so UI refreshes
          setState(() {
            username = user["username"];
          });

          if (kDebugMode) {
            print("Saved user: ${user["username"]} (${user["id"]})");
          }
        } else {
          if (kDebugMode) {
            print("Fetch failed: ${data["message"]}");
          }
        }
      } else {
        if (kDebugMode) {
          print("Server error: ${response.statusCode}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(
        title: const Center(child: Text('Calendar Page')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                child: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          username != null ? "Hello, $username!" : "Hello, User",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
