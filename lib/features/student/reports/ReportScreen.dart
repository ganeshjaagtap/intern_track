import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/chat/screens/chat_selection_screen.dart';
import 'ViewReportScreen.dart';
import 'SubmitReportScreen.dart';
import '../dashboard/StudentDashboardScreen.dart';
import '../attendance/AttendanceScreen.dart';
import '../profile/SettingsScreen.dart';

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

  final List<ReportItem> reports = [
    ReportItem(
      title: "Week 1 Progress Report",
      period: "1 Jan - 7 Jan",
      status: ReportStatus.approved,
      mentor: "Dr. Sharma",
      score: 8.5,
    ),
    ReportItem(
      title: "Week 2 Progress Report",
      period: "8 Jan - 14 Jan",
      status: ReportStatus.approved,
      mentor: "Dr. Sharma",
      score: 9.0,
    ),
    ReportItem(
      title: "Week 3 Progress Report",
      period: "15 Jan - 21 Jan",
      status: ReportStatus.pending,
      mentor: "Dr. Sharma",
      score: null,
    ),
    ReportItem(
      title: "Monthly Summary",
      period: "January 2026",
      status: ReportStatus.submitted,
      mentor: "Internship Cell",
      score: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

     
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
       
        title: const Text("REPORTS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// FILTERS
            Row(
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
                        if (v != null) setState(() => selectedMonth = v);
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
                      items: years
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text(y.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedYear = v);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// OVERVIEW
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _OverviewItem(
                    label: "Attendance",
                    value: "87%",
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                  _OverviewItem(
                    label: "Reports",
                    value: "4",
                    icon: Icons.description,
                    color: Colors.blue,
                  ),
                  _OverviewItem(
                    label: "Score",
                    value: "8.7",
                    icon: Icons.star,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Your Reports",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (_, i) => _ReportCard(report: reports[i]),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB6FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.white,
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
            

            const SizedBox(height: 40),
          ],
        ),
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



/// =======================
/// MODELS & WIDGETS
/// =======================

enum ReportStatus { submitted, pending, approved }

class ReportItem {
  final String title;
  final String period;
  final ReportStatus status;
  final String mentor;
  final double? score;

  ReportItem({
    required this.title,
    required this.period,
    required this.status,
    required this.mentor,
    required this.score,
  });
}

class _ReportCard extends StatelessWidget {
  final ReportItem report;

  const _ReportCard({required this.report});

  Color _statusColor() {
    switch (report.status) {
      case ReportStatus.approved:
        return Colors.green;
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.submitted:
        return Colors.blue;
    }
  }

  String _statusText() {
    switch (report.status) {
      case ReportStatus.approved:
        return "Approved";
      case ReportStatus.pending:
        return "Pending";
      case ReportStatus.submitted:
        return "Submitted";
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
                  report.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(report.period, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(report.mentor, style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              if (report.score != null)
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      report.score!.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewReportScreen(
                        title: report.title,
                        period: report.period,
                        mentor: report.mentor,
                      ),
                    ),
                  );
                },
                child: const Text("View"),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Report downloaded successfully"),
                    ),
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

class _OverviewItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
