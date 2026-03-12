import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/calendar/models/event_model.dart';
import 'package:flutter_application_2/features/faculty/calendar/service/calendar_service.dart';
import 'package:uuid/uuid.dart';

class EventBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final String facultyId;

  const EventBottomSheet({
    super.key,
    required this.selectedDate,
    required this.facultyId,
  });

  @override
  State<EventBottomSheet> createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends State<EventBottomSheet> {
  final CalendarService _service = CalendarService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedType = "Meeting";
  bool reminder = false;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createStudentNotifications({
    required String eventId,
    required DateTime dateTime,
    required String title,
    required String description,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final facultyDoc = await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUser.uid)
        .get();

    final facultyData = facultyDoc.data() as Map<String, dynamic>? ?? {};
    final facultyName =
        (facultyData["fullName"] ?? "Faculty Member").toString();

    final studentSnapshot = await FirebaseFirestore.instance
        .collection("user")
        .where("role", isEqualTo: "student")
        .where("facultyId", isEqualTo: widget.facultyId)
        .get();

    if (studentSnapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();

    for (final studentDoc in studentSnapshot.docs) {
      final notificationRef =
          FirebaseFirestore.instance.collection("notifications").doc();

      batch.set(notificationRef, {
        "eventId": eventId,
        "title": title,
        "desc": description,
        "type": "event",
        "senderName": facultyName,
        "senderRole": "Faculty",
        "senderId": currentUser.uid,
        "target": "student",
        "recipientId": studentDoc.id,
        "recipientRole": "student",
        "facultyId": widget.facultyId,
        "eventType": selectedType,
        "eventDateTime": Timestamp.fromDate(dateTime),
        "createdAt": FieldValue.serverTimestamp(),
        "isRead": false,
      });
    }

    await batch.commit();
  }

  Future<void> _addEvent() async {
    if (_titleController.text.trim().isEmpty || selectedTime == null) {
      return;
    }

    final selectedDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (selectedDay.isBefore(_startOfToday())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Events cannot be added for previous dates."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final dateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    final eventId = const Uuid().v4();

    try {
      await _service.addEvent(
        EventModel(
          id: eventId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: dateTime,
          type: selectedType,
          reminder: reminder,
          facultyId: widget.facultyId,
        ),
      );

      await _createStudentNotifications(
        eventId: eventId,
        dateTime: dateTime,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        selectedTime = null;
        reminder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add event: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final confirmDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete this event?"),
            content: const Text(
              "This will remove the event from the calendar and delete linked student notifications.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) {
      return;
    }

    try {
      await _service.deleteEvent(eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete event: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 560,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Text(
                "Events - ${widget.selectedDate.day}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: StreamBuilder<List<EventModel>>(
                  stream: _service.watchEventsByDate(
                    widget.selectedDate,
                    widget.facultyId,
                  ),
                  builder: (context, snapshot) {
                    final events = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (_, i) {
                        final event = events[i];
                        final time =
                            "${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}";

                        return ListTile(
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${event.type} • $time"),
                              if (event.description.isNotEmpty)
                                Text(
                                  event.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteEvent(event.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration:
                          const InputDecoration(labelText: "Event Title"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Event Details",
                        hintText: "Add useful details for students",
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: ["Meeting", "Deadline", "Review", "Other"]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedType = val!);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: Text(
                            selectedTime == null
                                ? "Pick Time"
                                : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            reminder
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                          ),
                          onPressed: () {
                            setState(() => reminder = !reminder);
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EA8DC),
                      ),
                      onPressed: _isSubmitting ? null : _addEvent,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Add Event"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
