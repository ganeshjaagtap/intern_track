import 'package:flutter/material.dart';

class DepartmentCard extends StatelessWidget {
  final String name;
  final int totalStudents;
  final int activeInterns;
  final double progress;
  final VoidCallback onTap;

  const DepartmentCard({
    super.key,
    required this.name,
    required this.totalStudents,
    required this.activeInterns,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text("Total Students: $totalStudents"),
            Text("Active Interns: $activeInterns"),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6BB6FF),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "${(progress * 100).toInt()}% Internship Completion",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
