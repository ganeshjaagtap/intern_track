import '../models/event_model.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final List<EventModel> _events = [];

  List<EventModel> getAllEvents(String facultyId) {
    return _events
        .where((e) => e.facultyId == facultyId)
        .toList();
  }

  List<EventModel> getEventsByDate(
      DateTime date, String facultyId) {
    return _events.where((e) =>
        e.facultyId == facultyId &&
        e.dateTime.year == date.year &&
        e.dateTime.month == date.month &&
        e.dateTime.day == date.day).toList();
  }

  void addEvent(EventModel event) {
    _events.add(event);
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
  }
}