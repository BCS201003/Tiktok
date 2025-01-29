// lib/views/widgets/text_input_field.dart

import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isObscure;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final String? errorText;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final Function()? onSuffixIconPressed;
  final String? Function(String?)? validator;

  const TextInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isObscure = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.isReadOnly = false,
    this.onSuffixIconPressed,
    this.validator,
  }) : super(key: key);

  @override
  TextInputFieldState createState() => TextInputFieldState();
}

class TextInputFieldState extends State<TextInputField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  void _toggleObscure() {
    if (widget.onSuffixIconPressed != null) {
      widget.onSuffixIconPressed!();
    } else {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        readOnly: widget.isReadOnly,
        obscureText: _obscureText,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: Icon(widget.prefixIcon),
          suffixIcon: widget.isObscure
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: _toggleObscure,
          )
              : (widget.suffixIcon != null
              ? IconButton(
            icon: Icon(widget.suffixIcon),
            onPressed: widget.onSuffixIconPressed,
          )
              : null),
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.grey,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.focusedBorderColor ?? Colors.blue,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.errorBorderColor ?? Colors.red,
              width: 2.0,
            ),
          ),
          errorText: widget.errorText,
        ),
      ),
    );
  }
}