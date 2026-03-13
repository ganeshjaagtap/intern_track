import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/HOD/screens/report/hod_student_reports_screen.dart';

class CompletedInternshipDetailsScreen extends StatelessWidget {

  final Map<String, dynamic> student;

  const CompletedInternshipDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {

    final name = student["fullName"] ?? "Student";
    final studentId = (student["uid"] ?? "").toString();

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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Internship Completed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "All assigned internship milestones are marked complete",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (studentId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Student report not available"),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HodStudentReportsScreen(
                            studentId: studentId,
                            studentName: name.toString(),
                          ),
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
