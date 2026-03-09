import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/student/task/add_task_screen.dart';

class Task {
  final String title;
  final String description;
  final DateTime deadline;
  final double progress;
  final List<String> members;
  final String status;

  Task({
    required this.title,
    required this.description,
    required this.deadline,
    required this.progress,
    required this.members,
    required this.status,
  });
}

class StudentTaskScreen extends StatefulWidget {
  const StudentTaskScreen({super.key});

  @override
  State<StudentTaskScreen> createState() => _StudentTaskScreenState();
}

class _StudentTaskScreenState extends State<StudentTaskScreen> {

  List<Task> tasks = [
    Task(
      title: "Design Dashboard",
      description: "Create internship tracker UI",
      deadline: DateTime.now().add(const Duration(days: 3)),
      progress: 0.4,
      members: ["S", "A", "G"],
      status: "todo",
    ),
    Task(
      title: "API Integration",
      description: "Connect backend APIs",
      deadline: DateTime.now().add(const Duration(days: 2)),
      progress: 0.7,
      members: ["S", "R"],
      status: "progress",
    ),
    Task(
      title: "Testing",
      description: "Perform UI testing",
      deadline: DateTime.now().add(const Duration(days: 1)),
      progress: 1,
      members: ["A", "G"],
      status: "done",
    ),
  ];

  String getRemainingTime(DateTime deadline) {
    Duration diff = deadline.difference(DateTime.now());

    if (diff.isNegative) {
      return "Expired";
    }

    int days = diff.inDays;
    int hours = diff.inHours % 24;

    return "$days d $hours h";
  }

  List<Task> getTasks(String status) {
    return tasks.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [

            buildColumn("To Do", "todo", Colors.orange),

            buildColumn("In Progress", "progress", Colors.blue),

            buildColumn("Completed", "done", Colors.green),

          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
  backgroundColor: const Color.fromARGB(255, 98, 174, 209),
  child: const Icon(Icons.add),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  },
),
    );
  }

  Widget buildColumn(String title, String status, Color color) {

    List<Task> columnTasks = getTasks(status);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),

        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: color,
                    child: Text(
                      columnTasks.length.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: columnTasks.length,
                itemBuilder: (context, index) {

                  final task = columnTasks[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        )
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          task.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          task.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        LinearProgressIndicator(
                          value: task.progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [

                            Row(
                              children: task.members.map((m) {

                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  child: CircleAvatar(
                                    radius: 12,
                                    child: Text(
                                      m,
                                      style:
                                          const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                );

                              }).toList(),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),

                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),

                              child: Text(
                                getRemainingTime(task.deadline),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}