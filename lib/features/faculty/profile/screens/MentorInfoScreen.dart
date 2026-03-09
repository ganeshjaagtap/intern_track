import 'package:flutter/material.dart';

class MentorInfoScreen extends StatelessWidget {
  const MentorInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mentor Information"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),
      body: const Center(
        child: Text(
          "Mentor Information Screen",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}