import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hod_student_reports_screen.dart';

class HodStudentListScreen extends StatelessWidget {
  const HodStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .where("role", isEqualTo: "student")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,

            itemBuilder: (context, index) {

              final data =
                  students[index].data() as Map<String, dynamic>? ?? {};

              final name = data["fullName"] ?? "Student";
              final enrollment = data["enrollmentNo"] ?? "";
              
              // Use uid field if available (for matching with reports), otherwise use document id
              final studentId = data["uid"] ?? students[index].id;

              return ListTile(

                leading: CircleAvatar(
                  child: Text(name.toString().isNotEmpty
                      ? name[0].toUpperCase()
                      : "S"),
                ),

                title: Text(name),
                subtitle: Text(enrollment),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HodStudentReportsScreen(
                        studentId: studentId,
                        studentName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}