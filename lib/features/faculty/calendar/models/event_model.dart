class EventModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final String type; // Meeting | Deadline | Review | Other
  final bool reminder;
  final String groupId;
  final String facultyId;

  EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.type,
    required this.reminder,
    required this.groupId,
    required this.facultyId,
  });
}