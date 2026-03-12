import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/calendar/calender_tile.dart';
import 'package:flutter_application_2/features/faculty/calendar/event_bottom_sheet.dart';
import 'package:flutter_application_2/features/faculty/calendar/models/event_model.dart';
import 'package:flutter_application_2/features/faculty/calendar/service/calendar_service.dart';

class FacultyCalendarScreen extends StatefulWidget {
  final bool showBackButton;

  const FacultyCalendarScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<FacultyCalendarScreen> createState() => _FacultyCalendarScreenState();
}

class _FacultyCalendarScreenState extends State<FacultyCalendarScreen> {
  final CalendarService _service = CalendarService();

  String facultyId = "";
  bool _isLoadingFaculty = true;
  DateTime selectedMonth = DateTime.now();

  final List<String> monthNames = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    _loadFacultyId();
  }

  Future<void> _loadFacultyId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Faculty not logged in");
      }

      final doc = await FirebaseFirestore.instance
          .collection("user")
          .doc(currentUser.uid)
          .get();

      final data = doc.data() as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        facultyId =
            (data["facultyId"] ?? data["uid"] ?? currentUser.uid).toString();
        _isLoadingFaculty = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFaculty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load calendar data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case "meeting":
        return const Color(0xFF4A90E2);
      case "deadline":
        return const Color(0xFFE74C3C);
      case "review":
        return const Color(0xFF27AE60);
      case "other":
        return const Color(0xFFF39C12);
      default:
        return Colors.grey;
    }
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFaculty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        backgroundColor: const Color(0xFF6EA8DC),
        elevation: 0,
        title: const Text(
          "CALENDAR",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _service.watchAllEvents(facultyId),
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _monthDropdown()),
                    const SizedBox(width: 10),
                    Expanded(child: _yearDropdown()),
                  ],
                ),
              ),
              _weekdayRow(),
              const SizedBox(height: 10),
              Expanded(child: _calendarGrid(events)),
              _upcomingSection(events),
            ],
          );
        },
      ),
    );
  }

  Widget _monthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: selectedMonth.month,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(12, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Text(monthNames[index]),
          );
        }),
        onChanged: (val) {
          setState(() {
            selectedMonth = DateTime(selectedMonth.year, val!);
          });
        },
      ),
    );
  }

  Widget _yearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: selectedMonth.year,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(5, (index) {
          final int year = DateTime.now().year - 2 + index;
          return DropdownMenuItem(
            value: year,
            child: Text(year.toString()),
          );
        }),
        onChanged: (val) {
          setState(() {
            selectedMonth = DateTime(val!, selectedMonth.month);
          });
        },
      ),
    );
  }

  Widget _weekdayRow() {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days
            .map(
              (day) => SizedBox(
                width: 30,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _calendarGrid(List<EventModel> events) {
    final int daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final int day = index + 1;
        final DateTime currentDate = DateTime(
          selectedMonth.year,
          selectedMonth.month,
          day,
        );

        final dayEvents = events
            .where((event) =>
                event.dateTime.year == currentDate.year &&
                event.dateTime.month == currentDate.month &&
                event.dateTime.day == currentDate.day)
            .toList();

        final bool hasEvent = dayEvents.isNotEmpty;
        Color? eventColor;

        if (hasEvent) {
          eventColor = _getEventColor(dayEvents.first.type);
        }

        return CalendarDayTile(
          day: day,
          hasEvent: hasEvent,
          eventColor: eventColor,
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => EventBottomSheet(
                selectedDate: currentDate,
                facultyId: facultyId,
              ),
            );
          },
        );
      },
    );
  }

  Widget _upcomingSection(List<EventModel> events) {
    final todayStart = _startOfToday();
    final upcoming = events
        .where((e) => !e.dateTime.isBefore(todayStart))
        .toList();

    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final nearestUpcoming = upcoming.take(3).toList();

    if (nearestUpcoming.isEmpty) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Events",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...nearestUpcoming.map(
            (event) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _getEventColor(event.type),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: Text(event.title),
              subtitle: Text(
                "${event.dateTime.day} ${monthNames[event.dateTime.month - 1]} • ${event.type}",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
