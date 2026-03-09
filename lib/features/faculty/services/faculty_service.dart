import '../models/faculty_model.dart';

class FacultyService {
  Future<Faculty> fetchFaculty() async {
    await Future.delayed(const Duration(seconds: 1));

    return Faculty(
      id: "F001",
      name: "Dr. Rahul Sharma",
      email: "rahul.sharma@college.edu",
      department: "Computer Engineering",
      interns: ["Aarav", "Riya", "Kunal"],
      tasks: ["Review Report", "Approve Internship", "Schedule Meeting"],
    );
  }
}
