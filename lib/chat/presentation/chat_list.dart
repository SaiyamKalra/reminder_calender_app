// import 'dart:convert';

import 'dart:convert';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/chat/presentation/chat_page.dart';
import 'package:reminder_calender_app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Future<List<Map<String, dynamic>>> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final uri = Uri.parse('$fetchUsername/$email');
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch usernames');
    }
    final body = jsonDecode(response.body);
    final List<dynamic> userJson = body['data'];
    return userJson
        .map(
          (e) => {
            'username': (e['username'] ?? 'Unknown User') as String,
            'email': (e['email'] ?? 'No Email') as String,
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(title: Center(child: Text('Chat List Page'))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final user = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: user.length,
              separatorBuilder: (context, index) {
                return Divider(color: Colors.white);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverName: user[index]['username'],
                          receiveEmail: user[index]['email'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person, size: 30),
                          ),
                          SizedBox(width: 20),
                          Text(
                            user[index]['username'],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
