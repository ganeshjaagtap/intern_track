import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/dashboard/models/student_model.dart';
import 'package:flutter_application_2/features/faculty/groups/group_model.dart';
import 'group_details_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<GroupModel> groups = [];

  List<StudentModel> allStudents = List.generate(
    73,
    (index) {
      final enrollment = (237001 + index).toString();
      return StudentModel(
        enrollment: enrollment,
        name: "Student ${index + 1}",
      );
    },
  );

  void createGroup(String name) {
    setState(() {
      groups.add(
        GroupModel(
          id: DateTime.now().toString(),
          name: name,
          students: [],
        ),
      );
    });
  }

  void showCreateDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Group"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter Group Name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                createGroup(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // important for keepAlive

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      /// ✅ AppBar Added (No Back Button)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6EA8DC),
        elevation: 0,
        title: const Text(
          "GROUPS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: groups.isEmpty
          ? const Center(
              child: Text(
                "No Groups Created",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(group.name),
                    subtitle:
                        Text("${group.students.length}/5 students"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailsScreen(
                            group: group,
                            allGroups: groups,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6EA8DC),
        onPressed: showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}