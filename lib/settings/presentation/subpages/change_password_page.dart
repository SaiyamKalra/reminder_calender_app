import 'package:flutter/material.dart';
import 'package:reminder_calender_app/auth/presentation/components/custom_text_field.dart';
import 'package:reminder_calender_app/settings/presentation/components/custom_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newUsernameController = TextEditingController();

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
            labeltext: 'Current Password',
            obscureText: false,
          ),
          SizedBox(height: 20),
          CustomTextField(
            controller: newUsernameController,
            labeltext: 'New Password',
            obscureText: false,
          ),
          Spacer(),
          CustomButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
