import 'package:flutter/material.dart';

class InternshipDetailsScreen extends StatelessWidget {
  const InternshipDetailsScreen({super.key});

  // Theme colors
  static const Color coolSky = Color(0xFF60B5FF);
  static const Color jasmine = Color(0xFFFFE588);
  static const Color aquamarine = Color(0xFF5EF2D5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Internship Details",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: coolSky,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.work_outline, size: 40, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  "TCS Internship",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  "Flutter Developer",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  _detailCard(Icons.person, "Student", "Aman Patel"),
                  _detailCard(Icons.business, "Company", "TCS"),
                  _detailCard(Icons.code, "Role", "Flutter Developer"),
                  _detailCard(Icons.schedule, "Duration", "6 Months"),

                  const SizedBox(height: 20),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: aquamarine,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Ongoing",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: jasmine,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          Icon(icon, color: Colors.black87),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}