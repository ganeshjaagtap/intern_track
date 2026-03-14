import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const CompanyDetailScreen({super.key, required this.companyData});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final Color primaryBlue = const Color(0xFF64A9F6);
  String? selectedCourse;

  // --- FUNCTION: Launch Phone Dialer ---
  Future<void> _launchCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty || phone == "N/A") return;
    final Uri url = Uri.parse('tel:${phone.trim()}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // --- FUNCTION: Open Email App ---
  Future<void> _launchMail(String? email) async {
    if (email == null || email.trim().isEmpty) return;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      queryParameters: {
        'subject': 'Inquiry regarding Internship at ${widget.companyData['name']}',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _copyToClipboard(email.trim(), "Email address copied to clipboard");
      }
    } catch (e) {
      _copyToClipboard(email.trim(), "Could not open email app. Email copied.");
    }
  }

  // --- FUNCTION: Open Website in External Browser ---
  Future<void> _launchWebsite(String? website) async {
    if (website == null || website.trim().isEmpty) return;

    String urlStr = website.trim();
    if (!urlStr.startsWith('http')) {
      urlStr = 'https://$urlStr';
    }

    final Uri url = Uri.parse(urlStr);

    try {
      // mode: LaunchMode.externalApplication is essential for modern Android/iOS
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open browser for: $urlStr")),
        );
      }
    }
  }

  // --- HELPER: Copy to Clipboard ---
  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.companyData['name'] ?? 'Unknown Company';
    final String industry = widget.companyData['industry'] ?? 'N/A';
    final String about = widget.companyData['about'] ?? 'No description available.';
    final String experience = widget.companyData['experience'] ?? 'N/A';
    final String phone = widget.companyData['phone'] ?? widget.companyData['phone_number'] ?? 'N/A';
    final String logoUrl =
        (widget.companyData['logoUrl'] ?? widget.companyData['companyLogoUrl'] ?? '')
            .toString();
    final dynamic internCount = widget.companyData['internCount'] ?? 0;
    
    final List<String> courses = widget.companyData['courses'] is List 
        ? List<String>.from(widget.companyData['courses']) 
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Company Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(name, industry, logoUrl),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatTile("Experience", experience, Icons.history_edu, Colors.blue)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatTile("Interns Trained", "$internCount+", Icons.people_alt_rounded, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _buildSectionTitle("About Company"),
                  const SizedBox(height: 10),
                  _buildContentCard(
                    child: Text(about, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.6)),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionTitle("Available Tracks"),
                  const SizedBox(height: 10),
                  _buildCourseDropdown(courses),

                  const SizedBox(height: 25),

                  _buildSectionTitle("Contact Details"),
                  const SizedBox(height: 10),
                  _buildContactCard(phone),

                  const SizedBox(height: 40),

                  // Call Action
                  _buildCallAction(phone),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String industry, String logoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
        child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage:
                logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
            child: logoUrl.isEmpty
                ? const Icon(Icons.business_rounded, size: 55, color: Color(0xFF64A9F6))
                : null,
          ),
          const SizedBox(height: 16),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(industry.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
      child: child,
    );
  }

  Widget _buildCourseDropdown(List<String> courses) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: primaryBlue.withOpacity(0.3))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourse,
          hint: const Text("View Courses Provided"),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down_circle, color: primaryBlue),
          items: courses.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
          }).toList(),
          onChanged: (newValue) => setState(() => selectedCourse = newValue),
        ),
      ),
    );
  }

  Widget _buildContactCard(String phone) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _contactTile(Icons.phone_rounded, "Phone", phone, onTap: () => _launchCall(phone)),
          const Divider(height: 1, indent: 60),
          _contactTile(Icons.email_rounded, "Email Address", widget.companyData['email'], onTap: () => _launchMail(widget.companyData['email'])),
          const Divider(height: 1, indent: 60),
          _contactTile(Icons.language_rounded, "Website", widget.companyData['website'], onTap: () => _launchWebsite(widget.companyData['website'])),
          const Divider(height: 1, indent: 60),
          _contactTile(Icons.location_on_rounded, "Location", widget.companyData['address']),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, String? value, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(value ?? "N/A", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onTap != null ? primaryBlue : Colors.black87)),
      trailing: onTap != null ? const Icon(Icons.open_in_new, size: 14, color: Colors.grey) : null,
    );
  }

  Widget _buildCallAction(String phone) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => _launchCall(phone),
        icon: const Icon(Icons.call, color: Colors.white),
        label: const Text("Call Company", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3243)));
  }
}
