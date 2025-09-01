import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_calender_app/auth/presentation/components/custom_text_field.dart';
import 'package:reminder_calender_app/calenderPage/presentation/calender_page.dart';
import 'package:reminder_calender_app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // late SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    // initSharedPref();
  }

  // void initSharedPref() async {
  //   prefs = await SharedPreferences.getInstance();
  // }

  Future<void> getSignedIn() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final uri = Uri.parse(login);
      final regbody = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      try {
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(regbody),
        );

        var jsonResponse = jsonDecode(response.body);
        // print('Login response: $jsonResponse');

        if (response.statusCode == 200 && jsonResponse["status"] == true) {
          var myToken = jsonResponse['token'];
          var user = jsonResponse['user'];

          // Use 'id' instead of '_id'
          await prefs.setString('token', myToken);
          await prefs.setString('userId', user['id']);
          await prefs.setString('username', user['username']);
          await prefs.setString('email', user['email']);

          if (kDebugMode) {
            print('User successfully logged in: ${user['username']}');
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CalenderPage()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(jsonResponse['message'] ?? 'Login failed'),
              ),
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error during login: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 200),
            Text(
              'Welcome Back!',
              style: TextStyle(
                color: Colors.green[300],
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Already a user! Login Please',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            CustomTextField(
              controller: emailController,
              labeltext: 'Email',
              obscureText: false,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: passwordController,
              labeltext: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: getSignedIn,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign In',
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
