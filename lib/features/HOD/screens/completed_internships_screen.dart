import 'package:flutter/material.dart';
import 'completed_internship_details_screen.dart';

class CompletedInternshipsScreen extends StatelessWidget {
  const CompletedInternshipsScreen({super.key});

  final List<Map<String, String>> students = const [
    {
      "name": "Aditya Verma",
      "roll": "237032",
      "dept": "IoT",
      "year": "3rd Year",
      "company": "Infosys",
      "role": "Flutter Developer",
      "type": "Hybrid",
      "start": "1 Jan 2026",
      "end": "31 Mar 2026",
      "attendance": "92%",
      "tasks": "12",
      "feedback": "Excellent",
      "grade": "A",
      "status": "Completed",
      "certificate": "Uploaded",
      "collegeMentor": "Dr. Kundlikar",
      "companyMentor": "Mr. Sharma"
    },
    {
      "name": "Sanya Malhotra",
      "roll": "237033",
      "dept": "IoT",
      "year": "3rd Year",
      "company": "TCS",
      "role": "Web Developer",
      "type": "Remote",
      "start": "10 Jan 2026",
      "end": "10 Apr 2026",
      "attendance": "88%",
      "tasks": "10",
      "feedback": "Very Good",
      "grade": "B+",
      "status": "Completed",
      "certificate": "Uploaded",
      "collegeMentor": "Dr. Kundlikar",
      "companyMentor": "Mr. Singh"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Internships"),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {

          final student = students[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(student["name"]![0]),
              ),

              title: Text(student["name"]!),

              subtitle: Text(
                "${student["company"]} • ${student["role"]}",
              ),

              trailing: const Text(
                "Completed",
                style: TextStyle(color: Colors.green),
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CompletedInternshipDetailsScreen(student: student),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}