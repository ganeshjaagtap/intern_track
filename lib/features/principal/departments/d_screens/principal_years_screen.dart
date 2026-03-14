import 'package:flutter/material.dart';
import 'principal_year_students_screen.dart'; // Added this import

class PrincipalYearScreen extends StatelessWidget {
  final String departmentName;

  const PrincipalYearScreen({super.key, required this.departmentName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> years = [
      {"year": "1st Year", "students": 60, "interns": 30, "progress": 0.50},
      {"year": "2nd Year", "students": 70, "interns": 45, "progress": 0.64},
      {"year": "3rd Year", "students": 80, "interns": 65, "progress": 0.81},
      {"year": "4th Year", "students": 50, "interns": 40, "progress": 0.80},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: Text(
          departmentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrincipalYearStudentsScreen(
                      departmentName: departmentName,
                      year: year["year"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      year["year"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Total Students: ${year["students"]}"),
                    Text("Active Interns: ${year["interns"]}"),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: year["progress"],
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6BB6FF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${(year["progress"] * 100).toInt()}% Internship Completion",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
