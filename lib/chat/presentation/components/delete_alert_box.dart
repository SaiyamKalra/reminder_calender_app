import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/config.dart';

class DeleteAlertBox extends StatefulWidget {
  final String messageId;
  final VoidCallback onMessageDeleted;
  const DeleteAlertBox({
    super.key,
    required this.messageId,
    required this.onMessageDeleted,
  });

  @override
  State<DeleteAlertBox> createState() => _DeleteAlertBoxState();
}

class _DeleteAlertBoxState extends State<DeleteAlertBox> {
  Future<void> deleteUserMessage() async {
    final uri = Uri.parse('$deleteMessage/${widget.messageId}');
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        if (response.statusCode == 200) {
          // Message deleted successfully.
          if (mounted) {
            // You might show a snackbar to confirm deletion
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message deleted successfully')),
            );
            widget.onMessageDeleted();
            Navigator.pop(context);
          } else if (response.statusCode == 404) {
            // Message not found on the server
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message not found.')),
              );
            }
          } else {
            // Handle other server errors
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete message.')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        'Are you Sure you want to Delete?',
        style: TextStyle(fontSize: 20),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Color.fromARGB(255, 133, 133, 133),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.green[100])),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Color.fromARGB(255, 133, 133, 133),
              ),
            ),
            onPressed: deleteUserMessage,
            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
