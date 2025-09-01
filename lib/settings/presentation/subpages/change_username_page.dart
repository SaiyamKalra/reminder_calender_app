import 'package:flutter/material.dart';
import 'package:reminder_calender_app/auth/presentation/components/custom_text_field.dart';
import 'package:reminder_calender_app/settings/presentation/components/custom_button.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({super.key});

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
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
            labeltext: 'Current Username',
            obscureText: false,
          ),
          SizedBox(height: 20),
          CustomTextField(
            controller: newUsernameController,
            labeltext: 'New Username',
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
