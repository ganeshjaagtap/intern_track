import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool allowNotifications = true;
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool showOnLockScreen = true;
  bool showPreview = true;
  bool doNotDisturb = false;

  TimeOfDay quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay quietEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "NOTIFICATION SETTINGS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// GENERAL
            _sectionTitle("General"),
            _settingsCard([
              _masterSwitch(),
              _divider(),
              _normalSwitch(
                "Push Notifications",
                "Receive push notifications",
                pushNotifications,
                (val) => setState(() => pushNotifications = val),
              ),
              _divider(),
              _normalSwitch(
                "Email Notifications",
                "Receive updates via email",
                emailNotifications,
                (val) => setState(() => emailNotifications = val),
              ),
            ]),

            const SizedBox(height: 20),

            /// ALERTS
            _sectionTitle("Alerts"),
            _settingsCard([
              _normalSwitch(
                "Sound",
                "Play sound for notifications",
                soundEnabled,
                (val) => setState(() => soundEnabled = val),
              ),
              _divider(),
              _normalSwitch(
                "Vibration",
                "Vibrate when notification arrives",
                vibrationEnabled,
                (val) => setState(() => vibrationEnabled = val),
              ),
              _divider(),
              _normalSwitch(
                "Show on Lock Screen",
                "Display notifications on lock screen",
                showOnLockScreen,
                (val) => setState(() => showOnLockScreen = val),
              ),
              _divider(),
              _normalSwitch(
                "Show Preview",
                "Display notification content preview",
                showPreview,
                (val) => setState(() => showPreview = val),
              ),
            ]),

            const SizedBox(height: 20),

            /// QUIET MODE
            _sectionTitle("Quiet Mode"),
            _settingsCard([
              _normalSwitch(
                "Do Not Disturb",
                "Silence notifications temporarily",
                doNotDisturb,
                (val) => setState(() => doNotDisturb = val),
              ),
              _divider(),
              _timeTile("Quiet Hours Start", quietStart, () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: quietStart,
                );
                if (picked != null) {
                  setState(() => quietStart = picked);
                }
              }),
              _divider(),
              _timeTile("Quiet Hours End", quietEnd, () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: quietEnd,
                );
                if (picked != null) {
                  setState(() => quietEnd = picked);
                }
              }),
            ]),

            const SizedBox(height: 30),

            /// RESET BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetSettings,
                child: const Text("Reset to Default"),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// MASTER SWITCH (Special Logic)
  Widget _masterSwitch() {
    return SwitchListTile(
      activeColor: const Color(0xFF6BB6FF),
      title: const Text("Allow Notifications"),
      subtitle: const Text("Enable or disable all notifications"),
      value: allowNotifications,
      onChanged: (val) {
        setState(() {
          allowNotifications = val;

          if (!val) {
            pushNotifications = false;
            emailNotifications = false;
            soundEnabled = false;
            vibrationEnabled = false;
            showOnLockScreen = false;
            showPreview = false;
            doNotDisturb = false;
          }
        });
      },
    );
  }

  /// NORMAL SWITCHES
  Widget _normalSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      activeColor: const Color(0xFF6BB6FF),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: allowNotifications ? onChanged : null,
    );
  }

  /// TIME PICKER TILE
  Widget _timeTile(String title, TimeOfDay time, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(time.format(context)),
      trailing: const Icon(Icons.access_time),
      onTap: allowNotifications ? onTap : null,
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// SETTINGS CARD
  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1);
  }

  void _resetSettings() {
    setState(() {
      allowNotifications = true;
      pushNotifications = true;
      emailNotifications = false;
      soundEnabled = true;
      vibrationEnabled = true;
      showOnLockScreen = true;
      showPreview = true;
      doNotDisturb = false;
      quietStart = const TimeOfDay(hour: 22, minute: 0);
      quietEnd = const TimeOfDay(hour: 7, minute: 0);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification settings reset")),
    );
  }
}
