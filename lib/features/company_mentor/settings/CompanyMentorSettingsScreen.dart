import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'EditProfileScreen.dart';
import 'ChangePasswordScreen.dart';
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
            name = (data["fullName"] ?? "Company Mentor").toString();
            email = (data["email"] ?? currentUser.email ?? "No Email Provided")
                .toString();
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
          (route) => false, // Destroys the entire navigation stack so they can't hit "back"
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF5F9ED6).withOpacity(0.2),
                  child: isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : Text(
                          // Safely grabs the first letter of their name
                          name.isNotEmpty && name != "Loading..." ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF5F9ED6),
                              fontSize: 20),
                        ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () async {
                    // Wait for the EditProfileScreen to pop
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );

                    // If they saved changes, refresh the data from Firebase
                    if (result == true || result != null) {
                      _loadUserData();
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// NOTIFICATIONS
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Receive report updates"),
              activeColor: const Color(0xFF5F9ED6),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          /// APPEARANCE
          const Text(
            "Appearance",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Enable dark theme"),
              activeColor: const Color(0xFF5F9ED6),
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          /// SECURITY
          const Text(
            "Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          /// LOGOUT
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out of your account?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _performLogout(); // Call the secure Firebase sign out
                          },
                          child: const Text("Logout", style: TextStyle(color: Colors.white)),
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
}
