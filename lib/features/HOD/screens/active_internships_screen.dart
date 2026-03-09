import 'package:flutter/material.dart';
import 'student_details_screen.dart';

class ActiveInternshipsScreen extends StatelessWidget {
  const ActiveInternshipsScreen({super.key});

  final List<Map<String, String>> students = const [
    {
      "name": "Aditya Verma",
      "roll": "237032",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "aditya@gmail.com",
      "phone": "9876543210",
      "company": "Infosys",
      "role": "Flutter Developer",
      "type": "Online",
      "start": "01 Jan 2026",
      "end": "30 Mar 2026",
      "status": "Active",
      "attendance": "92%",
      "collegeMentor": "Dr. Kundlikar",
      "companyMentor": "Mr. Sharma"
    },
    {
      "name": "Sanya Malhotra",
      "roll": "237033",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "sanya@gmail.com",
      "phone": "9876543211",
      "company": "TCS",
      "role": "Web Developer",
      "type": "Offline",
      "start": "05 Jan 2026",
      "end": "05 Apr 2026",
      "status": "Active",
      "attendance": "88%",
      "collegeMentor": "Dr. Kundlikar",
      "companyMentor": "Mr. Singh"
    },
    {
      "name": "Rahul Deshmukh",
      "roll": "237034",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "rahul@gmail.com",
      "phone": "9876543212",
      "company": "Wipro",
      "role": "Backend Developer",
      "type": "Hybrid",
      "start": "10 Jan 2026",
      "end": "10 Apr 2026",
      "status": "Active",
      "attendance": "90%",
      "collegeMentor": "Dr. Kundlikar",
      "companyMentor": "Ms. Mehta"
    },
    {
      "name": "Neha Patil",
      "roll": "237035",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "neha@gmail.com",
      "phone": "9876543213",
      "company": "Capgemini",
      "role": "UI Designer",
      "type": "Online",
      "start": "15 Jan 2026",
      "end": "15 Apr 2026",
      "status": "Active",
      "attendance": "95%",
      "collegeMentor": "Dr. Kundlikar",
      "companyMentor": "Mr. Kumar"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Internships"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(student["name"]![0]),
              ),
              title: Text(
                student["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${student["company"]} • ${student["role"]}",
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// OPEN STUDENT DETAILS
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentDetailsScreen(student: student),
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