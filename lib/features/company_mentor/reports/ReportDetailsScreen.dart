import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String internName;
  final String college;
  final String status;

  const ReportDetailsScreen({
    super.key,
    required this.internName,
    required this.college,
    required this.status,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {

  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  Color statusColor() {
    if (status == "Approved") {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Report Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// INTERN INFO CARD

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: ListTile(

                leading: CircleAvatar(
                  radius: 25,
                  child: Text(
                    widget.internName[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                title: Text(
                  widget.internName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(widget.college),

                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// REPORT HEADER

            const Text(
              "Weekly Report",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Week 3 Report • Submitted on Aug 20",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            /// WORK DESCRIPTION

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  "This week the intern worked on implementing the login "
                  "screen UI for the internship tracking system. "
                  "They integrated form validation, improved UI responsiveness, "
                  "and tested navigation across dashboard modules.",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TASKS COMPLETED

            const Text(
              "Tasks Completed",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _taskTile("Designed Login Screen UI"),
            _taskTile("Implemented validation for login form"),
            _taskTile("Connected navigation to dashboard"),
            _taskTile("Fixed layout issues on smaller screens"),

            const SizedBox(height: 20),

            /// GITHUB LINK

            const Text(
              "Project Repository",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: const Text("GitHub Repository"),
                subtitle: const Text("github.com/intern-project"),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 30),

            /// APPROVE BUTTON

            if (status == "Pending")
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(

                  icon: const Icon(Icons.check),

                  label: const Text("Approve Report"),

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  onPressed: () {

                    setState(() {
                      status = "Approved";
                    });

                    Navigator.pop(context, "Approved");
                  },
                ),
              ),

            if (status == "Approved")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "This report has already been approved.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// TASK ITEM

  Widget _taskTile(String text) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(text),
    );
  }
}