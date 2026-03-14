import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    /* final Map<String, dynamic> internship =
        (student["internship"] ?? {}) as Map<String, dynamic>;

    final Map<String, dynamic> mentor =
        (student["mentor"] ?? {}) as Map<String, dynamic>;*/

    /// Safe student name
    final String name = (student["fullName"] ?? "Student").toString();
    final String imageUrl = (student["profileImageUrl"] ?? "").toString();

    return Scaffold(
      appBar: AppBar(title: Text(name)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl.isEmpty
                    ? Text(
                        (name.isNotEmpty ? name[0] : "S").toUpperCase(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            /// Student Information
            const Text(
              "Student Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            _infoTile("Full Name", student["fullName"]),
            _infoTile("Enrollment No", student["enrollmentNo"]),
            _infoTile("Department", student["dept"]),
            _infoTile("Year", student["year"]),
            _infoTile("Email", student["email"]),
            _infoTile("Phone", student["phoneNumber"]),

            const SizedBox(height: 20),

            /// Internship Details
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
            _statusTile("Status", student["internshipStatus"]),

            const SizedBox(height: 20),

            /// Mentor Details
            const Text(
              "Mentor Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            _infoTile("College Mentor", student["collegeMentor"]),
            _infoTile("Company Mentor", student["companyMentor"]),
          ],
        ),
      ),
    );
  }

  /// Info Row
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

          Expanded(flex: 3, child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }

  /// Status Row
  Widget _statusTile(String title, dynamic status) {
    Color color = Colors.grey;

    if (status == "Active") color = Colors.green;
    if (status == "Completed") color = Colors.blue;
    if (status == "Pending") color = Colors.red;

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
            child: Text(
              status?.toString() ?? "-",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
