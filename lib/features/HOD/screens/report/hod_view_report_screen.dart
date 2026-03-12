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
      backgroundColor: const Color(0xFFF5F7FA),
      
      appBar: AppBar(
        title: const Text("Report Details"),
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
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
            return const Center(
              child: Text("Report not found"),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER SECTION
                _buildHeaderCard(data),
                const SizedBox(height: 20),

                /// STUDENT INFO SECTION
                _buildSectionTitle("Student Information"),
                _buildInfoCard([
                  _buildInfoRow("Name", data["studentName"] ?? "—"),
                  _buildDivider(),
                  _buildInfoRow("Enrollment", data["enrollmentNo"] ?? "—"),
                  _buildDivider(),
                  _buildInfoRow("Department", data["department"] ?? "—"),
                  _buildDivider(),
                  _buildInfoRow("Role", data["role"] ?? "—"),
                ]),
                const SizedBox(height: 20),

                /// MENTORS SECTION
                _buildSectionTitle("Assigned Mentors"),
                _buildInfoCard([
                  _buildInfoRowWithIcon(
                    Icons.person,
                    "Faculty Mentor",
                    data["facultyMentorName"] ?? "Not assigned",
                  ),
                  _buildDivider(),
                  _buildInfoRowWithIcon(
                    Icons.business,
                    "Company Mentor",
                    data["companyMentorName"] ?? "Not assigned",
                  ),
                ]),
                const SizedBox(height: 20),

                /// REPORT DETAILS
                _buildSectionTitle("Report Period"),
                _buildInfoCard([
                  _buildInfoRowWithIcon(
                    Icons.date_range,
                    "Period",
                    data["period"] ?? "—",
                  ),
                  _buildDivider(),
                  _buildInfoRowWithIcon(
                    Icons.assignment,
                    "Type",
                    data["reportType"] ?? "—",
                  ),
                  _buildDivider(),
                  _buildInfoRowWithIcon(
                    Icons.calendar_month,
                    "Week",
                    data["week"] ?? "—",
                  ),
                ]),
                const SizedBox(height: 20),

                /// SUMMARY
                _buildSectionTitle("Summary"),
                _buildTextCard(data["summary"] ?? ""),
                const SizedBox(height: 20),

                /// WORK DONE
                _buildSectionTitle("Work Accomplished"),
                _buildTextCard(data["workDone"] ?? ""),
                const SizedBox(height: 20),

                /// LEARNING
                _buildSectionTitle("Learning Outcomes"),
                _buildTextCard(data["learning"] ?? ""),
                const SizedBox(height: 20),

                /// CHALLENGES/ISSUES
                _buildSectionTitle("Challenges & Issues"),
                _buildTextCard(data["issues"] ?? ""),
                const SizedBox(height: 20),

                /// NEXT PLAN
                _buildSectionTitle("Next Week Plan"),
                _buildTextCard(data["nextPlan"] ?? ""),
                const SizedBox(height: 20),

                /// STATUS SECTION
                if (data["status"] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Report Status"),
                      _buildStatusCard(data["status"] ?? "pending"),
                      const SizedBox(height: 20),
                    ],
                  ),

                /// SUBMISSION DATE
                if (data["createdAt"] != null)
                  _buildInfoCard([
                    _buildInfoRowWithIcon(
                      Icons.schedule,
                      "Submitted",
                      _formatDate(data["createdAt"]),
                    ),
                  ]),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                      data["title"] ?? "Untitled Report",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data["period"] ?? "—",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(data["status"] ?? "pending"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextCard(String text) {
    if (text.isEmpty || text == "—") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
        child: Text(
          "—",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF333333),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6BB6FF)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey[200],
        height: 1,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case "approved":
        bgColor = Colors.green;
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case "rejected":
        bgColor = Colors.red;
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.orange;
        textColor = Colors.orange;
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String displayText;

    switch (status.toLowerCase()) {
      case "approved":
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        displayText = "APPROVED";
        break;
      case "rejected":
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        displayText = "REJECTED";
        break;
      default:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        displayText = "PENDING REVIEW";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "—";
    
    try {
      final dateTime = (timestamp as Timestamp).toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "—";
    }
  }
}