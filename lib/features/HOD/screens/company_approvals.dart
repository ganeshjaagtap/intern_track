import 'package:flutter/material.dart';

class CompanyApprovalsScreen extends StatelessWidget {

  final Map<String, String> company;

  const CompanyApprovalsScreen({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Company Logo Avatar
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.business,
                  size: 35,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Company Information
            const Text(
              "Company Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            _infoTile("Company Name", company["company"]),
            _infoTile("Industry", company["industry"]),
            _infoTile("Location", company["location"]),
            _infoTile("Website", company["website"]),
            _infoTile("HR Contact", company["hrName"]),
            _infoTile("HR Email", company["hrEmail"]),
            _infoTile("HR Phone", company["hrPhone"]),

            const SizedBox(height: 20),

            /// Internship Details
            const Text(
              "Internship Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            _infoTile("Role", company["role"]),
            _infoTile("Internship Type", company["type"]),
            _infoTile("Duration", company["duration"]),
            _infoTile("Start Date", company["start"]),
            _infoTile("End Date", company["end"]),
            _infoTile("Stipend", company["stipend"]),
            _infoTile("Students Required", company["students"]),

            const SizedBox(height: 20),

            /// Eligibility
            const Text(
              "Eligibility Criteria",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            _infoTile("Department", company["department"]),
            _infoTile("Minimum CGPA", company["cgpa"]),
            _infoTile("Required Skills", company["skills"]),

            const SizedBox(height: 30),

            /// Buttons
            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Company Approved"),
                        ),
                      );

                    },
                    child: const Text("Approve"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Company Rejected"),
                        ),
                      );

                    },
                    child: const Text("Reject"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String? value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}