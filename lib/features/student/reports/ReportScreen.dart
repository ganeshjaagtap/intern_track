import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ViewReportScreen.dart';
import 'SubmitReportScreen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int selectedMonth = 1;
  int selectedYear = 2026;

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
          /// FILTER SECTION
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

          /// REPORT LIST FROM FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("reports")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No reports submitted yet"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return _ReportCard(
                      reportId: docs[index].id,
                      title: data["title"] ?? "",
                      period: data["period"] ?? "",
                      mentor: data["mentor"] ?? "",
                      status: data["status"] ?? "pending",
                    );
                  },
                );
              },
            ),
          ),

          /// SUBMIT REPORT BUTTON
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

/// REPORT CARD
class _ReportCard extends StatelessWidget {
  final String reportId;
  final String title;
  final String period;
  final String mentor;
  final String status;

  const _ReportCard({
    required this.reportId,
    required this.title,
    required this.period,
    required this.mentor,
    required this.status,
  });

  Color statusColor() {
    if (status == "approved") return Colors.green;
    if (status == "pending") return Colors.orange;

    return Colors.blue;
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
          /// TITLE + STATUS
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

          /// PERIOD
          Text(period, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 8),

          /// MENTOR
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),

              const SizedBox(width: 4),

              Text(mentor, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 12),

          /// ACTION BUTTONS
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
