import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String type; // Meeting | Deadline | Review | Other
  final bool reminder;
  final String facultyId;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    required this.reminder,
    required this.facultyId,
  });

  factory EventModel.fromMap(Map<String, dynamic> data, String documentId) {
    final rawDate = data['dateTime'];
    final dateTime = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    return EventModel(
      id: documentId,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      dateTime: dateTime,
      type: (data['type'] ?? 'Other').toString(),
      reminder: data['reminder'] == true,
      facultyId: (data['facultyId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type,
      'reminder': reminder,
      'facultyId': facultyId,
    };
  }
}
