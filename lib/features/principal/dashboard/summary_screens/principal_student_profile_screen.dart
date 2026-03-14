import 'package:flutter/material.dart';

class PrincipalStudentProfileScreen extends StatelessWidget {
  final Map<String, String> studentData;

  const PrincipalStudentProfileScreen({super.key, required this.studentData});

  final Color coolSky = const Color(0xFF60B5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // --- HEADER: AVATAR & BASIC INFO ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 30),
            decoration: BoxDecoration(
              color: coolSky.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: coolSky,
                  child: Text(
                    studentData['name']![0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  studentData['name']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "ID: ${studentData['id']} | ${studentData['dept']} Dept",
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),

          // --- INFO LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildInfoSection("Internship Status", [
                  _infoTile(
                    Icons.assignment_turned_in,
                    "Current Status",
                    studentData['status'] ?? "N/A",
                  ),
                  _infoTile(
                    Icons.business,
                    "Allotted Company",
                    studentData['status'] == "Placed"
                        ? "Tech Solutions Ltd"
                        : "Not Assigned",
                  ),
                  _infoTile(
                    Icons.person_pin,
                    "Internal Mentor",
                    "Prof. Suresh Kumar",
                  ),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection("Contact Details", [
                  _infoTile(
                    Icons.phone_android,
                    "Student Phone",
                    "+91 98XXX-XXXXX",
                  ),
                  _infoTile(
                    Icons.email_outlined,
                    "Official Email",
                    "${studentData['name']?.toLowerCase().replaceAll(' ', '')}@inst.edu",
                  ),
                ]),
              ],
            ),
          ),

          // --- BOTTOM ACTIONS: CALL & PDF ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            print("Calling ${studentData['name']}"),
                        icon: const Icon(Icons.call, size: 20),
                        label: const Text("Call Student"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ✅ DOWNLOAD PDF OPTION
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDownloadProgress(context),
                    icon: Icon(Icons.picture_as_pdf, color: coolSky),
                    label: Text(
                      "Download Report PDF",
                      style: TextStyle(color: coolSky),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: coolSky),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: coolSky.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: coolSky),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black38, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Simple feedback for the Principal
  void _showDownloadProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generating Student Report PDF..."),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
