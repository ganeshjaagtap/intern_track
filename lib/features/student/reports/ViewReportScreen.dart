import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewReportScreen extends StatelessWidget {
  final String reportId;

  const ViewReportScreen({
    Key? key,
    required this.reportId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("VIEW REPORT"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("reports").doc(reportId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Report not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = (data["status"] ?? "pending").toString();
          final String rejectionReason =
              (data["rejectionReason"] ?? "").toString().trim();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data["period"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Mentor: ${data["facultyMentorName"] ?? data["mentor"] ?? ""}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusChip(status, _statusColor(status)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle("Approval Status"),
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("Current Status", status.toUpperCase()),
                      _infoRow(
                        "Reviewed On",
                        _formatTimestamp(data["approvalDate"]),
                      ),
                      if (status.toLowerCase() == "rejected" &&
                          rejectionReason.isNotEmpty)
                        _infoRow("Rejection Reason", rejectionReason),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Student Information"),
                _sectionCard(
                  child: Column(
                    children: [
                      _infoRow("Name", data["studentName"] ?? ""),
                      _infoRow("Department", data["department"] ?? ""),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Summary"),
                _sectionCard(
                  child: Text(data["summary"] ?? ""),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Work Done"),
                _sectionCard(
                  child: Text(data["workDone"] ?? ""),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Learning Outcomes"),
                _sectionCard(
                  child: Text(data["learning"] ?? ""),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Issues / Challenges"),
                _sectionCard(
                  child: Text(data["issues"] ?? ""),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Next Week Plan"),
                _sectionCard(
                  child: Text(data["nextPlan"] ?? ""),
                ),
                const SizedBox(height: 20),
                if (data["fileUrl"] != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB6FF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Open file using browser"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text("Download Report"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final dateTime = value.toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    return "Not reviewed yet";
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _infoRow extends StatelessWidget {
  final String label;
  final String value;

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
