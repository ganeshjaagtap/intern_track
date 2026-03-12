import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InternshipBriefDetailsScreen extends StatelessWidget {
  const InternshipBriefDetailsScreen({super.key});

  // Theme colors
  static const Color coolSky = Color(0xFF60B5FF);
  static const Color jasmine = Color(0xFFFFE588);
  static const Color aquamarine = Color(0xFF5EF2D5);

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

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

      body: StreamBuilder<DocumentSnapshot>(

        stream: FirebaseFirestore.instance
            .collection("user")
            .doc(uid)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final studentName = data["fullName"] ?? "Student";
          final company = data["company"] ?? "-";
          final role = data["internshipRole"] ?? "-";
          final status = data["internshipStatus"] ?? "-";

          final start = data["startDate"];
          final end = data["endDate"];

          String duration = "-";

          if (start != null && end != null) {
            DateTime? startDate;
            DateTime? endDate;
            
            // Handle Timestamp or String types
            if (start is Timestamp) {
              startDate = start.toDate();
            } else if (start is String) {
              startDate = DateTime.tryParse(start);
            }
            
            if (end is Timestamp) {
              endDate = end.toDate();
            } else if (end is String) {
              endDate = DateTime.tryParse(end);
            }
            
            if (startDate != null && endDate != null) {
              duration =
                  "${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}";
            }
          }

          return Column(
            children: [

              /// HEADER
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

                child: Column(
                  children: [

                    const Icon(Icons.work_outline,
                        size: 40, color: Colors.white),

                    const SizedBox(height: 8),

                    Text(
                      company,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      role,
                      style: const TextStyle(color: Colors.white70),
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

                      _detailCard(Icons.person, "Student", studentName),

                      _detailCard(Icons.business, "Company", company),

                      _detailCard(Icons.code, "Role", role),

                      _detailCard(Icons.schedule, "Duration", duration),

                      const SizedBox(height: 20),

                      /// STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),

                        decoration: BoxDecoration(
                          color: aquamarine,
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 18),

                            const SizedBox(width: 6),

                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
          );
        },
      ),
    );
  }

  /// DETAIL CARD
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