import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/config.dart';
import 'package:reminder_calender_app/utils/custom_text_field.dart';
import 'package:reminder_calender_app/settings/presentation/components/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({super.key});

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newUsernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString('username');
    if (currentUsername != null) {
      usernameController.text = currentUsername;
    }
  }

  Future<void> changeUsername() async {
    if (newUsernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data entered in the Text field')),
      );
      return;
    }
    if (newUsernameController.text == usernameController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New username is the same as the current one')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final emailUrl = prefs.getString('email');
    final url = Uri.parse('$updateUsername/$emailUrl');
    var regbody = {'newUsername': newUsernameController.text};
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regbody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setString('username', newUsernameController.text);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated the username successfully')),
        );
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text('Username updating failed')));
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(centerTitle: true, title: Text('Change Username')),
      body: Column(
        children: [
          SizedBox(height: 40),
          CustomTextField(
            controller: usernameController,
            labeltext: '',
            obscureText: false,
            readOnly: true,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 20),
          CustomTextField(
            controller: newUsernameController,
            labeltext: 'New Username',
            obscureText: false,
          ),
          Spacer(),
          CustomButton(onTap: changeUsername),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
