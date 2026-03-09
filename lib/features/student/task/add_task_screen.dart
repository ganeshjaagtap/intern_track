import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  // Theme colors
  final Color coolSky = const Color(0xFF60B5FF);
  final Color jasmine = const Color(0xFFFFE588);
  final Color aquamarine = const Color(0xFF5EF2D5);
  final Color tangerine = const Color(0xFFF79D65);
  final Color strawberry = const Color(0xFFF35252);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDeadline;
  double progress = 0;
  bool isGroupTask = false;

  Future<void> pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  void saveTask() {
    Navigator.pop(context);
  }

  Widget inputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: coolSky),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: jasmine.withOpacity(0.25),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget progressSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Progress (${progress.toInt()}%)",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: aquamarine),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: aquamarine,
            inactiveTrackColor: aquamarine.withOpacity(.3),
            thumbColor: coolSky,
          ),
          child: Slider(
            value: progress,
            min: 0,
            max: 100,
            divisions: 10,
            label: "${progress.toInt()}%",
            onChanged: (value) {
              setState(() {
                progress = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget deadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Deadline",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tangerine)),
        const SizedBox(height: 6),
        InkWell(
          onTap: pickDeadline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: tangerine.withOpacity(.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: tangerine),
                const SizedBox(width: 10),
                Text(
                  selectedDeadline == null
                      ? "Pick deadline"
                      : DateFormat('dd MMM yyyy').format(selectedDeadline!),
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget groupToggle() {
    return Container(
      decoration: BoxDecoration(
        color: coolSky.withOpacity(.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        activeColor: aquamarine,
        title: const Text(
          "Group Task",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text("Enable if multiple people will work on this"),
        value: isGroupTask,
        onChanged: (value) {
          setState(() {
            isGroupTask = value;
          });
        },
      ),
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [coolSky, aquamarine],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Add Task",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [coolSky, aquamarine],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Create a New Task ",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Add Task"),
        backgroundColor: coolSky,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            header(),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  inputField("Task Title", titleController),
                  const SizedBox(height: 18),

                  inputField("Description", descriptionController, maxLines: 3),
                  const SizedBox(height: 18),

                  deadlinePicker(),
                  const SizedBox(height: 18),

                  progressSelector(),
                  const SizedBox(height: 18),

                  groupToggle(),
                  const SizedBox(height: 30),

                  saveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}