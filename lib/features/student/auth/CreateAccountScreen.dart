import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/facultymentorinfo/dashboard/MentorInfoScreen.dart';
import 'package:flutter_application_2/features/interns/screens/InternshipDetailsScreen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: const Center(
        child: Text("Create Account Screen"),
      ),
    );
  }
}