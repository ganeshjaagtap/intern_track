import 'package:flutter/material.dart';
// 1. ✅ IMPORT YOUR LOGIN SCREEN (Adjust path if needed)
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  bool _isDarkMode = false; 

  // ✅ LOGOUT FUNCTION
  void _handleLogout() {
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ NAVIGATE AND CLEAR STACK
    // This removes the Layout and Profile screens from memory
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF64A9F6);
    const bgLight = Color(0xFFF5F7F9);

    return Container(
      color: bgLight,
      child: Column(
        children: [
          /// 📘 HEADER TITLE BAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]
            ),
            child: const Text(
              "Account Settings",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(primaryBlue),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),

                  _buildSettingsGroup([
                    _settingsTile(Icons.person_outline, "Edit Profile", "Update personal info"),
                    _settingsTile(Icons.notifications_none, "Notifications", "Manage alerts"),
                    _settingsTile(Icons.lock_outline, "Security", "Password & Privacy"),
                    _settingsTile(
                      Icons.dark_mode_outlined, 
                      "Dark Mode", 
                      "Toggle theme",
                      trailing: Switch(
                        value: _isDarkMode,
                        activeColor: primaryBlue,
                        onChanged: (val) => setState(() => _isDarkMode = val),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  /// 🚪 LOG OUT BUTTON (Updated)
                  ElevatedButton.icon(
                    onPressed: _handleLogout, // ✅ Calls the logout function
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text("LOG OUT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildProfileCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: themeColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 40, color: themeColor),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User Name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("user@email.com", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64A9F6)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}