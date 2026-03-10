import 'package:flutter/material.dart';
import 'GroupChatScreen.dart';
import 'HodChatScreen.dart';
import 'MentorListScreen.dart';

class CompanyMentorChat extends StatelessWidget {
  const CompanyMentorChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Chats"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// GROUP CHAT

          chatCard(
            icon: Icons.groups,
            iconColor: Colors.green,
            title: "Group Chat",
            subtitle: "Chat with all interns",
            unread: 12,
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GroupChatScreen(),
                ),
              );

            },
          ),

          const SizedBox(height: 12),

          /// COLLEGE MENTOR

          chatCard(
            icon: Icons.school,
            iconColor: Colors.orange,
            title: "College Mentor",
            subtitle: "Chat with assigned college mentor",
            unread: 3,
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MentorListScreen(),
                ),
              );

            },
          ),

          const SizedBox(height: 12),

          /// HOD CHAT

          chatCard(
            icon: Icons.admin_panel_settings,
            iconColor: Colors.blue,
            title: "HOD",
            subtitle: "Chat with Head of Department",
            unread: 0,
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HodChatScreen(),
                ),
              );

            },
          ),
        ],
      ),
    );
  }

  /// CHAT CARD

  Widget chatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int unread,
    required VoidCallback onTap,
  }) {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(

        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(subtitle),

        trailing: unread > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}