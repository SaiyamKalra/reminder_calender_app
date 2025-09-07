import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/config.dart';
import 'package:reminder_calender_app/utils/custom_text_field.dart';
import 'package:reminder_calender_app/settings/presentation/components/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> changePassword() async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter data in both the fields')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    if (email == null) {
      return;
    }
    final regbody = {'newPassword': confirmPasswordController.text};
    try {
      if (passwordController.text == confirmPasswordController.text) {
        final uri = Uri.parse('$updatePassword/$email');
        final response = await http.patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(regbody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully')),
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
          ).showSnackBar(SnackBar(content: Text('Password update failed')));
          if (mounted) {
            Navigator.pop(context);
          }
          return;
        }
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(centerTitle: true, title: Text('Change Password')),
      body: Column(
        children: [
          SizedBox(height: 40),
          CustomTextField(
            controller: passwordController,
            labeltext: 'New Password',
            obscureText: true,
            // readOnly: true,
            // color: Colors.grey.shade600,
          ),
          SizedBox(height: 20),
          CustomTextField(
            controller: confirmPasswordController,
            labeltext: 'Confirm Password',
            obscureText: true,
          ),
          Spacer(),
          CustomButton(onTap: changePassword),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
