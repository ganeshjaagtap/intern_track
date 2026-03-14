import 'package:flutter/material.dart';

class PrincipalHelpSupportScreen extends StatelessWidget {
  const PrincipalHelpSupportScreen({super.key});

  final Color coolSky = const Color(0xFF60B5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        title: const Text(
          "HELP & SUPPORT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ❓ FAQ Section
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSupportCard([
            _buildSupportTile(
              "How to export reports?",
              "Click the download icon on the Reports tab.",
            ),
            const Divider(height: 1),
            _buildSupportTile(
              "Approving HOD access",
              "Contact the System Admin for role changes.",
            ),
          ]),

          const SizedBox(height: 24),

          // ✉️ Contact Section
          const Text(
            "Contact Support",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSupportCard([
            _buildActionTile(
              Icons.email_outlined,
              "Email Support",
              "support@internship-tracker.edu",
            ),
            const Divider(height: 1),
            _buildActionTile(
              Icons.language_outlined,
              "Visit Website",
              "www.university-portal.edu",
            ),
          ]),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              "App Version: 1.0.4 (Stable)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSupportTile(String q, String a) {
    return ExpansionTile(
      title: Text(
        q,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            a,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, String sub) {
    return ListTile(
      leading: Icon(icon, color: coolSky),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {},
    );
  }
}
