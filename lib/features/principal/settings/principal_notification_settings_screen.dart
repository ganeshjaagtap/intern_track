import 'package:flutter/material.dart';

class PrincipalNotificationSettingsScreen extends StatefulWidget {
  const PrincipalNotificationSettingsScreen({super.key});

  @override
  State<PrincipalNotificationSettingsScreen> createState() =>
      _PrincipalNotificationSettingsScreenState();
}

class _PrincipalNotificationSettingsScreenState
    extends State<PrincipalNotificationSettingsScreen> {
  // Navigation Color
  final Color coolSky = const Color(0xFF60B5FF);

  // Toggle States
  bool allowNotifications = true;
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool sound = true;
  bool vibration = true;
  bool showOnLockScreen = true;
  bool showPreview = true;
  bool doNotDisturb = false;

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
          "NOTIFICATION SETTINGS",
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
          // Section: General Notifications
          _buildSettingsContainer([
            _buildSwitchTile(
              "Allow Notifications",
              "Enable or disable all notifications",
              allowNotifications,
              (val) => setState(() => allowNotifications = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              "Push Notifications",
              "Receive push notifications",
              pushNotifications,
              (val) => setState(() => pushNotifications = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              "Email Notifications",
              "Receive updates via email",
              emailNotifications,
              (val) => setState(() => emailNotifications = val),
            ),
          ]),

          const SizedBox(height: 24),
          const Text(
            "Alerts",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Section: Alerts
          _buildSettingsContainer([
            _buildSwitchTile(
              "Sound",
              "Play sound for notifications",
              sound,
              (val) => setState(() => sound = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              "Vibration",
              "Vibrate when notification arrives",
              vibration,
              (val) => setState(() => vibration = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              "Show on Lock Screen",
              "Display notifications on lock screen",
              showOnLockScreen,
              (val) => setState(() => showOnLockScreen = val),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              "Show Preview",
              "Display notification content preview",
              showPreview,
              (val) => setState(() => showPreview = val),
            ),
          ]),

          const SizedBox(height: 24),
          const Text(
            "Quiet Mode",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Section: Quiet Mode
          _buildSettingsContainer([
            _buildSwitchTile(
              "Do Not Disturb",
              "Silence notifications temporarily",
              doNotDisturb,
              (val) => setState(() => doNotDisturb = val),
            ),
            const Divider(height: 1),
            _buildTimeTile("Quiet Hours Start", "10:00 PM"),
            const Divider(height: 1),
            _buildTimeTile("Quiet Hours End", "07:00 AM"),
          ]),

          const SizedBox(height: 32),

          // Reset Button
          Center(
            child: OutlinedButton(
              onPressed: () {
                // Logic to reset settings
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Reset to Default",
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w500,
                ),
              ),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: coolSky,
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

  Widget _buildTimeTile(String title, String time) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      trailing: const Icon(Icons.access_time, color: Colors.black87, size: 22),
      onTap: () {
        // Implement TimePicker logic here
      },
    );
  }
}
