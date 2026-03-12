import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/HOD/screens/report/hod_view_report_screen.dart';

class FacultyStudentReportsScreen extends StatelessWidget {

  final String studentId;
  final String studentName;

  const FacultyStudentReportsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      appBar: AppBar(
        title: Text("$studentName's Reports"),
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No reports found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final reports = snapshot.data!.docs;
          
          // Sort reports by createdAt in descending order (newest first)
          reports.sort((a, b) {
            final aTime = (a["createdAt"] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            final bTime = (b["createdAt"] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,

            itemBuilder: (context, index) {

              final data = reports[index].data() as Map<String, dynamic>? ?? {};
              final reportId = reports[index].id;

              final title = data["title"] ?? "Untitled Report";
              final period = data["period"] ?? "";
              final week = data["week"] ?? "";
              final status = data["status"] ?? "pending";
              final reportType = data["reportType"] ?? "";

              return _reportCard(
                context,
                reportId,
                title,
                week,
                period,
                status,
                reportType,
              );
            },
          );
        },
      ),
    );
  }

  Widget _reportCard(
    BuildContext context,
    String reportId,
    String title,
    String week,
    String period,
    String status,
    String reportType,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HodViewReportScreen(
              reportId: reportId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          week,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6BB6FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BB6FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      reportType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6BB6FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case "approved":
        bgColor = Colors.green;
        textColor = Colors.green;
        break;
      case "rejected":
        bgColor = Colors.red;
        textColor = Colors.red;
        break;
      default:
        bgColor = Colors.orange;
        textColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
