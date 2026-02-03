import 'package:flutter/material.dart';

class SectionDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const SectionDetailPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[700],
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
