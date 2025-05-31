import 'package:flutter/material.dart';
import 'package:pb_lms/models/fahad/model.dart';
import 'package:pb_lms/services/fahad/services.dart';
import 'package:pb_lms/utilities/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthProvider with ChangeNotifier {
  final AdminAPI _apiService = AdminAPI();
  int? batchId;
  int? courseId;
  String? _token;
  List<Admincoursemodel> _course = [];
  bool _isLoading = false;
  Map<int, List<AdminCourseBatch>> _courseBatches = {};
  BatchStudentModel? _batchData;
  String? _error;
  String? _errorMessage;
  List<AdminAllusersmodel> _users = [];
  List<LeaveRequest> _leave = [];
  List<Transaction> _transactions = [];
  Map<int, AdminLiveLinkResponse> _liveBatch = {};

  List<Admincoursemodel> get course => _course;
  String? get token => _token;
  bool get isLoading => _isLoading;
  Map<int, List<AdminCourseBatch>> get courseBatches => _courseBatches;
  String? get error => _error;
  BatchStudentModel? get batchData => _batchData;
  List<Student> get students => _batchData?.students ?? [];
  List<LeaveRequest> get leave => _leave;
  String? get errorMessage => _errorMessage;
  List<AdminAllusersmodel> get users => _users;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  List<Transaction> get transactions => _transactions;
  Map<int, AdminLiveLinkResponse> get liveBatch => _liveBatch;

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

  Future<int?> getSavedCourseId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('courseId');
    } catch (e) {
      print('Error getting saved course ID: $e');
      return null;
    }
  }

  Future<void> savecourseId(int courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('courseId', courseId);
      this.courseId = courseId; // Update the instance variable
    } catch (e) {
      print('Error saving course ID: $e');
    }
  }

  Future<void> AdminfetchCoursesprovider() async {
    try {
      await _ensureTokenLoaded();

      _isLoading = true;
      _error = null;
      notifyListeners();

      _course = await _apiService.AdminfetchCoursesAPI(_token!);

      if (_course.isNotEmpty) {
        int courseId = _course.first.courseId;
        await savecourseId(courseId);
        print('Saved Course ID: $courseId');
      }

      print('Fetched courses: ${_course.length} courses');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch courses: $e';
      print('Error fetching courses: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> AdminfetchBatchForCourseProvider(int courseId) async {
    try {
      await _ensureTokenLoaded();

      _isLoading = true;
      _error = null;
      notifyListeners();

      final batches = await _apiService.AdminfetctBatchForCourseAPI(
        _token!,
        courseId,
      );
      _courseBatches[courseId] = batches;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch batches: $e';
      print('Error fetching batch for course: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> AdminfetchallusersBatchProvider(
    int courseId,
    int batchId,
  ) async {
    try {
      await _ensureTokenLoaded();

      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.AdminfetchUsersBatchAPI(
        _token!,
        courseId,
        batchId,
      );

      _batchData = response;
      _isLoading = false;
      print('Fetched batch data: ${_batchData?.students.length ?? 0} students');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch batch users: $e';
      print('Error fetching users: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> AdmindeleteUserFromBatchprovider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    try {
      await _ensureTokenLoaded();

      final isSuccess = await _apiService.AdmindeleteUserFromBatch(
        token: _token!,
        courseId: courseId,
        batchId: batchId,
        userId: userId,
      );

      if (isSuccess) {
        print('User successfully deleted from batch.');
        // Refresh the batch data after deletion
        await AdminfetchallusersBatchProvider(courseId, batchId);
      } else {
        _error = 'Failed to delete user from batch';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error deleting user: $e';
      print('Error deleting user from batch: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> manageStudentAccess({
    required int studentId,
    required int batchId,
    required String action,
  }) async {
    try {
      await _ensureTokenLoaded();

      final isSuccess = await _apiService.manageStudentAccessAPI(
        token: _token!,
        studentId: studentId,
        batchId: batchId,
        action: action,
      );

      if (isSuccess) {
        print('Student access updated successfully');
        notifyListeners();
      } else {
        _error = 'Failed to update student access';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error managing student access: $e';
      print('Error managing student access: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> AdminfetchallusersProvider() async {
    try {
      await _ensureTokenLoaded();

      _isLoading = true;
      _error = null;
      _errorMessage = null;
      notifyListeners();

      final fetchedUsers = await _apiService.fetchAdminUsers(_token!);

      // Filter to show only approved users
      _users = fetchedUsers.where((user) => user.approved == true).toList();

      print('Total fetched users: ${fetchedUsers.length}');
      print('Approved users: ${_users.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch users: $e';
      _errorMessage = 'Error fetching users: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  Future<void> assignUserToBatchProvider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    try {
      await _ensureTokenLoaded();

      final isSuccess = await _apiService.AdminassignUserToBatch(
        token: _token!,
        courseId: courseId,
        batchId: batchId,
        userId: userId,
      );

      if (isSuccess) {
        print('User successfully assigned to batch.');
        notifyListeners();
      } else {
        _error = 'Failed to assign user to batch';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error assigning user to batch: $e';
      print('Error assigning user to batch: $e');
      notifyListeners();
    }
  }

  Future<void> Adminfetchleaveprovider() async {
    try {
      await _ensureTokenLoaded();

      _isLoading = true;
      _error = null;
      notifyListeners();

      _leave = await _apiService.AdminfetchgetAllLeaveRequestssAPI(_token!);
      print('Fetched leave requests: ${_leave.length} requests');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch leave requests: $e';
      print('Error fetching leave requests: $e');
      notifyListeners();
    }
  }

  Future<void> adminApproveleaveprovider({
    required int leaveId,
    required String status,
  }) async {
    try {
      await _ensureTokenLoaded();

      final isSuccess = await _apiService.adminApprovependingleave(
        token: _token!,
        leaveId: leaveId,
        status: status,
      );

      if (isSuccess) {
        print('Leave request processed successfully');
        // Refresh leave requests after approval/rejection
        await Adminfetchleaveprovider();
      } else {
        _error = 'Failed to process leave request';
        print('Failed to process leave request');
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error processing leave request: $e';
      print('Error processing leave approval/rejection: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    try {
      _token = await TokenManager.getToken();
      if (_token == null || _token!.isEmpty) {
        _error = 'Failed to refresh token. Please login again.';
      } else {
        _error = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Token refresh failed: $e';
      notifyListeners();
    }
  }

  Future<void> Adminlogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');

      await TokenManager.deleteToken();
      _token = null;

      notifyListeners();
      await _apiService.Adminlogout();
    } catch (error) {
      print('Error during logout: $error');
      rethrow;
    }
  }

  Future<void> fetchStudentTransactions({
    required int studentId,
    String? token,
  }) async {
    if (token != null) _token = token;

    if (_token == null) {
      throw Exception('Token is missing');
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _apiService.fetchTransactions(_token!, studentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future AdminCreateBatchProvider(
    String batchName,
    int courseId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_token == null) {
      throw Exception('Authentication token is missing');
    }

    // Validate required fields
    if (courseId <= 0) {
      throw Exception('Invalid courseId');
    }
    if (batchName.trim().isEmpty) {
      throw Exception('Batch name is required');
    }

    try {
      final result = await _apiService.adminCreateBatch(
        _token!,
        courseId,
        batchName.trim(),
        startDate,
        endDate,
      );

      // Update the local state with the new batch
      final currentBatches = courseBatches[courseId] ?? [];
      courseBatches[courseId] = [...currentBatches, result];
      notifyListeners();
    } catch (e) {
      print('Error in AdminCreateBatchProvider: $e');
      rethrow;
    }
  }

  Future<void> AdminUpdatebatchprovider(
    int courseId,
    int batchId,
    String batchName,
    String medium,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.AdminupdateBatchAPI(
        _token!,
        courseId,
        batchId,
        batchName,
        medium,
        startDate,
        endDate,
      );
      await AdminfetchBatchForCourseProvider(courseId);
    } catch (e) {
      print('Error updating batch: $e');
      throw Exception('Failed to update batch');
    }
  }

  Future<void> AdmindeleteBatchprovider(
    int courseId,
    int batchId,
    String medium,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminBatch(
        courseId,
        _token!,
        batchId,
      );
      print(result); // Optionally print success message

      if (_courseBatches.containsKey(courseId)) {
        _courseBatches[courseId]?.removeWhere(
          (Batche) => Batche.batchId == batchId,
        );
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchBatchForCourseProvider(courseId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<AdminLiveLinkResponse?> AdminfetchLiveAdmin(int batchId) async {
    if (_token == null) {
      print('Error: Token is null. Please authenticate first.');
      return null; // Return null instead of throwing an exception
    }

    try {
      final liveData = await _apiService.AdminfetchLiveAdmin(_token!, batchId);
      _liveBatch[batchId] = liveData!;
      notifyListeners(); // Trigger UI rebuild
      return liveData;
    } catch (error) {
      print('Failed to fetch live data: $error');
      return null; // Return null so UI can handle it gracefully
    }
  }

  Future<void> AdmincreateLivelinkprovider(
    int batchId,
    String liveLink,
    DateTime liveStartTime,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      // Remove courseId reference as it's not needed or defined
      print('Creating LiveLink for batchId: $batchId');

      // Call API to create the live link
      await _apiService.AdminpostLiveLink(
        _token!,
        batchId,
        liveLink,
        liveStartTime,
      );

      print('LiveLink creation successful. Fetching updated live data...');
      // Fetch updated live data after creation
      await AdminfetchLiveAdmin(batchId);
      print('LiveLink created and data refreshed successfully.');
    } catch (e) {
      print('Error creating LiveLink: $e');
      // Modify this condition to not reference courseId
      if (e.toString().contains("Batch not found")) {
        throw Exception('Batch ID $batchId not found. Please verify.');
      } else {
        throw Exception('Failed to create LiveLink: $e');
      }
    }
  }

  Future<void> AdminupdateLive(
    int batchId,
    String liveLink,
    DateTime startTime,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateLIveAPI(
        _token!,
        batchId,
        liveLink,
        startTime,
      );
      await AdminfetchLiveAdmin(
        batchId,
      ); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

  Future<void> AdmindeleteLiveprovider(int courseId, int batchId) async {
    if (_token == null || _token!.isEmpty) {
      throw Exception('Invalid or missing token');
    }
    try {
      // Fix: Change parameter order to match API expectation
      final result = await _apiService.AdmindeleteAdminLive(
        batchId,
        courseId,
        _token!,
      );
      print("Delete result: $result");
      notifyListeners();
    } catch (e) {
      print('Error in provider while deleting: $e');
      rethrow;
    }
  }
}
