import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FacultyStudentReportsScreen extends StatefulWidget {
  final String reportId;

  const FacultyStudentReportsScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<FacultyStudentReportsScreen> createState() =>
      _FacultyStudentReportsScreenState();
}

class _FacultyStudentReportsScreenState extends State<FacultyStudentReportsScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  bool _isProcessing = false;
  String? _facultyShortId;

  @override
  void initState() {
    super.initState();
    _loadFacultyId();
  }

  Future<void> _loadFacultyId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection("user").doc(uid).get();
    if (!mounted) return;

    setState(() {
      _facultyShortId = (doc.data()?["facultyId"] ?? "").toString().trim();
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _reviewReport({
    required String status,
    required Map<String, dynamic> reportData,
  }) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final reportFacultyId = (reportData["facultyId"] ?? "").toString().trim();

    if (currentUid == null || _facultyShortId == null || _facultyShortId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faculty profile is incomplete.")),
      );
      return;
    }

    if (reportFacultyId != _facultyShortId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are not allowed to review this report.")),
      );
      return;
    }

    if (status == "rejected" && _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rejection reason is required.")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance.collection("reports").doc(widget.reportId).update({
        "status": status,
        "approvedBy": currentUid,
        "approvalDate": FieldValue.serverTimestamp(),
        "rejectionReason": status == "rejected" ? _feedbackController.text.trim() : null,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "approved"
                ? "Report approved successfully"
                : "Report rejected successfully",
          ),
          backgroundColor: status == "approved" ? Colors.green : Colors.red,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update report: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Review Report"),
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("reports").doc(widget.reportId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Report not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = (data["status"] ?? "pending").toString();
          final bool canReview =
              status == "pending" &&
              _facultyShortId != null &&
              (data["facultyId"] ?? "").toString().trim() == _facultyShortId;

          if (_feedbackController.text.isEmpty &&
              (data["rejectionReason"] ?? "").toString().trim().isNotEmpty) {
            _feedbackController.text = data["rejectionReason"];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerCard(data, status),
                const SizedBox(height: 20),
                _sectionTitle("Student Information"),
                _card(
                  children: [
                    _infoRow("Name", data["studentName"] ?? "-"),
                    _infoRow("Enrollment", data["enrollmentNo"] ?? "-"),
                    _infoRow("Department", data["department"] ?? "-"),
                    _infoRow("Role", data["role"] ?? "-"),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle("Assigned Mentors"),
                _card(
                  children: [
                    _infoRow("Faculty Mentor", data["facultyMentorName"] ?? "Not assigned"),
                    _infoRow("Company Mentor", data["companyMentorName"] ?? "Not assigned"),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle("Report Details"),
                _card(
                  children: [
                    _infoRow("Title", data["title"] ?? "-"),
                    _infoRow("Report Type", data["reportType"] ?? "-"),
                    _infoRow("Week", data["week"] ?? "-"),
                    _infoRow("Period", data["period"] ?? "-"),
                    _infoRow(
                      "Submitted On",
                      _formatTimestamp(data["submittedAt"] ?? data["createdAt"]),
                    ),
                    _infoRow("Attachment", data["fileName"] ?? "No file selected"),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle("Report Content"),
                _textCard("Summary", data["summary"] ?? ""),
                const SizedBox(height: 16),
                _textCard("Work Done", data["workDone"] ?? ""),
                const SizedBox(height: 16),
                _textCard("Learning Outcomes", data["learning"] ?? ""),
                const SizedBox(height: 16),
                _textCard("Issues / Challenges", data["issues"] ?? ""),
                const SizedBox(height: 16),
                _textCard("Next Week Plan", data["nextPlan"] ?? ""),
                const SizedBox(height: 20),
                _sectionTitle("Approval Status"),
                _card(
                  children: [
                    _infoRow("Current Status", status.toUpperCase()),
                    _buildApprovalActorRow(data["approvedBy"]),
                    _infoRow("Approval Date", _formatTimestamp(data["approvalDate"])),
                    _infoRow(
                      "Rejection Reason",
                      (data["rejectionReason"] ?? "").toString().trim().isEmpty
                          ? "-"
                          : data["rejectionReason"],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle("Approval Decision"),
                _card(
                  children: [
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Feedback / Rejection Reason",
                        hintText: "Add feedback for the student",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (status == "rejected" &&
                        (data["rejectionReason"] ?? "").toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        "Current rejection reason: ${data["rejectionReason"]}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: canReview && !_isProcessing
                                ? () => _reviewReport(status: "approved", reportData: data)
                                : null,
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Approve"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: canReview && !_isProcessing
                                ? () => _reviewReport(status: "rejected", reportData: data)
                                : null,
                            child: const Text("Reject"),
                          ),
                        ),
                      ],
                    ),
                    if (!canReview) ...[
                      const SizedBox(height: 12),
                      Text(
                        status == "pending"
                            ? "You can only review reports assigned to your facultyId."
                            : "This report has already been reviewed.",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerCard(Map<String, dynamic> data, String status) {
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
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data["period"] ?? "",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    if ((data["week"] ?? "").toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          data["week"],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6BB6FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Submitted: ${_formatTimestamp(data["submittedAt"] ?? data["createdAt"])}",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
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

  Widget _card({required List<Widget> children}) {
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

  Widget _textCard(String title, String value) {
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.toString().isEmpty ? "-" : value.toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color textColor;
    switch (status.toLowerCase()) {
      case "approved":
        textColor = Colors.green;
        break;
      case "rejected":
        textColor = Colors.red;
        break;
      default:
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

  Widget _buildApprovalActorRow(dynamic value) {
    final approverId = (value ?? "").toString().trim();
    if (approverId.isEmpty) {
      return _infoRow("Approved / Rejected By", "Not reviewed yet");
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("user").doc(approverId).get(),
      builder: (context, snapshot) {
        String label = approverId;
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          label = (userData["fullName"] ?? approverId).toString();
        }
        return _infoRow("Approved / Rejected By", label);
      },
    );
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final dateTime = value.toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    return "Not available";
  }
}
