import 'package:flutter/material.dart';

class ViewReportScreen extends StatelessWidget {
  final String title;
  final String period;
  final String mentor;

  const ViewReportScreen({
    Key? key,
    required this.title,
    required this.period,
    required this.mentor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("VIEW REPORT"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// =======================
            /// REPORT HEADER
            /// =======================
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    period,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Mentor: $mentor",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      _statusChip("Approved", Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// =======================
            /// STUDENT INFO
            /// =======================
            _sectionTitle("Student Information"),
            _sectionCard(
              child: Column(
                children: const [
                  _infoRow("Name", "Abhijeet Apare"),
                  _infoRow("Department", "Computer Science"),
                  _infoRow("Internship Role", "Flutter Developer Intern"),
                  _infoRow("Organization", "Tech Solutions Pvt. Ltd."),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// SUMMARY
            /// =======================
            _sectionTitle("Weekly Summary"),
            _sectionCard(
              child: const Text(
                "This week focused on improving the attendance module and "
                "building the report dashboard. Navigation issues were fixed "
                "and UI consistency was improved across screens.",
                style: TextStyle(height: 1.4),
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// WORK DONE
            /// =======================
            _sectionTitle("Work Done"),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _bulletPoint("Designed attendance calendar with month/year logic"),
                  _bulletPoint("Implemented leave, absent and late reason dialog"),
                  _bulletPoint("Built report dashboard with filters"),
                  _bulletPoint("Integrated bottom navigation"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// LEARNING OUTCOMES
            /// =======================
            _sectionTitle("Learning Outcomes"),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _bulletPoint("Better understanding of Flutter state management"),
                  _bulletPoint("Improved UI structuring using reusable widgets"),
                  _bulletPoint("Navigation handling using pushReplacement"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// ISSUES / CHALLENGES
            /// =======================
            _sectionTitle("Issues & Challenges"),
            _sectionCard(
              child: const Text(
                "Initially faced issues with Flutter Web hot reload and "
                "null-safety errors. These were resolved by proper state handling "
                "and full application restarts.",
                style: TextStyle(height: 1.4),
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// NEXT WEEK PLAN
            /// =======================
            _sectionTitle("Next Week Plan"),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _bulletPoint("Implement backend integration"),
                  _bulletPoint("Add authentication flow"),
                  _bulletPoint("Improve report submission feature"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// MENTOR FEEDBACK
            /// =======================
            _sectionTitle("Mentor Feedback"),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Good progress overall. Code structure has improved and "
                    "UI implementation is clean. Focus on backend integration "
                    "next week.",
                    style: TextStyle(height: 1.4),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "- Dr. Sharma",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// SCORE
            /// =======================
            _sectionTitle("Evaluation Score"),
            _sectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _scoreItem("Code Quality", "9/10"),
                  _scoreItem("UI Design", "8/10"),
                  _scoreItem("Punctuality", "9/10"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// =======================
            /// DOWNLOAD BUTTON
            /// =======================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB6FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Report downloaded successfully"),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text("Download Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// REUSABLE WIDGETS
  /// =======================

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
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// =======================
/// SMALL WIDGETS
/// =======================

class _infoRow extends StatelessWidget {
  final String label;
  final String value;

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _bulletPoint extends StatelessWidget {
  final String text;

  const _bulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _scoreItem extends StatelessWidget {
  final String label;
  final String value;

  const _scoreItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
