import 'package:flutter/material.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CompanyMentorPerformanceScreen extends StatefulWidget {
  const CompanyMentorPerformanceScreen({super.key});

  @override
  State<CompanyMentorPerformanceScreen> createState() =>
      _CompanyMentorPerformanceScreenState();
}

class _CompanyMentorPerformanceScreenState
    extends State<CompanyMentorPerformanceScreen> {

  final List<Map<String, dynamic>> interns = [

    {
      "name": "John Doe",
      "college": "ABC College",
      "progress": 0.92,
      "tasks": 14
    },

    {
      "name": "Aisha Khan",
      "college": "XYZ Institute",
      "progress": 0.75,
      "tasks": 11
    },

    {
      "name": "Rohit Sharma",
      "college": "ABC College",
      "progress": 0.65,
      "tasks": 9
    },

    {
      "name": "Priya Mehta",
      "college": "LMN University",
      "progress": 0.85,
      "tasks": 13
    },

    {
      "name": "Karan Patel",
      "college": "XYZ Institute",
      "progress": 0.55,
      "tasks": 7
    },

  ];

  @override
  Widget build(BuildContext context) {

    double average =
        interns.map((e) => e["progress"]).reduce((a, b) => a + b) /
            interns.length;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("Intern Performance"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.analytics),
          )
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 5),

            const Text(
              "Performance Overview",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// SUMMARY CARDS

            Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    title: "Average",
                    value: "${(average * 100).round()}%",
                    icon: Icons.show_chart,
                    color: const Color(0xFFBFD1E3),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Top Performer",
                    value: "John",
                    icon: Icons.emoji_events,
                    color: const Color(0xFFE7D8AE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    title: "Total Interns",
                    value: interns.length.toString(),
                    icon: Icons.people,
                    color: const Color(0xFFC2D6CC),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Modules",
                    value: "18",
                    icon: Icons.menu_book,
                    color: const Color(0xFFE4CFC3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// SEARCH INTERN

            TextField(
              decoration: InputDecoration(
                hintText: "Search intern...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Intern Progress",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// INTERN LIST

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: interns.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {

                final intern = interns[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [

                      Row(
                        children: [

                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              intern["name"][0],
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
                                  intern["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  intern["college"],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "${(intern["progress"] * 100).round()}%",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      LinearProgressIndicator(
                        value: intern["progress"],
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            "${intern["tasks"]} tasks completed",
                            style: const TextStyle(fontSize: 12),
                          ),

                          const Text(
                            "View Details",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// WEEKLY PERFORMANCE

            const Text(
              "Weekly Performance",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                _weekBar("Mon", 0.6),
                _weekBar("Tue", 0.7),
                _weekBar("Wed", 0.9),
                _weekBar("Thu", 0.5),
                _weekBar("Fri", 0.8),
              ],
            ),

            const SizedBox(height: 30),

            /// ACTION BUTTONS

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Export Data"),
                    style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14)),
                    onPressed: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  /// WEEK BAR

  Widget _weekBar(String day, double value) {

    return Column(
      children: [

        Container(
          width: 18,
          height: 80,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: 80 * value,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(day, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}