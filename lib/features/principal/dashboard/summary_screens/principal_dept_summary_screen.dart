import 'package:flutter/material.dart';
import 'principal_student_list_screen.dart';

class PrincipalDeptSummaryScreen extends StatelessWidget {
  const PrincipalDeptSummaryScreen({super.key});

  final Color coolBlue = const Color(0xFF60B5FF);

  @override
  Widget build(BuildContext context) {
    // List of departments for navigation
    final List<String> departments = [
      "Information Technology",
      "Computer Engineering",
      "Mechanical Engineering",
      "Civil Engineering",
      "Electrical Engineering",
      "Electronics & TC",
      "Automobile Engineering",
      "DDGM",
      "AIML",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: coolBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Department Overview",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Institute Departments",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Select a department to view specific enrollment and placement records.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // --- DEPT LIST GENERATOR ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                return _buildSimpleDeptTile(context, departments[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDeptTile(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: coolBlue.withOpacity(0.1),
          child: Icon(Icons.account_balance, color: coolBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrincipalStudentListScreen(
                department: title,
                year: "2026", // Defaulting to current year
              ),
            ),
          );
        },
      ),
    );
  }
}
