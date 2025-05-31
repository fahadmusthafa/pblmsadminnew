import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  int? _selectedCourseId;
  int? get selectedCourseId => _selectedCourseId;

  int? _selectedUserId;
  int? get selectedUserId => _selectedUserId;

  String? _selectedUserName;
  String? get selectedUserName => _selectedUserName;

  String? _selectedUserEmail;
  String? get selectedUserEmail => _selectedUserEmail;

  int? _selectedModuleId;
  int? get selectedModuleId => _selectedModuleId;

  String? _selectedCourseName;
  String? get selectedCourseName => _selectedCourseName;

  String? _selectedUserPhoneNo;
  String? get selectedUserPhoneNo => _selectedUserPhoneNo;

  String? _selectedModuleName;
  String? get selectedModuleName => _selectedModuleName;

  int? _selectedAssignmentId;
  int? get selectedAssignmentId => _selectedAssignmentId;

  String? _selectedAssignmentName;
  String? get selectedAssignmentName => _selectedAssignmentName;
  int? _selectedStudentId;
  int? get selectedStudentId => _selectedStudentId;
  int? _selectedBatchId;
  int? get selectedBatchId => _selectedBatchId;

  bool _isViewingAllUsers = false;
  bool get isViewingAllUsers => _isViewingAllUsers;

  // Check if we're currently viewing modules
  bool get isViewingModules => _selectedCourseId != null;
  bool get isViewingLessons => _selectedModuleId != null;
  bool get isViewingAssignments => _selectedAssignmentId != null;
  bool get isViewingAttendance => _selectedUserId != null;

  void setIndex(int index) {
    _selectedIndex = index;

    _selectedCourseId = null;
    _selectedCourseName = null;

    _selectedModuleId = null;
    _selectedModuleName = null;

    _selectedAssignmentId = null;
    _selectedAssignmentName = null;

    _selectedStudentId = null;
    _selectedBatchId = null;

    notifyListeners();
  }

  void navigateToModules(int courseId, String courseName) {
    _selectedCourseId = courseId;
    _selectedCourseName = courseName;
    notifyListeners();
  }

  void navigateBackToCourses() {
    _selectedCourseId = null;
    _selectedCourseName = null;

    _selectedModuleId = null;
    _selectedModuleName = null;

    _selectedAssignmentId = null;
    _selectedAssignmentName = null;
    notifyListeners();
  }

  void navigateToLessons(int moduleId, String moduleName) {
    _selectedModuleId = moduleId;
    _selectedModuleName = moduleName;
    notifyListeners();
  }

  void navigateBackToModules() {
    _selectedModuleId = null;
    _selectedModuleName = null;
    _selectedAssignmentId = null;
    _selectedAssignmentName = null;
    notifyListeners();
  }

  void navigateToSubmissions(int assignmentId, String assignmentName) {
    _selectedAssignmentId = assignmentId;
    _selectedAssignmentName = assignmentName;
    notifyListeners();
  }

  void navigateBackToAssignments() {
    _selectedAssignmentId = null;
    _selectedAssignmentName = null;
    notifyListeners();
  }

  void navigateToAllUsers(int courseId, int batchId) {
    _selectedCourseId = courseId;
    _selectedBatchId = batchId;
    _isViewingAllUsers = true;
    notifyListeners();
  }

  void navigateBackToStudentManagement() {
    _selectedCourseId = null;
    _selectedBatchId = null;
    _isViewingAllUsers = false;
    notifyListeners();
  }

  void navigateToAttendance(
    int userId,
    String userName,
    String email,
    String phoneNumber,
  ) {
    _selectedUserId = userId;
    _selectedUserName = userName;
    _selectedUserEmail = email;
    _selectedUserPhoneNo = phoneNumber;

    notifyListeners();
  }

  void navigateBackToUserMg() {
    _selectedUserId = null;
    _selectedUserName = null;
    _selectedUserEmail = null;
    _selectedUserPhoneNo = null;
    notifyListeners();
  }
}
