import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ Required for kIsWeb check
import 'package:image_picker/image_picker.dart';
import '../../settings/principal_edit_profile_screen.dart';
import '../../settings/principal_notification_settings_screen.dart';
import '../../settings/principal_privacy_security_screen.dart';
import '../../settings/principal_help_support_screen.dart';

class PrincipalProfileScreen extends StatefulWidget {
  PrincipalProfileScreen({super.key});

  @override
  State<PrincipalProfileScreen> createState() => _PrincipalProfileScreenState();
}

class _PrincipalProfileScreenState extends State<PrincipalProfileScreen> {
  final Color coolSky = const Color(0xFF60B5FF);
  final Color strawberry = const Color(0xFFF35252);

  // ✅ UNIVERSAL DATA: Works for Chrome (Blob) and Mobile (Path)
  String? _imagePath;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser.uid)
        .get();

    if (!mounted) return;

    final data = userDoc.data() as Map<String, dynamic>? ?? {};
    setState(() {
      _profileImageUrl = (data['profileImageUrl'] ?? '').toString();
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Clean Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              "Account Profile",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // 👤 User Information Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // ✅ UPDATED: Universal Profile Image Logic
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imagePath != null
                            ? (kIsWeb
                                  ? NetworkImage(_imagePath!)
                                  : FileImage(File(_imagePath!))
                                        as ImageProvider)
                            : (_profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profileImageUrl!)
                                : null),
                        child: _imagePath == null &&
                                (_profileImageUrl == null ||
                                    _profileImageUrl!.isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: coolSky,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dr. Arindam Das",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "principal@university.edu",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Principal | University Institute",
                        style: TextStyle(
                          color: coolSky,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ⚙️ Settings Section (Restored)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        context,
                        Icons.person_outline,
                        "Edit Profile",
                        "Update university credentials",
                        PrincipalEditProfileScreen(),
                      ),
                      const Divider(height: 1, indent: 55),
                      _buildProfileOption(
                        context,
                        Icons.notifications_none,
                        "Notifications",
                        "Manage push alerts",
                        PrincipalNotificationSettingsScreen(),
                      ),
                      const Divider(height: 1, indent: 55),
                      _buildProfileOption(
                        context,
                        Icons.lock_outline,
                        "Privacy & Security",
                        "Password and login settings",
                        PrincipalPrivacySecurityScreen(),
                      ),
                      const Divider(height: 1, indent: 55),
                      _buildProfileOption(
                        context,
                        Icons.help_outline,
                        "Help & Support",
                        "FAQs and contact us",
                        PrincipalHelpSupportScreen(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🚪 Logout Button (Restored)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.logout, color: strawberry, size: 20),
                    label: Text(
                      "Log Out",
                      style: TextStyle(
                        color: strawberry,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: strawberry),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Padding for the floating bottom bar
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Widget? destination,
  ) {
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
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }
}
