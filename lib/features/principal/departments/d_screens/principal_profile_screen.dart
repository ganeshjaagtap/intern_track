import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';
import 'package:image_picker/image_picker.dart';

import '../../settings/principal_edit_profile_screen.dart';
import '../../settings/principal_help_support_screen.dart';
import '../../settings/principal_notification_settings_screen.dart';
import '../../settings/principal_privacy_security_screen.dart';

class PrincipalProfileScreen extends StatefulWidget {
  const PrincipalProfileScreen({super.key});

  @override
  State<PrincipalProfileScreen> createState() => _PrincipalProfileScreenState();
}

class _PrincipalProfileScreenState extends State<PrincipalProfileScreen> {
  final Color coolSky = const Color(0xFF60B5FF);
  final Color strawberry = const Color(0xFFF35252);

  String? _imagePath;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    setState(() {
      _imagePath = pickedFile.path;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in.'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final fullName =
            (data['fullName'] ?? data['name'] ?? 'Principal').toString();
        final email =
            (data['email'] ?? currentUser.email ?? 'No Email').toString();
        final dept = (data['dept'] ?? 'Department Not Set').toString().trim();

        if (_imagePath == null) {
          _profileImageUrl = (data['profileImageUrl'] ?? '').toString();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Account Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _resolveImageProvider(),
                            child: _imagePath == null &&
                                    (_profileImageUrl ?? '').isEmpty
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Principal | $dept',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                            'Edit Profile',
                            'Update university credentials',
                            const PrincipalEditProfileScreen(),
                          ),
                          const Divider(height: 1, indent: 55),
                          _buildProfileOption(
                            context,
                            Icons.notifications_none,
                            'Notifications',
                            'Manage push alerts',
                            const PrincipalNotificationSettingsScreen(),
                          ),
                          const Divider(height: 1, indent: 55),
                          _buildProfileOption(
                            context,
                            Icons.lock_outline,
                            'Privacy & Security',
                            'Password and login settings',
                            const PrincipalPrivacySecurityScreen(),
                          ),
                          const Divider(height: 1, indent: 55),
                          _buildProfileOption(
                            context,
                            Icons.help_outline,
                            'Help & Support',
                            'FAQs and contact us',
                            const PrincipalHelpSupportScreen(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        icon: Icon(Icons.logout, color: strawberry, size: 20),
                        label: Text(
                          'Log Out',
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
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider? _resolveImageProvider() {
    if (_imagePath != null) {
      return kIsWeb
          ? NetworkImage(_imagePath!)
          : FileImage(File(_imagePath!)) as ImageProvider;
    }

    if ((_profileImageUrl ?? '').isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }

    return null;
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
      onTap: () async {
        if (destination == null) {
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );

        if (mounted) {
          setState(() {
            _imagePath = null;
          });
        }
      },
    );
  }
}
