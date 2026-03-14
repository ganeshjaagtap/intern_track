import 'package:flutter/material.dart';

class PrincipalStudentScreen extends StatelessWidget {
  const PrincipalStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Principal - Students")),
      body: const Center(child: Text("This is Principal Student Screen")),
    );
  }
}
