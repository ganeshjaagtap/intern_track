import 'package:flutter/material.dart';

class PrincipalPrivacySecurityScreen extends StatefulWidget {
  const PrincipalPrivacySecurityScreen({super.key});

  @override
  State<PrincipalPrivacySecurityScreen> createState() =>
      _PrincipalPrivacySecurityScreenState();
}

class _PrincipalPrivacySecurityScreenState
    extends State<PrincipalPrivacySecurityScreen> {
  // Navigation Color
  final Color coolSky = const Color(0xFF60B5FF);

  // Toggle States
  bool twoFactorAuth = false;
  bool biometricLogin = true;
  bool hideProfile = true;
  bool loginAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PRIVACY & SECURITY",
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
          const Text(
            "Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Section: Security
          _buildSettingsContainer([
            _buildActionTile(
              Icons.lock_outline,
              "Change Password",
              "Update your account password",
              () {
                // Navigate to Change Password Screen
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              Icons.verified_user_outlined,
              "Two-Factor Authentication",
              "Extra security for your account",
              twoFactorAuth,
              (val) => setState(() => twoFactorAuth = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              Icons.fingerprint,
              "Biometric Login",
              "Use fingerprint or face ID",
              biometricLogin,
              (val) => setState(() => biometricLogin = val),
            ),
          ]),

          const SizedBox(height: 24),
          const Text(
            "Privacy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Section: Privacy
          _buildSettingsContainer([
            _buildSwitchTile(
              Icons.visibility_off_outlined,
              "Hide Profile Information",
              "Limit visibility to mentors only",
              hideProfile,
              (val) => setState(() => hideProfile = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              Icons.notifications_active_outlined,
              "Login Activity Alerts",
              "Get alerts for new logins",
              loginAlerts,
              (val) => setState(() => loginAlerts = val),
            ),
          ]),

          const SizedBox(height: 24),

          // Section: Logout Action
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              title: const Text(
                "Log Out from All Devices",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: const Text(
                "Force logout everywhere",
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
              onTap: () {
                // Global Logout Logic
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: coolSky),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: coolSky,
      secondary: Icon(icon, color: coolSky),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
