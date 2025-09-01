import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/auth/presentation/components/custom_text_field.dart';
import 'package:reminder_calender_app/auth/presentation/sign_in_page.dart';
// import 'package:reminder_calender_app/auth/presentation/sign_in_page.dart';
import 'package:reminder_calender_app/calenderPage/presentation/calender_page.dart';
import 'package:reminder_calender_app/config.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getRegister() async {
    final uri = Uri.parse(registration);
    var regbody = {
      'username': usernameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    };
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regbody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('Registration Successful');
        }
        if (mounted) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => CalenderPage()),
          );
        }
      } else {
        if (kDebugMode) {
          print('Registration failed: ${response.statusCode}');
        }
        // ignore: use_build_context_synchronously
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 51, 51, 51),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200),
            Text(
              'Welcome! User',
              style: TextStyle(
                color: Colors.green[300],
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            // SizedBox(height: 10),
            Text(
              'New to the app! Please Register',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            CustomTextField(
              controller: usernameController,
              labeltext: 'Username',
              obscureText: false,
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: emailController,
              labeltext: 'Email',
              obscureText: false,
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: passwordController,
              labeltext: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already a User! ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  getRegister();
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
