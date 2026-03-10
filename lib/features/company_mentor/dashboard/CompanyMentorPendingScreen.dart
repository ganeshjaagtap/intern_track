import 'package:flutter/material.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CompanyMentorPendingScreen extends StatefulWidget {
  const CompanyMentorPendingScreen({super.key});

  @override
  State<CompanyMentorPendingScreen> createState() =>
      _CompanyMentorPendingScreenState();
}

class _CompanyMentorPendingScreenState
    extends State<CompanyMentorPendingScreen> {

  final List<Map<String, dynamic>> pendingReports = [

    {
      "name": "John Doe",
      "college": "ABC College",
      "week": "Week 8",
      "title": "UI Module Report",
      "date": "2 days ago",
    },

    {
      "name": "Aisha Khan",
      "college": "XYZ Institute",
      "week": "Week 7",
      "title": "Backend API Integration",
      "date": "1 day ago",
    },

    {
      "name": "Rohit Sharma",
      "college": "ABC College",
      "week": "Week 6",
      "title": "Database Module",
      "date": "3 days ago",
    },

    {
      "name": "Priya Mehta",
      "college": "LMN University",
      "week": "Week 5",
      "title": "Authentication System",
      "date": "Today",
    },

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("Pending Reports"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          )
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Reports Awaiting Approval",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// SUMMARY CARDS

            Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    title: "Total Pending",
                    value: pendingReports.length.toString(),
                    icon: Icons.pending_actions,
                    color: const Color(0xFFE7D8AE),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Reviewed Today",
                    value: "3",
                    icon: Icons.check_circle,
                    color: const Color(0xFFC2D6CC),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    title: "Rejected",
                    value: "1",
                    icon: Icons.cancel,
                    color: const Color(0xFFE4CFC3),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Approved",
                    value: "12",
                    icon: Icons.verified,
                    color: const Color(0xFFBFD1E3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// SEARCH BAR

            TextField(
              decoration: InputDecoration(
                hintText: "Search report...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Pending Reports",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// REPORT LIST

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingReports.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {

                final report = pendingReports[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),

                  child: Column(
                    children: [

                      Row(
                        children: [

                          CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Text(
                              report["name"][0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  report["title"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  "${report["name"]} • ${report["college"]}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  report["week"],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            report["date"],
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text("View"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              onPressed: () {},
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              onPressed: () {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Report Approved")),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              onPressed: () {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Report Rejected")),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// ACTION BUTTONS

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Export Reports"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    onPressed: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar:
      const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  /// SUMMARY CARD

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
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
            child: Icon(icon),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}