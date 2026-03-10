import 'package:flutter/material.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CompanyMentorAttendanceScreen extends StatefulWidget {
  const CompanyMentorAttendanceScreen({super.key});

  @override
  State<CompanyMentorAttendanceScreen> createState() =>
      _CompanyMentorAttendanceScreenState();
}

class _CompanyMentorAttendanceScreenState
    extends State<CompanyMentorAttendanceScreen> {

  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> interns = [
    {
      "name": "John Doe",
      "college": "ABC College",
      "status": "Present"
    },
    {
      "name": "Aisha Khan",
      "college": "XYZ Institute",
      "status": "Absent"
    },
    {
      "name": "Rohit Sharma",
      "college": "ABC College",
      "status": "Present"
    },
    {
      "name": "Priya Mehta",
      "college": "LMN University",
      "status": "Present"
    },
    {
      "name": "Karan Patel",
      "college": "XYZ Institute",
      "status": "Absent"
    },
  ];

  @override
  Widget build(BuildContext context) {

    int presentCount =
        interns.where((e) => e["status"] == "Present").length;
    int absentCount =
        interns.where((e) => e["status"] == "Absent").length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("Attendance Overview"),
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

            /// DATE SELECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  "Today's Attendance",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                TextButton.icon(
                  onPressed: () async {

                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Change"),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// SUMMARY CARDS
            Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    title: "Total Interns",
                    value: interns.length.toString(),
                    icon: Icons.people,
                    color: const Color(0xFFBFD1E3),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Present",
                    value: presentCount.toString(),
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
                    title: "Absent",
                    value: absentCount.toString(),
                    icon: Icons.cancel,
                    color: const Color(0xFFE4CFC3),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Attendance %",
                    value:
                        "${((presentCount / interns.length) * 100).round()}%",
                    icon: Icons.show_chart,
                    color: const Color(0xFFE7D8AE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// SEARCH BAR
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

            const SizedBox(height: 20),

            const Text(
              "Intern Attendance",
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

                return ListTile(

                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      intern["name"][0],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  title: Text(intern["name"]),
                  subtitle: Text(intern["college"]),

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: intern["status"] == "Present"
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      intern["status"],
                      style: TextStyle(
                        color: intern["status"] == "Present"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    label: const Text("Export Report"),
                    style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14)),
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
                            const EdgeInsets.symmetric(vertical: 14)),
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
}