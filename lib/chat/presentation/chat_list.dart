import 'package:flutter/material.dart';
import 'package:reminder_calender_app/chat/presentation/chat_page.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(title: Center(child: Text('Chat List Page'))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              separatorBuilder: (context, index) {
                return Divider(color: Colors.white);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
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
                            'Saiyam Kalra',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
