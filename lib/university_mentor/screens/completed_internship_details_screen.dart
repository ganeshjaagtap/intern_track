import 'package:flutter/material.dart';

class CompletedInternshipDetailsScreen extends StatelessWidget {

  final Map<String, String> student;

  const CompletedInternshipDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(student["name"] ?? "Internship Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// STUDENT PROFILE
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  student["name"]![0],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// STUDENT INFO
            const Text(
              "Student Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            _infoTile("Name", student["name"]),
            _infoTile("Roll Number", student["roll"]),
            _infoTile("Department", student["dept"]),
            _infoTile("Year", student["year"]),

            const SizedBox(height: 20),

            /// INTERNSHIP DETAILS
            const Text(
              "Internship Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            _infoTile("Company", student["company"]),
            _infoTile("Role", student["role"]),
            _infoTile("Type", student["type"]),
            _infoTile("Start Date", student["start"]),
            _infoTile("End Date", student["end"]),

            const SizedBox(height: 20),

            /// PERFORMANCE DETAILS
            const Text(
              "Performance Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            _infoTile("Attendance", student["attendance"]),
            _infoTile("Tasks Completed", student["tasks"]),
            _infoTile("Mentor Feedback", student["feedback"]),
            _infoTile("Final Grade", student["grade"]),

            const SizedBox(height: 20),

            /// STATUS
            const Text(
              "Internship Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            _infoTile("Status", student["status"]),
            _infoTile("Certificate", student["certificate"]),

            const SizedBox(height: 20),

            /// MENTOR DETAILS
            const Text(
              "Mentor Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            _infoTile("College Mentor", student["collegeMentor"]),
            _infoTile("Company Mentor", student["companyMentor"]),

            const SizedBox(height: 20),

            /// ACTION BUTTONS
            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Download Certificate"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("View Report"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(value ?? "-"),
          ),
        ],
      ),
    );
  }
}