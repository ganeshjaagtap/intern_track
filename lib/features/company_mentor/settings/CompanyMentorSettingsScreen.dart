import 'package:flutter/material.dart';
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

  String name = "Company Mentor";
  String email = "mentor@company.com";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// PROFILE CARD

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person),
              ),

              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Text(email),

              trailing: IconButton(
                icon: const Icon(Icons.edit),

                onPressed: () async {

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        name: name,
                        email: email,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      name = result["name"];
                      email = result["email"];
                    });
                  }

                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// NOTIFICATIONS

          const Text(
            "Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Receive report updates"),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Enable dark theme"),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

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

          const SizedBox(height: 20),

          /// LOGOUT

          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {

                showDialog(
                  context: context,
                  builder: (context) {

                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text(
                          "Are you sure you want to logout?"
                      ),

                      actions: [

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),

                        ElevatedButton(
                          onPressed: () {

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                                  (route) => false,
                            );

                          },
                          child: const Text("Logout"),
                        ),
                      ],
                    );

                  },
                );

              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 3),
    );
  }
}