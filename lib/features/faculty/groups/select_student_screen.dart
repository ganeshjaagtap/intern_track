import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/dashboard/models/student_model.dart';
import 'package:flutter_application_2/features/faculty/groups/group_model.dart';

class SelectStudentScreen extends StatefulWidget {
  final List<StudentModel> allStudents;
  final List<GroupModel> allGroups;

  const SelectStudentScreen({
    super.key,
    required this.allStudents,
    required this.allGroups,
  });

  @override
  State<SelectStudentScreen> createState() =>
      _SelectStudentScreenState();
}

class _SelectStudentScreenState
    extends State<SelectStudentScreen> {

  String searchQuery = "";

  bool isStudentAssigned(String enrollment) {
    for (var group in widget.allGroups) {
      if (group.students.contains(enrollment)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {

    final filteredStudents = widget.allStudents
        .where((student) =>
            student.enrollment.contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Student")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search Enrollment No",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                final isAssigned =
                    isStudentAssigned(student.enrollment);

                return ListTile(
                  title: Text(student.enrollment),
                  subtitle: Text(student.name),
                  enabled: !isAssigned,
                  trailing: isAssigned
                      ? const Text(
                          "Assigned",
                          style: TextStyle(
                              color: Colors.red),
                        )
                      : null,
                  onTap: isAssigned
                      ? null
                      : () {
                          Navigator.pop(
                              context, student);
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}