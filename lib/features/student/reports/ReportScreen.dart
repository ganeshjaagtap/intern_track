import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'SubmitReportScreen.dart';
import 'ViewReportScreen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<int> years = [2025, 2026, 2027];

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text(
          "REPORTS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _dropdown(
                    DropdownButton<int>(
                      value: selectedMonth,
                      isExpanded: true,
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(months[i]),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedMonth = v);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    DropdownButton<int>(
                      value: selectedYear,
                      isExpanded: true,
                      items: years.map((y) {
                        return DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedYear = v);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("reports")
                  .where("studentId", isEqualTo: _currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No reports submitted yet"));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = _extractDate(data);
                  if (date == null) return true;
                  return date.month == selectedMonth && date.year == selectedYear;
                }).toList();

                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aDate = _extractDate(aData) ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bDate = _extractDate(bData) ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return bDate.compareTo(aDate);
                });

                if (docs.isEmpty) {
                  return const Center(child: Text("No reports found for the selected month"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final rejectionReason =
                        (data["rejectionReason"] ?? "").toString().trim();

                    return _ReportCard(
                      reportId: docs[index].id,
                      title: data["title"] ?? "",
                      period: data["period"] ?? "",
                      mentor: data["facultyMentorName"] ??
                          data["mentor"] ??
                          data["companyMentorName"] ??
                          "",
                      status: (data["status"] ?? "pending").toString(),
                      rejectionReason: rejectionReason,
                      submittedAt: _extractDate(data),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB6FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubmitReportScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text("Submit New Report"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _extractDate(Map<String, dynamic> data) {
    final dynamic raw = data["submittedAt"] ?? data["createdAt"];
    if (raw is Timestamp) {
      return raw.toDate();
    }
    return null;
  }

  Widget _dropdown(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String reportId;
  final String title;
  final String period;
  final String mentor;
  final String status;
  final String rejectionReason;
  final DateTime? submittedAt;

  const _ReportCard({
    required this.reportId,
    required this.title,
    required this.period,
    required this.mentor,
    required this.status,
    required this.rejectionReason,
    required this.submittedAt,
  });

  Color statusColor() {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(period, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  mentor.isEmpty ? "Mentor not assigned" : mentor,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          if (submittedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              "Submitted: ${submittedAt!.day}/${submittedAt!.month}/${submittedAt!.year}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (status.toLowerCase() == "rejected" && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Rejection reason: $rejectionReason",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewReportScreen(reportId: reportId),
                    ),
                  );
                },
                child: const Text("View"),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report downloaded")),
                  );
                },
                child: const Text("Download"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
