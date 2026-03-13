import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'EditProfileScreen.dart';
import '../../student/auth/Main_Login.dart';

class CompanyMentorSettingsScreen extends StatefulWidget {
  const CompanyMentorSettingsScreen({super.key});

  @override
  State<CompanyMentorSettingsScreen> createState() =>
      _CompanyMentorSettingsScreenState();
}

class _CompanyMentorSettingsScreenState
    extends State<CompanyMentorSettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  String name = "Loading...";
  String email = "Loading...";
  String companyName = "No Company";
  String designation = "No Designation";
  String mentorId = "Not Set";
  String phoneNumber = "Not Set";
  String companyAddress = "Not Set";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// FETCH USER DATA FROM FIREBASE
  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("user")
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            name =
                (data["fullName"] ?? data["name"] ?? "Company Mentor").toString();
            email = (data["email"] ?? currentUser.email ?? "No Email")
                .toString();
            companyName = (data["company_name"] ?? "No Company").toString();
            designation = (data["designation"] ?? "No Designation").toString();
            mentorId = (data["mentorId"] ?? "Not Set").toString();
            phoneNumber =
                (data["phoneNumber"] ?? data["phone"] ?? "Not Set").toString();
            companyAddress =
                (data["company_address"] ?? "Not Set").toString();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// SECURE LOGOUT
  Future<void> _performLogout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) =>
              false, // Destroys the entire navigation stack so they can't hit "back"
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error logging out: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  String _displayValue(String value, String fallback) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == "Loading...") {
      return fallback;
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F9ED6);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF5F9ED6),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// PROFILE CARD
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                name.isNotEmpty && name != "Loading..."
                                    ? name[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 24,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayValue(name, "Company Mentor"),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildBadge(
                                  icon: Icons.business_outlined,
                                  text: _displayValue(companyName, "No Company"),
                                ),
                                _buildBadge(
                                  icon: Icons.work_outline,
                                  text: _displayValue(
                                      designation, "No Designation"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          label: "Email",
                          value: _displayValue(email, "No Email"),
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailTile(
                          label: "Phone",
                          value: _displayValue(phoneNumber, "Not Set"),
                          icon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          label: "Company ID",
                          value: _displayValue(mentorId, "Not Set"),
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailTile(
                          label: "Company",
                          value: _displayValue(companyName, "No Company"),
                          icon: Icons.apartment_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailTile(
                    label: "Company Address",
                    value: _displayValue(companyAddress, "Not Set"),
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.edit_outlined, color: primaryColor),
              title: const Text("Edit Profile"),
              subtitle: const Text("Update your company mentor details"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );

                if (result == true || result != null) {
                  _loadUserData();
                }
              },
            ),
          ),

          const SizedBox(height: 30),

          /// LOGOUT
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text("Logout"),
                      content: const Text(
                          "Are you sure you want to log out of your account?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _performLogout(); // Call the secure Firebase sign out
                          },
                          child: const Text("Logout",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 3),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5F9ED6).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5F9ED6)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5F9ED6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5F9ED6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF5F9ED6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
