import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'completed_internship_details_screen.dart';

class CompletedInternshipsScreen extends StatelessWidget {
  const CompletedInternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Internships"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .where("internshipStatus", isEqualTo: "Completed")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Completed Internships"));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,

            itemBuilder: (context, index) {

              final student =
                  students[index].data() as Map<String, dynamic>;

              final name = student["fullName"] ?? "Student";
              final company = student["company"] ?? "-";
              final role = student["internshipRole"] ?? "-";

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: CircleAvatar(
                    child: Text(name.toString()[0]),
                  ),

                  title: Text(name),

                  subtitle: Text("$company • $role"),

                  trailing: const Text(
                    "Completed",
                    style: TextStyle(color: Colors.green),
                  ),

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompletedInternshipDetailsScreen(
                                student: student),
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