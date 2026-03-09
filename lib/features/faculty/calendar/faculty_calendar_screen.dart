import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/calendar/calender_tile.dart';
import 'package:flutter_application_2/features/faculty/calendar/event_bottom_sheet.dart';
import 'package:flutter_application_2/features/faculty/calendar/models/event_model.dart';
import 'package:flutter_application_2/features/faculty/calendar/reminder_screen.dart';
import 'package:flutter_application_2/features/faculty/calendar/service/calendar_service.dart';

class FacultyCalendarScreen extends StatefulWidget {
  const FacultyCalendarScreen({super.key});

  @override
  State<FacultyCalendarScreen> createState() =>
      _FacultyCalendarScreenState();
}

class _FacultyCalendarScreenState
    extends State<FacultyCalendarScreen> {

  final CalendarService _service = CalendarService();

  String facultyId = "faculty1"; // backend ready
  DateTime selectedMonth = DateTime.now();

  final List<String> monthNames = const [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  /// EVENT COLOR
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

  @override
  Widget build(BuildContext context) {

    final events = _service.getAllEvents(facultyId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      /// ❌ NO BACK BUTTON (TAB SCREEN)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6EA8DC),
        elevation: 0,
        title: const Text(
          "CALENDAR",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReminderScreen(),
                    ),
                  );
                },
              ),
              if (events.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      events.length.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10),
                    ),
                  ),
                )
            ],
          )
        ],
      ),

      body: Column(
        children: [

          /// MONTH + YEAR
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
          Expanded(child: _calendarGrid()),
          _upcomingSection(),
        ],
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
            selectedMonth =
                DateTime(selectedMonth.year, val!);
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
          int year = DateTime.now().year - 2 + index;
          return DropdownMenuItem(
            value: year,
            child: Text(year.toString()),
          );
        }),
        onChanged: (val) {
          setState(() {
            selectedMonth =
                DateTime(val!, selectedMonth.month);
          });
        },
      ),
    );
  }

  Widget _weekdayRow() {
    const days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: days
            .map((d) => SizedBox(
                  width: 30,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _calendarGrid() {
    int daysInMonth = DateTime(
            selectedMonth.year,
            selectedMonth.month + 1,
            0)
        .day;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        int day = index + 1;

        DateTime currentDate = DateTime(
          selectedMonth.year,
          selectedMonth.month,
          day,
        );

        final dayEvents =
            _service.getEventsByDate(currentDate, facultyId);

        bool hasEvent = dayEvents.isNotEmpty;

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

            setState(() {});
          },
        );
      },
    );
  }

  Widget _upcomingSection() {
    List<EventModel> events =
        _service.getAllEvents(facultyId);

    events.sort((a, b) =>
        a.dateTime.compareTo(b.dateTime));

    final upcoming = events
        .where((e) =>
            e.dateTime.isAfter(DateTime.now()))
        .take(3)
        .toList();

    if (upcoming.isEmpty) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Events",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...upcoming.map((e) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      _getEventColor(e.type),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(e.title),
                subtitle: Text(
                    "${e.dateTime.day} ${monthNames[e.dateTime.month - 1]} • ${e.type}"),
              ))
        ],
      ),
    );
  }
}