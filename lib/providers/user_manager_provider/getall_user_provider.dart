import 'package:flutter/material.dart'; // Changed from widgets.dart to material.dart
import 'package:pb_lms/models/user_managemet_model/UserManagerModel.dart';
import 'package:pb_lms/services/user_management_service/userManager_service.dart';
import 'package:pb_lms/utilities/token_manager.dart';

class AdminProvider with ChangeNotifier {
  void clearModuleData() {
    notifyListeners();
  }

  bool _isLoading = false;
  // Removed duplicate isLoading variable

  String? _token;
  String? _errorMessage;
  String? _error;

  // Getter for isLoading
  bool get isLoading => _isLoading;
  // Getter for token 
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  final userApiService _apiService =
      userApiService(); // Made it final and initialized properly

  List<AdminAllusersmodel> _users = [];

  List<AdminAllusersmodel>? get users => _users;

  // Add method to set token
   Future<void> initializeToken() async {
    try {
      _token = await TokenManager.getToken();
      if (_token == null || _token!.isEmpty) {
        _error = 'No valid token found. Please login again.';
        print('Token initialization failed: Token is null or empty');
      } else {
        _error = null;
        print('Token initialized successfully');
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize token: $e';
      print('Token initialization error: $e');
      notifyListeners();
    }
  }

  Future<void> _ensureTokenLoaded() async {
    if (_token == null || _token!.isEmpty) {
      _token = await TokenManager.getToken();
    }
    if (_token == null || _token!.isEmpty) {
      _error = 'Authentication required. Please login again.';
      throw Exception('Token is missing or invalid. Please login again.');
    }
  }

  Future<void> AdminfetchallusersProvider() async {
    print('111111111111');
    // if (_token == null || _token!.isEmpty) {
    //   _errorMessage = 'Token is missing';
    //   notifyListeners();
    //   throw Exception(_errorMessage);
    // }
    print('22222222222');
    print(_token);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final _token = await TokenManager.getToken();
      final fetchedUsers = await _apiService.fetchAdminUsers(_token!);
      _users = fetchedUsers;

      // Print the fetched users for debugging
      print('Fetched users: $_users');
    } catch (e) {
      _errorMessage = 'Error fetching users: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when data is updated
    }
  }

  Future<void> adminApproveUserprovider({
    required int userId,
    required String role,
    required String action, // 'approve' or 'reject'
  }) async {
    // if (_token == null || _token!.isEmpty) {
    //   throw Exception('Token is missing');

    try {
      final _token = await TokenManager.getToken();
      final isSuccess = await _apiService.adminApproveUser(
        token: _token!,
        userId: userId,
        role: role,
        action: action,
      );

      if (isSuccess) {
        print('User successfully ${action}ed.');
        // Refresh the users list after successful action
        await AdminfetchallusersProvider();
      }
    } catch (e) {
      print('Error processing user approval/rejection: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  List<AttendanceHistory> _attendanceHistory = [];
  List<AttendanceHistory> get attendanceHistory => _attendanceHistory;

  Future<void> fetchAttendanceHistoryProvider(int studentId) async {
    try {
      final _token = await TokenManager.getToken();
      final response = await _apiService.fetchAttendanceHistory(
        studentId,
        _token!,
      );
      _attendanceHistory = response;
      notifyListeners();
    } catch (e) {
      print('Error fetching attendance history: $e');
      rethrow;
    }
  }

  Future<void> updateStudentAttendance({
    required int attendanceId,
    required String status,
  }) async {
    final _token = await TokenManager.getToken();
    if (_token == null) throw Exception('Token is missing');

    try {
      
      await _apiService.updateStudentAttendance(_token, attendanceId, status);

      // Update local list
      final index = _attendanceHistory.indexWhere(
        (att) => att.id == attendanceId,
      );
      if (index != -1) {
        // Create a new instance with updated status
        final updatedAttendance = AttendanceHistory(
          id: _attendanceHistory[index].id,
          studentId: _attendanceHistory[index].studentId,
          batchId: _attendanceHistory[index].batchId,
          date: _attendanceHistory[index].date,
          status: status,
          createdAt: _attendanceHistory[index].createdAt,
          updatedAt:
              DateTime.now().toIso8601String(), // Update with current timestamp
          studentBatch: _attendanceHistory[index].studentBatch,
        );

        _attendanceHistory[index] = updatedAttendance;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }
}
