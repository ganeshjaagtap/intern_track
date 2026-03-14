import 'package:flutter/material.dart';
import 'principal_student_profile_screen.dart';

class PrincipalStudentListScreen extends StatefulWidget {
  final String department;
  final String year;

  const PrincipalStudentListScreen({
    super.key,
    required this.department,
    required this.year,
  });

  @override
  State<PrincipalStudentListScreen> createState() =>
      _PrincipalStudentListScreenState();
}

class _PrincipalStudentListScreenState
    extends State<PrincipalStudentListScreen> {
  String searchQuery = "";

  // Data based on your provided screenshot
  final List<Map<String, String>> students = [
    {"name": "ganesh", "id": "237032"},
    {"name": "Siddhika Deshmukh", "id": "237057"},
    {"name": "Student", "id": "-"},
    {"name": "shiv", "id": "237033"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.department} Students",
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
              ),
            ),
          ),

          // --- THE STUDENT LIST ---
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, String> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF), // Match the blue tint in screenshot
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD0E0FF), // Match avatar background
          child: Text(
            student['name']![0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4A80FF), // Match initial letter color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student['name']!,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          "Enrollment No: ${student['id']}",
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PrincipalStudentProfileScreen(studentData: student),
            ),
          );
        },
      ),
    );
  }
}
