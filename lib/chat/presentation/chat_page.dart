import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/chat/presentation/components/delete_alert_box.dart';
import 'package:reminder_calender_app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:reminder_calender_app/utils/custom_text_field.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiveEmail;
  const ChatPage({
    super.key,
    required this.receiverName,
    required this.receiveEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  String? myEmail;

  @override
  void initState() {
    super.initState();
    _loadMyEmail();
    markAsRead();
  }

  Future<void> _loadMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    // final myEmail = prefs.getString('email');
    setState(() {
      myEmail = prefs.getString('email');
    });
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');
    final receiverEmail = widget.receiveEmail;
    final uri = Uri.parse(fetchMessages).replace(
      queryParameters: {
        'senderEmail': senderEmail,
        'receiverEmail': receiverEmail,
      },
    );
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 400) {
      throw Exception('No data present to fetch');
    }
    final res = jsonDecode(response.body);
    final List<dynamic> messagesJson = res['messages'];
    final List<Map<String, dynamic>> messageData = messagesJson
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return messageData;
  }

  Future<void> postMessages() async {
    if (messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please type a message")));
    }
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');
    final receiverEmail = widget.receiveEmail;
    final uri = Uri.parse(messages);
    var regbody = {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': messageController.text.trim(),
    };
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(regbody),
    );
    if (response.statusCode == 400) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('data is not stored')));
      if (!mounted) {
        messageController.clear();
      }
      return;
    } else {
      if (kDebugMode) {
        print('Message updated successfully');
      }
      messageController.clear();
      setState(() {});
      return;
    }
  }

  Future<void> markAsRead() async {
    final receiverEmail = widget.receiveEmail;
    final uri = Uri.parse(markRead);
    final prefs = await SharedPreferences.getInstance();
    final List<String>? messageIds = prefs.getStringList('_id');
    if (messageIds == null) {
      return;
    }
    var reqbody = {
      "senderEmail": myEmail,
      "receiverEmail": receiverEmail,
      "messageIds": messageIds,
    };

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reqbody),
    );
    if (response.statusCode == 400) {
      if (kDebugMode) {
        print('Error: data not found');
      }
    } else if (response.statusCode == 200) {
      if (kDebugMode) {
        print('data updated successfully');
      }
    } else {
      if (kDebugMode) {
        print(
          'Error: Failed to mark messages as read with status code ${response.statusCode}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 20, child: Icon(Icons.person)),
            SizedBox(width: 15),
            Text(widget.receiverName),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 51, 51, 51),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.green[300]),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (snapshot.data!.isEmpty || !snapshot.hasData) {
                  return Center(
                    child: const Text(
                      'Start a Conversation',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final messages = snapshot.data!;
                return ListView.separated(
                  // reverse: true,
                  itemCount: messages.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 2);
                  },
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderEmail'] == myEmail;
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeleteAlertBox(
                              messageId: msg['_id'],
                              onMessageDeleted: () {
                                setState(() {});
                              },
                            );
                          },
                        );
                      },
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,

                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[300] : Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['message'] ?? '',
                            style: const TextStyle(color: Colors.white),
                            softWrap: true,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Spacer(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    postMessages();
                  },
                  child: Icon(Icons.send, color: Colors.green[300]),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'messages',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
