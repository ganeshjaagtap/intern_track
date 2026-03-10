import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_details_screen.dart';

class ActiveInternshipsScreen extends StatelessWidget {
  const ActiveInternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Internships"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .where("internshipStatus", isEqualTo: "Ongoing")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Active Internships"));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: students.length,

            itemBuilder: (context, index) {

              final student =
                  students[index].data() as Map<String, dynamic>;

              final name = student["fullName"] ?? "Student";
              final company = student["company"] ?? "-";
              final role = student["internshipRole"] ?? "-";

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),

                child: ListTile(

                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(name.toString()[0]),
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text("$company • $role"),

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),

                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: const Text(
                      "Active",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// OPEN STUDENT DETAILS
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentDetailsScreen(student: student),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}