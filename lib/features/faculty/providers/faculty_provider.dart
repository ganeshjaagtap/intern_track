import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import '../services/faculty_service.dart';

class FacultyProvider extends ChangeNotifier {
  final FacultyService _service = FacultyService();

  Faculty? _faculty;
  bool _isLoading = false;

  Faculty? get faculty => _faculty;
  bool get isLoading => _isLoading;

  Future<void> loadFaculty() async {
    _isLoading = true;
    notifyListeners();

    _faculty = await _service.fetchFaculty();

    _isLoading = false;
    notifyListeners();
  }
}
