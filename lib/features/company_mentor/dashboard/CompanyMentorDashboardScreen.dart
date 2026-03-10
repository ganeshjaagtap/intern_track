import 'package:flutter/material.dart';

import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'MentorAttendanceScreen.dart';
import 'CompanyMentorPendingScreen.dart';
import 'CompanyMentorPerformanceScreen.dart';
import 'CollegeMentorsScreen.dart';
import '../notifications/CompanyMentorNotificationScreen.dart';

class CompanyMentorDashboardScreen extends StatelessWidget {
  const CompanyMentorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        actions: [

          IconButton(
            icon: const Icon(Icons.notifications_none),

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompanyMentorNotificationScreen(),
                ),
              );

            },
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            /// COMPANY DETAILS CARD
            //////////////////////////////////////////////////////

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [

                  Container(
                    height: 60,
                    width: 60,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEF7),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.business,
                      size: 32,
                      color: Colors.blueGrey,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Tech Surya IT Solutions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Chh. Sambhajinagar, Maharashtra",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: const [

                            Icon(Icons.people, size: 18, color: Colors.blue),
                            SizedBox(width: 4),
                            Text("12 Interns"),

                            SizedBox(width: 16),

                            Icon(Icons.code, size: 18, color: Colors.green),
                            SizedBox(width: 4),
                            Text("Software Development"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            //////////////////////////////////////////////////////
            /// FIRST ROW
            //////////////////////////////////////////////////////

            Row(
              children: [

                Expanded(
                  child: GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CompanyMentorAttendanceScreen(),
                        ),
                      );

                    },

                    child: const MiniStatCard(
                      icon: Icons.how_to_reg,
                      value: "82%",
                      label: "Attendance",
                      bg: Color(0xFFD6E9FF),
                      iconColor: Colors.blue,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CompanyMentorPendingScreen(),
                        ),
                      );

                    },

                    child: const MiniStatCard(
                      icon: Icons.pending_actions,
                      value: "4",
                      label: "Pending",
                      bg: Color(0xFFFFE4B5),
                      iconColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            //////////////////////////////////////////////////////
            /// SECOND ROW
            //////////////////////////////////////////////////////

            Row(
              children: [

                Expanded(
                  child: GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CompanyMentorPerformanceScreen(),
                        ),
                      );

                    },

                    child: const MiniStatCard(
                      icon: Icons.trending_up,
                      value: "92%",
                      label: "Performance",
                      bg: Color(0xFFDFF5EA),
                      iconColor: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CollegeMentorsScreen(),
                        ),
                      );

                    },

                    child: const MiniStatCard(
                      icon: Icons.school,
                      value: "6",
                      label: "Mentors",
                      bg: Color(0xFFE8D5C4),
                      iconColor: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// TODAY ATTENDANCE BLOCK
            //////////////////////////////////////////////////////

            const Text(
              "Today's Attendance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CompanyMentorAttendanceScreen(),
                  ),
                );

              },

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.fact_check,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Fill Today's Attendance",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Mark intern attendance for today",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar:
          const CompanyMentorBottomBar(currentIndex: 0),
    );
  }
}

//////////////////////////////////////////////////////
// MINI STAT CARD
//////////////////////////////////////////////////////

class MiniStatCard extends StatelessWidget {

  final IconData icon;
  final String value;
  final String label;
  final Color bg;
  final Color iconColor;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}