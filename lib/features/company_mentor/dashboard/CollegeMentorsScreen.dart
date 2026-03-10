import 'package:flutter/material.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CollegeMentorsScreen extends StatefulWidget {
  const CollegeMentorsScreen({super.key});

  @override
  State<CollegeMentorsScreen> createState() => _CollegeMentorsScreenState();
}

class _CollegeMentorsScreenState extends State<CollegeMentorsScreen> {

  final List<Map<String, dynamic>> mentors = [

    {
      "name": "Dr. Rahul Sharma",
      "college": "ABC Engineering College",
      "email": "rahul.sharma@abc.edu",
      "phone": "+91 9876543210",
      "interns": 4,
    },

    {
      "name": "Prof. Neha Verma",
      "college": "XYZ Institute of Technology",
      "email": "neha.verma@xyz.edu",
      "phone": "+91 9876500011",
      "interns": 3,
    },

    {
      "name": "Dr. Amit Kulkarni",
      "college": "LMN University",
      "email": "amit.kulkarni@lmn.edu",
      "phone": "+91 9988776655",
      "interns": 2,
    },

    {
      "name": "Prof. Sneha Patil",
      "college": "ABC Engineering College",
      "email": "sneha.patil@abc.edu",
      "phone": "+91 9090909090",
      "interns": 5,
    },

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("College Mentors"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.school),
          )
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "College Mentor Directory",
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
                    title: "Total Mentors",
                    value: mentors.length.toString(),
                    icon: Icons.people,
                    color: const Color(0xFFBFD1E3),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Colleges",
                    value: "3",
                    icon: Icons.school,
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
                    title: "Active Interns",
                    value: "14",
                    icon: Icons.groups,
                    color: const Color(0xFFC2D6CC),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: "Departments",
                    value: "5",
                    icon: Icons.apartment,
                    color: const Color(0xFFE4CFC3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// SEARCH

            TextField(
              decoration: InputDecoration(
                hintText: "Search mentor or college...",
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
              "Mentor List",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// MENTOR LIST

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mentors.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (context, index) {

                final mentor = mentors[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),

                  child: Column(
                    children: [

                      Row(
                        children: [

                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              mentor["name"][0],
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
                                  mentor["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  mentor["college"],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${mentor["interns"]} interns",
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.email),
                              label: const Text("Email"),
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
                              icon: const Icon(Icons.phone),
                              label: const Text("Call"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              onPressed: () {},
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.chat),
                              label: const Text("Message"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            mentor["email"],
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),

                          Text(
                            mentor["phone"],
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
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
                    label: const Text("Export Contacts"),
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
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
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
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