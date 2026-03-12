class GroupModel {
  String id;
  String name;
  List<String> students; // Stores the UIDs of the students
  static const int maxStudents = 5;

  GroupModel({
    required this.id,
    required this.name,
    required this.students,
  });

  /// Logic to check if more students can join (keeps your original logic)
  bool canAddStudent() {
    return students.length < maxStudents;
  }

  /// ✅ Convert Firestore Document to GroupModel object
  /// This is used when reading data from Firebase
  factory GroupModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GroupModel(
      id: documentId,
      name: data['groupName'] ?? 'Unnamed Group',
      // Safely converts the Firestore dynamic list to a List of Strings
      students: List<String>.from(data['studentIds'] ?? []),
    );
  }

  /// ✅ Convert GroupModel object to Map
  /// This is used when saving or updating data in Firebase
  Map<String, dynamic> toMap(String facultyUid) {
    return {
      'groupId': id,
      'groupName': name,
      'studentIds': students,
      'createdBy': facultyUid, // Track which faculty created the group
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}