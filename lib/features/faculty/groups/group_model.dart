class GroupModel {
  String id;
  String name;
  List<String> students; // student IDs or names

  GroupModel({
    required this.id,
    required this.name,
    required this.students,
  });

  bool canAddStudent() {
    return students.length < 5;
  }
}