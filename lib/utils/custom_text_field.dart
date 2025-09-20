import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  String labeltext;
  final bool obscureText;
  String hintText;
  Color color;
  bool readOnly;
  int maxLine;
  final String? Function(String?)? validator;
  CustomTextField({
    super.key,
    required this.controller,
    this.labeltext = '',
    this.hintText = '',
    required this.obscureText,
    this.readOnly = false,
    this.color = Colors.white,
    this.maxLine = 1,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        // style: TextStyle(color: Colors.white),
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        controller: widget.controller,
        maxLines: widget.maxLine,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: widget.color,
          hintText: widget.hintText,
          labelText: widget.labeltext,
          labelStyle: TextStyle(color: Colors.black),
        ),
        validator: widget.validator,
      ),
    );
  }
}
