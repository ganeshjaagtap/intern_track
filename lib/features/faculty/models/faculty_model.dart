class Faculty {
  final String id;
  final String name;
  final String email;
  final String department;
  final List<String> interns;
  final List<String> tasks;

  Faculty({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.interns,
    required this.tasks,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      department: json['department'],
      interns: List<String>.from(json['interns'] ?? []),
      tasks: List<String>.from(json['tasks'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'interns': interns,
      'tasks': tasks,
    };
  }
}
