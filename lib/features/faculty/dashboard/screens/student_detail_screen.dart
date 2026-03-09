import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Map<String, String> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student["name"] ?? "Student Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Student Avatar
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  student["name"]![0],
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Student Information
            const Text(
              "Student Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            _infoTile("Full Name", student["name"]),
            _infoTile("Roll Number", student["roll"]),
            _infoTile("Department", student["dept"]),
            _infoTile("Year", student["year"]),
            _infoTile("Email", student["email"]),
            _infoTile("Phone", student["phone"]),

            const SizedBox(height: 20),

            /// Internship Details
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

            /// Status with color
            _statusTile("Status", student["status"]),

            /// Attendance
            _infoTile("Attendance (%)", student["attendance"]),

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

  /// Normal Info Tile
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
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  /// Status Tile with Color
  Widget _statusTile(String title, String? status) {
    Color statusColor = Colors.grey;

    if (status == "Active") {
      statusColor = Colors.green;
    } else if (status == "Completed") {
      statusColor = Colors.blue;
    } else if (status == "Pending") {
      statusColor = Colors.red;
    }

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
              status ?? "-",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}