import 'package:flutter/material.dart';
import 'package:reminder_calender_app/auth/presentation/register_user_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterUserPage(),
    );
  }
}
