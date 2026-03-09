import 'package:flutter/material.dart';

class FacultyDetailsScreen extends StatelessWidget {

  final Map<String, String> faculty;

  const FacultyDetailsScreen({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Avatar
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  faculty["name"]![0],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Heading
            const Text(
              "Faculty Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),

            const Divider(),

            _infoTile("Name", faculty["name"]),
            _infoTile("Employee ID", faculty["empId"]),
            _infoTile("Department", faculty["department"]),
            _infoTile("Designation", faculty["designation"]),
            _infoTile("Email", faculty["email"]),
            _infoTile("Phone", faculty["phone"]),
            _infoTile("Status", faculty["status"]),

            const Spacer(),

            /// Buttons Row
            Row(
              children: [

                /// Approve Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Faculty Approved"),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                /// Reject Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Faculty Rejected"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(value ?? "-"),
          ),
        ],
      ),
    );
  }
}