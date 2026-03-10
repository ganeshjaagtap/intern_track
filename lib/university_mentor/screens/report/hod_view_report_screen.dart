import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HodViewReportScreen extends StatelessWidget {

  final String reportId;

  const HodViewReportScreen({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("reports")
            .doc(reportId)
            .get(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Report not found"));
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return Padding(
            padding: const EdgeInsets.all(16),

            child: ListView(
              children: [

                Text(
                  data["title"] ?? "No Title",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text("Student: ${data["studentName"] ?? "Unknown"}"),
                Text("Period: ${data["period"] ?? ""}"),
                Text("Mentor: ${data["mentor"] ?? ""}"),

                const Divider(),

                Text("Summary:\n${data["summary"] ?? ""}"),
                const SizedBox(height: 12),

                Text("Work Done:\n${data["workDone"] ?? ""}"),
                const SizedBox(height: 12),

                Text("Learning:\n${data["learning"] ?? ""}"),
                const SizedBox(height: 12),

                Text("Issues:\n${data["issues"] ?? ""}"),
                const SizedBox(height: 12),

                Text("Next Plan:\n${data["nextPlan"] ?? ""}"),
              ],
            ),
          );
        },
      ),
    );
  }
}