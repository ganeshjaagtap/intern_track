import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailScreen extends StatelessWidget {

  final Map<String, dynamic> companyData;

  const CompanyDetailScreen({super.key, required this.companyData});

  final Color primaryBlue = const Color(0xFF64A9F6);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),

      appBar: AppBar(
        title: const Text(
          "Company Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),

              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business_rounded,
                      size: 60,
                      color: Color(0xFF64A9F6),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// COMPANY NAME
                  Text(
                    companyData['name'] ?? 'Unknown Company',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),

                  /// INDUSTRY
                  Text(
                    companyData['industry'] ?? 'N/A',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ABOUT
                  const Text(
                    "About Company",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      companyData['about'] ?? 'No description available.',
                      style: const TextStyle(
                          fontSize: 15,
                          height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// CONTACT DETAILS
                  const Text(
                    "Contact Details",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// ADDRESS
                  _buildInfoTile(
                    Icons.location_on,
                    "Address",
                    companyData['address'],
                  ),

                  /// EMAIL
                  _buildInfoTile(
                    Icons.email,
                    "Email",
                    companyData['email'],
                    onTap: () => _launchMail(companyData['email']),
                  ),

                  /// WEBSITE
                  _buildInfoTile(
                    Icons.language,
                    "Website",
                    companyData['website'],
                    onTap: () => _launchWebsite(companyData['website']),
                  ),

                  const SizedBox(height: 40),

                  /// APPLY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      onPressed: () =>
                          _launchMail(companyData['email']),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),

                      child: const Text(
                        "Apply Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INFO TILE
  Widget _buildInfoTile(
      IconData icon,
      String label,
      String? value,
      {VoidCallback? onTap}) {

    return ListTile(
      leading: Icon(icon, color: primaryBlue),

      title: Text(
        label,
        style: const TextStyle(
            fontSize: 12,
            color: Colors.grey),
      ),

      subtitle: Text(
        value ?? "N/A",
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500),
      ),

      onTap: onTap,
    );
  }

  /// OPEN EMAIL
  void _launchMail(String? email) async {

    if (email == null) return;

    final Uri url = Uri.parse('mailto:$email');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// OPEN WEBSITE
  void _launchWebsite(String? website) async {

    if (website == null) return;

    final Uri url = Uri.parse(
        website.startsWith('http')
            ? website
            : 'https://$website');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
} 