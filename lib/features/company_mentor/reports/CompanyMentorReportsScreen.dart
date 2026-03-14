import 'package:flutter/material.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'ReportDetailsScreen.dart';

class CompanyMentorReportsScreen extends StatefulWidget {
  const CompanyMentorReportsScreen({super.key});

  @override
  State<CompanyMentorReportsScreen> createState() =>
      _CompanyMentorReportsScreenState();
}

class _CompanyMentorReportsScreenState
    extends State<CompanyMentorReportsScreen> {

  TextEditingController searchController = TextEditingController();

  String filter = "Approved First";

  final List<Map<String, dynamic>> interns = [

    {
      "name": "John Doe",
      "college": "ABC Engineering College",
      "status": "Approved",
      "profileImageUrl": ""
    },

    {
      "name": "Aisha Khan",
      "college": "XYZ Institute",
      "status": "Pending",
      "profileImageUrl": ""
    },

    {
      "name": "Rohit Sharma",
      "college": "ABC Engineering College",
      "status": "Approved",
      "profileImageUrl": ""
    },

    {
      "name": "Priya Mehta",
      "college": "LMN University",
      "status": "Pending",
      "profileImageUrl": ""
    },
  ];

  List<Map<String, dynamic>> filteredInterns = [];

  @override
  void initState() {
    super.initState();
    filteredInterns = List.from(interns);
    sortInterns();
  }

  void searchIntern(String query) {

    final results = interns.where((intern) {
      final name = intern["name"].toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    filteredInterns = results;
    sortInterns();
  }

  void sortInterns() {

    if (filter == "Approved First") {

      filteredInterns.sort((a, b) {
        if (a["status"] == b["status"]) return 0;
        if (a["status"] == "Approved") return -1;
        return 1;
      });

    } else {

      filteredInterns.sort((a, b) {
        if (a["status"] == b["status"]) return 0;
        if (a["status"] == "Pending") return -1;
        return 1;
      });

    }

    setState(() {});
  }

  Color statusColor(String status) {
    if (status == "Approved") return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Reports"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Report Directory",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// SEARCH BAR

            TextField(
              controller: searchController,
              onChanged: searchIntern,
              decoration: InputDecoration(
                hintText: "Search intern report...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SORT DROPDOWN

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  "Sort Reports",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                DropdownButton<String>(
                  value: filter,
                  items: const [

                    DropdownMenuItem(
                      value: "Approved First",
                      child: Text("Approved First"),
                    ),

                    DropdownMenuItem(
                      value: "Pending First",
                      child: Text("Pending First"),
                    ),
                  ],
                  onChanged: (value) {

                    setState(() {
                      filter = value!;
                      sortInterns();
                    });

                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// REPORT LIST

            Expanded(
              child: ListView.builder(

                itemCount: filteredInterns.length,

                itemBuilder: (context, index) {

                  final intern = filteredInterns[index];
                  final imageUrl = (intern["profileImageUrl"] ?? "").toString();

                  return GestureDetector(

                    onTap: () async {

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailsScreen(
                            internName: intern["name"],
                            college: intern["college"],
                            status: intern["status"],
                            profileImageUrl: intern["profileImageUrl"],
                          ),
                        ),
                      );

                      if (result == "Approved") {

                        setState(() {
                          intern["status"] = "Approved";
                        });

                        sortInterns();
                      }
                    },

                    child: Container(

                      margin: const EdgeInsets.only(bottom: 14),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                          )
                        ],
                      ),

                      child: Row(
                        children: [

                          /// AVATAR

                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? Text(
                                    intern["name"][0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  )
                                : null,
                          ),

                          const SizedBox(width: 12),

                          /// NAME + COLLEGE

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  intern["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  intern["college"],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// STATUS BADGE

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(intern["status"])
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              intern["status"],
                              style: TextStyle(
                                color: statusColor(intern["status"]),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM BAR (Reports index = 2)

      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 2),
    );
  }
}
