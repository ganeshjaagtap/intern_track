import 'package:flutter/material.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'InternDetailsScreen.dart';

class CompanyMentorInternsScreen extends StatefulWidget {
  const CompanyMentorInternsScreen({super.key});

  @override
  State<CompanyMentorInternsScreen> createState() =>
      _CompanyMentorInternsScreenState();
}

class _CompanyMentorInternsScreenState
    extends State<CompanyMentorInternsScreen> {

  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> interns = [

    {
      "name": "John Doe",
      "college": "ABC Engineering College",
      "progress": "92%"
    },

    {
      "name": "Aisha Khan",
      "college": "XYZ Institute",
      "progress": "75%"
    },

    {
      "name": "Rohit Sharma",
      "college": "ABC Engineering College",
      "progress": "65%"
    },

    {
      "name": "Priya Mehta",
      "college": "LMN University",
      "progress": "85%"
    },

    {
      "name": "Karan Patel",
      "college": "XYZ Institute",
      "progress": "55%"
    },
  ];

  List<Map<String, dynamic>> filteredInterns = [];

  @override
  void initState() {
    super.initState();
    filteredInterns = interns;
  }

  void searchIntern(String query) {

    final results = interns.where((intern) {
      final name = intern["name"].toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      filteredInterns = results;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Interns"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Intern Directory",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// SEARCH BAR

            TextField(
              controller: searchController,
              onChanged: searchIntern,
              decoration: InputDecoration(
                hintText: "Search intern...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// INTERN LIST

            Expanded(
              child: ListView.separated(

                itemCount: filteredInterns.length,

                separatorBuilder: (_, __) => const Divider(),

                itemBuilder: (context, index) {

                  final intern = filteredInterns[index];

                  return ListTile(

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InternDetailsScreen(),
                        ),
                      );
                    },

                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        intern["name"][0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      intern["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(intern["college"]),

                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        intern["progress"],
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 1),
    );
  }
}