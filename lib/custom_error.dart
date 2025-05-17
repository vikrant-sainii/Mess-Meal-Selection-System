import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context, String message,
    {bool isError = false}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    backgroundColor: isError ? Colors.redAccent : Colors.deepPurpleAccent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: const Duration(seconds: 2),
    elevation: 8,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}