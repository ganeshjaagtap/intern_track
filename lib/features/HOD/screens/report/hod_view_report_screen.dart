import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        future: FirebaseFirestore.instance.collection("reports").doc(reportId).get(),
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
                _buildHeaderCard(data),
                const SizedBox(height: 20),
                _buildSectionTitle("Student Information"),
                _buildInfoCard([
                  _buildInfoRow("Name", data["studentName"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Enrollment", data["enrollmentNo"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Department", data["department"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Role", data["role"] ?? "-"),
                ]),
                const SizedBox(height: 20),
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
                _buildSectionTitle("Report Details"),
                _buildInfoCard([
                  _buildInfoRow("Title", data["title"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Report Type", data["reportType"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Week", data["week"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Period", data["period"] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow(
                    "Submitted On",
                    _formatDate(data["submittedAt"] ?? data["createdAt"]),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    "Attachment",
                    (data["fileName"] ?? "").toString().trim().isEmpty
                        ? "No file selected"
                        : data["fileName"],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionTitle("Summary"),
                _buildTextCard(data["summary"] ?? ""),
                const SizedBox(height: 20),
                _buildSectionTitle("Work Accomplished"),
                _buildTextCard(data["workDone"] ?? ""),
                const SizedBox(height: 20),
                _buildSectionTitle("Learning Outcomes"),
                _buildTextCard(data["learning"] ?? ""),
                const SizedBox(height: 20),
                _buildSectionTitle("Challenges & Issues"),
                _buildTextCard(data["issues"] ?? ""),
                const SizedBox(height: 20),
                _buildSectionTitle("Next Week Plan"),
                _buildTextCard(data["nextPlan"] ?? ""),
                const SizedBox(height: 20),
                _buildSectionTitle("Approval Details"),
                _buildInfoCard([
                  _buildInfoRowWithIcon(
                    Icons.flag_outlined,
                    "Current Status",
                    (data["status"] ?? "pending").toString().toUpperCase(),
                  ),
                  _buildDivider(),
                  _buildApprovalActorRow(data["approvedBy"]),
                  _buildDivider(),
                  _buildInfoRowWithIcon(
                    Icons.event_available,
                    "Approval Date",
                    _formatDate(data["approvalDate"]),
                  ),
                  _buildDivider(),
                  _buildInfoRowWithIcon(
                    Icons.comment_outlined,
                    "Rejection Reason",
                    (data["rejectionReason"] ?? "").toString().trim().isEmpty
                        ? "Not provided"
                        : data["rejectionReason"],
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

  Widget _buildApprovalActorRow(dynamic approvedBy) {
    final approverId = (approvedBy ?? "").toString().trim();
    if (approverId.isEmpty) {
      return _buildInfoRowWithIcon(
        Icons.person_outline,
        "Reviewed By",
        "Not reviewed yet",
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("user").doc(approverId).get(),
      builder: (context, snapshot) {
        String label = approverId;
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          label = (userData["fullName"] ?? approverId).toString();
        }

        return _buildInfoRowWithIcon(
          Icons.person_outline,
          "Reviewed By",
          label,
        );
      },
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
                    Text(
                      data["period"] ?? "-",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      child: Column(children: children),
    );
  }

  Widget _buildTextCard(String text) {
    final displayText = text.isEmpty ? "-" : text;
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
        displayText,
        style: TextStyle(
          fontSize: 14,
          color: displayText == "-" ? Colors.grey[400] : const Color(0xFF333333),
          height: 1.6,
          fontStyle: displayText == "-" ? FontStyle.italic : FontStyle.normal,
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
            value.toString().isEmpty ? "-" : value.toString(),
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
            value.toString().isEmpty ? "-" : value.toString(),
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
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case "approved":
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case "rejected":
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Not available";

    try {
      final dateTime = (timestamp as Timestamp).toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Not available";
    }
  }
}
