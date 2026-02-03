import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Colors.black;
  static const Color accent = Colors.white;

  static InputDecoration inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
    filled: true,
    fillColor: Colors.grey[900],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle smallButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    minimumSize: const Size(40, 36), // Small height
    textStyle: const TextStyle(
      fontSize: 14,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
