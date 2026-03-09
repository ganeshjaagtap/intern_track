import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {

  /// THEME COLORS
  final Color coolSky = const Color(0xFF60B5FF);
  final Color aquamarine = const Color(0xFF5EF2D5);
  final Color jasmine = const Color(0xFFFFE588);

  /// TEXT CONTROLLERS
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  /// SAMPLE GROUPS (Replace later with backend groups)
  List<Map<String, dynamic>> groups = [
    {"name": "Group Alpha", "members": 4, "selected": false},
    {"name": "Group Beta", "members": 5, "selected": false},
    {"name": "Group Gamma", "members": 3, "selected": false},
  ];

  DateTime? deadline;

  /// DATE PICKER
  Future<void> pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }

  /// GROUP CARD
  Widget groupCard(int index) {
    final group = groups[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          group["selected"] = !group["selected"];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: group["selected"] ? aquamarine.withOpacity(.25) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: group["selected"] ? aquamarine : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [

            CircleAvatar(
              backgroundColor: coolSky,
              child: const Icon(Icons.group, color: Colors.white),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${group["members"]} members",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            Icon(
              group["selected"]
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: group["selected"] ? aquamarine : Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget inputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: jasmine.withOpacity(.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// DEADLINE PICKER
  Widget deadlinePicker() {
    return GestureDetector(
      onTap: pickDeadline,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: coolSky.withOpacity(.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [

            Icon(Icons.calendar_today, color: coolSky),

            const SizedBox(width: 10),

            Text(
              deadline == null
                  ? "Select Deadline"
                  : DateFormat("dd MMM yyyy").format(deadline!),
            )
          ],
        ),
      ),
    );
  }

  /// ASSIGN BUTTON
  Widget assignButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: coolSky,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          "Assign Task",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        backgroundColor: coolSky,
        title: const Text("Assign Task"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            inputField("Task Title", titleController),

            const SizedBox(height: 16),

            inputField("Description", descriptionController, maxLines: 3),

            const SizedBox(height: 16),

            const Text(
              "Select Groups",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return groupCard(index);
              },
            ),

            const SizedBox(height: 16),

            const Text(
              "Deadline",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            deadlinePicker(),

            const SizedBox(height: 24),

            assignButton(),
          ],
        ),
      ),
    );
  }
}