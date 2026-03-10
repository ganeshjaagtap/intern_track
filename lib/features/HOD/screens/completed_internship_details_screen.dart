import 'package:flutter/material.dart';

class CompletedInternshipDetailsScreen extends StatelessWidget {

  final Map<String, dynamic> student;

  const CompletedInternshipDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {

    final name = student["fullName"] ?? "Student";

    return Scaffold(

      appBar: AppBar(
        title: Text(name),
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
                  name.toString().isNotEmpty
                      ? name.toString()[0]
                      : "S",
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

            _infoTile("Name", student["fullName"]),
            _infoTile("Enrollment No", student["enrollmentNo"]),
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
            _infoTile("Role", student["internshipRole"]),
            _infoTile("Type", student["internshipType"]),
            _infoTile("Start Date", student["startDate"]),
            _infoTile("End Date", student["endDate"]),

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

            _infoTile("Status", student["internshipStatus"]),
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
                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Certificate download coming soon"),
                        ),
                      );

                    },
                    child: const Text("Download Certificate"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("View report feature coming soon"),
                        ),
                      );

                    },
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

  Widget _infoTile(String title, dynamic value) {

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
            child: Text(value?.toString() ?? "-"),
          ),
        ],
      ),
    );
  }
}