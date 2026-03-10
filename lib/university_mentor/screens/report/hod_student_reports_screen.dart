import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hod_view_report_screen.dart';

class HodStudentReportsScreen extends StatelessWidget {

  final String studentId;
  final String studentName;

  const HodStudentReportsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("$studentName Reports"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reports")
            .where("studentId", isEqualTo: studentId)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reports found"));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,

            itemBuilder: (context, index) {

              final data =
                  reports[index].data() as Map<String, dynamic>? ?? {};

              final title = data["title"] ?? "Untitled Report";
              final period = data["period"] ?? "";

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text(title),
                  subtitle: Text(period),

                  trailing: TextButton(

                    child: const Text("View"),

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HodViewReportScreen(
                            reportId: reports[index].id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}