import 'package:flutter/material.dart';

class PrincipalYearStudentsScreen extends StatelessWidget {
  final String departmentName;
  final String year;

  const PrincipalYearStudentsScreen({
    super.key,
    required this.departmentName,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> students = [
      {
        "name": "Rahul Sharma",
        "roll": "CE202301",
        "company": "TCS",
        "status": "Active",
      },
      {
        "name": "Priya Mehta",
        "roll": "CE202302",
        "company": "Infosys",
        "status": "Completed",
      },
      {
        "name": "Aman Verma",
        "roll": "CE202303",
        "company": "Wipro",
        "status": "Pending",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: Text(
          "$departmentName - $year",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];

            Color statusColor;

            switch (student["status"]) {
              case "Active":
                statusColor = Colors.orange;
                break;
              case "Completed":
                statusColor = Colors.green;
                break;
              default:
                statusColor = Colors.red;
            }

            return Container(
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
                    student["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Roll No: ${student["roll"]}"),
                  Text("Company: ${student["company"]}"),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student["status"],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
