import 'package:flutter/material.dart';
import '../chat/ChatScreen.dart';

class InternDetailsScreen extends StatelessWidget {
  const InternDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Intern Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PROFILE CARD

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 30),
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "John Doe",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text("ABC Engineering College"),

                        SizedBox(height: 4),

                        Text("Flutter Developer Intern"),
                      ],
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "92%",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ATTENDANCE SUMMARY

            const Text(
              "Attendance Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [

                    Column(
                      children: [
                        Text("Total"),
                        SizedBox(height: 4),
                        Text("30",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),

                    Column(
                      children: [
                        Text("Present"),
                        SizedBox(height: 4),
                        Text("27",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),

                    Column(
                      children: [
                        Text("Absent"),
                        SizedBox(height: 4),
                        Text("3",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// PROGRESS SECTION

            const Text(
              "Internship Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            progressTile("Week 1", 1.0),
            progressTile("Week 2", 0.8),
            progressTile("Week 3", 0.6),
            progressTile("Week 4", 0.9),

            const SizedBox(height: 20),

            /// WEEKLY REPORTS

            const Text(
              "Weekly Reports",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            reportTile("Week 1", "Approved", Colors.green),
            reportTile("Week 2", "Approved", Colors.green),
            reportTile("Week 3", "Pending", Colors.orange),
            reportTile("Week 4", "Not Submitted", Colors.red),

            const SizedBox(height: 20),

            /// COLLEGE MENTOR CONTACT

            const Text(
              "College Mentor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Prof. R. S. Sindge"),
                subtitle: const Text("rssindge@college.edu"),

                trailing: IconButton(
                  icon: const Icon(Icons.message),

                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatScreen(
                          title: "Prof. R. S. Sindge",
                        ),
                      ),
                    );

                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ACTIVITY TIMELINE

            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            activityTile("Submitted Week 3 Report"),
            activityTile("Completed Task: Login Screen"),
            activityTile("Marked Present Today"),
            activityTile("Uploaded GitHub Repository"),
          ],
        ),
      ),
    );
  }

  /// PROGRESS TILE

  Widget progressTile(String week, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(week),

          const SizedBox(height: 4),

          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  /// REPORT TILE

  Widget reportTile(String week, String status, Color color) {
    return Card(
      child: ListTile(
        title: Text(week),
        trailing: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// ACTIVITY TILE

  Widget activityTile(String text) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(text),
    );
  }
}