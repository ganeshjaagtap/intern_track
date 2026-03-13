import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final CollectionReference _eventsRef =
      FirebaseFirestore.instance.collection('faculty_events');

  Stream<List<EventModel>> watchAllEvents(String facultyId) {
    return _eventsRef
        .where('facultyId', isEqualTo: facultyId)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return events;
    });
  }

  Stream<List<EventModel>> watchEventsByDate(DateTime date, String facultyId) {
    return watchAllEvents(facultyId).map(
      (events) => events
          .where((e) =>
              e.dateTime.year == date.year &&
              e.dateTime.month == date.month &&
              e.dateTime.day == date.day)
          .toList(),
    );
  }

  Future<void> addEvent(EventModel event) async {
    await _eventsRef.doc(event.id).set(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    final batch = FirebaseFirestore.instance.batch();

    batch.delete(_eventsRef.doc(id));

    final notificationSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('type', isEqualTo: 'event')
        .where('eventId', isEqualTo: id)
        .get();

    for (final doc in notificationSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
