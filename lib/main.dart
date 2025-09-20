import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_calender_app/auth/presentation/register_user_page.dart';
import 'package:reminder_calender_app/calenderPage/provider/event_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => EventProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterUserPage(),
    ),
  );
}
