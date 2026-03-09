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
  State<EventBottomSheet> createState() =>
      _EventBottomSheetState();
}

class _EventBottomSheetState
    extends State<EventBottomSheet> {

  final CalendarService _service = CalendarService();
  final TextEditingController _titleController =
      TextEditingController();

  String selectedType = "Meeting";
  bool reminder = false;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final events = _service.getEventsByDate(
        widget.selectedDate, widget.facultyId);

    return Container(
      padding: const EdgeInsets.all(20),
      height: 500,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [

          /// TITLE
          Text(
            "Events - ${widget.selectedDate.day}",
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15), 

          /// EXISTING EVENTS
          Expanded( 
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (_, i) {
                final event = events[i];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      "${event.type} • ${event.dateTime.hour}:${event.dateTime.minute}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _service.deleteEvent(event.id);
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(),

          /// ADD EVENT
          TextField(
            controller: _titleController,
            decoration:
                const InputDecoration(labelText: "Event Title"),
          ),

          const SizedBox(height: 10),

          DropdownButton<String>(
            value: selectedType,
            isExpanded: true,
            items: ["Meeting", "Deadline", "Review", "Other"]
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
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
                      initialTime: TimeOfDay.now());
                  setState(() {});
                },
                child: const Text("Pick Time"),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(reminder
                    ? Icons.notifications_active
                    : Icons.notifications_none),
                onPressed: () {
                  setState(() => reminder = !reminder);
                },
              )
            ],
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF6EA8DC),
            ),
            onPressed: () {
              if (_titleController.text.isEmpty ||
                  selectedTime == null) return;

              final dateTime = DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month,
                widget.selectedDate.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              _service.addEvent(EventModel(
                id:  Uuid().v4(),
                title: _titleController.text,
                dateTime: dateTime,
                type: selectedType,
                reminder: reminder,
                groupId: "groupA",
                facultyId: widget.facultyId,
              ));

              setState(() {
                _titleController.clear();
              });
            },
            child: const Text("Add Event"),
          )
        ],
      ),
    );
  }
}