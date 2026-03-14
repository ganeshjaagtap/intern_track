import 'package:flutter/material.dart';

class PrincipalInternDetailScreen extends StatelessWidget {
  final Map<String, dynamic> internData;

  const PrincipalInternDetailScreen({super.key, required this.internData});

  final Color jasmine = const Color(0xFFFFE588);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: jasmine,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Internship Progress",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. TOP STATUS HEADER ---
            Container(
              padding: const EdgeInsets.all(24),
              color: jasmine.withOpacity(0.3),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: jasmine,
                    child: Text(
                      internData['name'][0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          internData['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${internData['dept']} | ${internData['company']}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. LIVE METRICS ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildMetricCard(
                    "Attendance",
                    "94%",
                    Icons.calendar_today,
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    "Reports",
                    "06/10",
                    Icons.description,
                    Colors.blue,
                  ),
                ],
              ),
            ),

            // --- 3. PROJECT DETAILS ---
            _buildSectionTitle("Project Information"),
            _buildDetailTile(
              "Project Title",
              "Smart Inventory Management System",
              Icons.assignment,
            ),
            _buildDetailTile(
              "Industry Mentor",
              "Mr. Rajesh V. (Senior Lead)",
              Icons.person_outline,
            ),
            _buildDetailTile("Joining Date", "01 Jan 2026", Icons.date_range),

            const SizedBox(height: 20),

            // --- 4. WEEKLY LOG TIMELINE ---
            _buildSectionTitle("Weekly Performance"),
            _buildTimelineTile(
              "Week 6",
              "Completed Database Integration",
              true,
            ),
            _buildTimelineTile("Week 5", "UI Components finalized", true),
            _buildTimelineTile("Week 4", "System Architecture design", true),

            const SizedBox(height: 120), // Added padding for bottom button
          ],
        ),
      ),

      // --- 5. UPDATED BUTTON: DOWNLOAD DOCUMENT AS PDF ---
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Downloading Internship Log PDF..."),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black87),
            label: const Text(
              "Download Document as PDF",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: Colors.black87, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTimelineTile(String week, String task, bool isDone) {
    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: Colors.green,
      ),
      title: Text(week, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(task),
    );
  }
}
