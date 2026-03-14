import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/HOD/screens/edit_mentor_profile_screen.dart';
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  void _handleLogout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF6BB6FF);
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: currentUid.isEmpty
          ? _buildProfileContent(
              context,
              primaryBlue: primaryBlue,
              name: "Mentor",
              email: FirebaseAuth.instance.currentUser?.email ?? "No Email",
              role: "Mentor",
              dept: "Not Set",
              college: "Not Set",
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildProfileContent(
                    context,
                    primaryBlue: primaryBlue,
                    name: "Mentor",
                    email:
                        FirebaseAuth.instance.currentUser?.email ?? "No Email",
                    role: "Mentor",
                    dept: "Not Set",
                    college: "Not Set",
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final String name =
                    (data['fullName'] ?? data['name'] ?? 'Mentor').toString();
                final String email = (data['email'] ??
                        FirebaseAuth.instance.currentUser?.email ??
                        'No Email')
                    .toString();
                final String role =
                    (data['designation'] ?? data['role'] ?? 'Mentor')
                        .toString();
                final String dept =
                    (data['dept'] ?? data['department'] ?? 'Not Set')
                        .toString();
                final String college =
                    (data['college'] ?? data['collegeName'] ?? 'Not Set')
                        .toString();
                final String profileImageUrl =
                    (data['profileImageUrl'] ?? '').toString();

                return _buildProfileContent(
                  context,
                  primaryBlue: primaryBlue,
                  name: name,
                  email: email,
                  role: role,
                  dept: dept,
                  college: college,
                  profileImageUrl: profileImageUrl,
                );
              },
            ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context, {
    required Color primaryBlue,
    required String name,
    required String email,
    required String role,
    required String dept,
    required String college,
    String profileImageUrl = '',
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 42,
                              color: primaryBlue,
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            name.isEmpty ? 'Mentor' : name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              role.isEmpty ? 'Mentor' : role,
                              style:  TextStyle(
                                color: primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _ProfileInfoRow(label: "Email", value: email),
                const SizedBox(height: 12),
                _ProfileInfoRow(label: "Role", value: role),
                const SizedBox(height: 12),
                _ProfileInfoRow(label: "Department", value: dept),
                const SizedBox(height: 12),
                _ProfileInfoRow(label: "College", value: college),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Settings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.person_outline,
                  title: "Edit Profile",
                  subtitle: "Update your personal information",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditMentorProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text("LOG OUT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF6BB6FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6BB6FF)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
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
            value.isEmpty ? 'Not Set' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
