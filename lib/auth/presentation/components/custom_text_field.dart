import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labeltext;
  final bool obscureText;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labeltext,
    required this.obscureText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        // style: TextStyle(color: Colors.white),
        obscureText: widget.obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          labelText: widget.labeltext,
          labelStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
