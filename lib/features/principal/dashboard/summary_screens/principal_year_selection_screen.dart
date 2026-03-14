import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/principal/dashboard/summary_screens/principal_student_list_screen.dart';

class PrincipalYearSelectionScreen extends StatelessWidget {
  final String departmentName;

  const PrincipalYearSelectionScreen({super.key, required this.departmentName});

  final Color coolSky = const Color(0xFF60B5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          departmentName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Academic Year",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Accessing student records for $departmentName",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),

            // ✅ All cards now pass the correct departmentName to the list screen
            _buildYearCard(
              context,
              "1st Year",
              "New Enrollments",
              Icons.filter_1,
            ),
            _buildYearCard(
              context,
              "2nd Year",
              "Intermediate Level",
              Icons.filter_2,
            ),
            _buildYearCard(
              context,
              "3rd Year",
              "Final Year & Placements",
              Icons.filter_3,
            ),

            const Spacer(),
            Center(
              child: Text(
                "Institute Management System v1.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearCard(
    BuildContext context,
    String year,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrincipalStudentListScreen(
                department:
                    departmentName, // ✅ Fixed: Passes actual name like "IT"
                year: year,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: coolSky.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: coolSky, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      year,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
