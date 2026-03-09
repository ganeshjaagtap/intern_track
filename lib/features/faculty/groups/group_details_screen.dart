import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/dashboard/models/student_model.dart';
import 'package:flutter_application_2/features/faculty/groups/group_model.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;
  final List<GroupModel> allGroups;

  const GroupDetailsScreen({
    super.key,
    required this.group,
    required this.allGroups,
  });

  @override
  State<GroupDetailsScreen> createState() =>
      _GroupDetailsScreenState();
}

class _GroupDetailsScreenState
    extends State<GroupDetailsScreen> {

  // Generate students 237001–237073
  late List<StudentModel> allStudents;

  @override
  void initState() {
    super.initState();
    allStudents = List.generate(
      73,
      (index) {
        final enrollment = (237001 + index).toString();
        return StudentModel(
          enrollment: enrollment,
          name: "Student ${index + 1}",
        );
      },
    );
  }

  bool isStudentAssigned(String enrollment) {
    for (var group in widget.allGroups) {
      if (group.students.contains(enrollment) &&
          group.id != widget.group.id) {
        return true;
      }
    }
    return false;
  }

  void openStudentSelector() async {
    if (widget.group.students.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Maximum 5 students allowed in a group"),
        ),
      );
      return;
    }

    final selectedStudent =
        await showModalBottomSheet<StudentModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = "";

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredStudents = allStudents
                .where((student) => student.enrollment
                    .contains(searchQuery))
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                        0.75,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Select Student",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration:
                            const InputDecoration(
                          hintText:
                              "Search Enrollment No",
                          prefixIcon:
                              Icon(Icons.search),
                          border:
                              OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            filteredStudents.length,
                        itemBuilder:
                            (context, index) {
                          final student =
                              filteredStudents[
                                  index];
                          final assigned =
                              isStudentAssigned(
                                  student
                                      .enrollment);

                          return ListTile(
                            title: Text(
                                student.enrollment),
                            subtitle:
                                Text(student.name),
                            enabled: !assigned,
                            trailing: assigned
                                ? const Text(
                                    "Assigned",
                                    style: TextStyle(
                                        color:
                                            Colors.red),
                                  )
                                : null,
                            onTap: assigned
                                ? null
                                : () {
                                    Navigator.pop(
                                        context,
                                        student);
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedStudent != null) {
      setState(() {
        widget.group.students
            .add(selectedStudent.enrollment);
      });
    }
  }

  void removeStudent(int index) {
    setState(() {
      widget.group.students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: widget.group.students.isEmpty
          ? const Center(
              child: Text("No students added yet"),
            )
          : ListView.builder(
              itemCount:
                  widget.group.students.length,
              itemBuilder: (context, index) {
                final enrollment =
                    widget.group.students[index];

                return ListTile(
                  title: Text(enrollment),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        removeStudent(index),
                  ),
                );
              },
            ),
      floatingActionButton:
          widget.group.students.length < 5
              ? FloatingActionButton(
                  onPressed: openStudentSelector,
                  child:
                      const Icon(Icons.person_add),
                )
              : null,
    );
  }
}