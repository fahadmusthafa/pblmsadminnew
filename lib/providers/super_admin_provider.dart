import 'package:flutter/widgets.dart';
import 'package:pb_lms/models/models.dart';
import 'package:pb_lms/services/super_admin_service.dart';
import 'package:pb_lms/utilities/token_manager.dart';

class SuperAdminProvider with ChangeNotifier {
  final SuperAdminService _superService = SuperAdminService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<CourseModel> _courses = [];
  List<CourseModel> get courses => _courses;
  List<ModuleModel> _modules = [];
  List<ModuleModel> get modules => _modules;
  List<LessonModel> _lessons = [];
  List<LessonModel> get lessons => _lessons;
  List<AssignmentModel> _assignments = [];
  List<AssignmentModel> get assignments => _assignments;
  Map<int, List<AssignmentSubmission>> _submissions = {};
  Map<int, List<AssignmentSubmission>> get submissions => _submissions;
  List<AssignmentSubmission> getSubmissionsByAssignmentId(int assignmentId) {
    return _submissions[assignmentId] ?? [];
  }

  Future<Map<String, dynamic>> loginProvider(
    String? email,
    String? password,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _superService.loginService(email, password);
      print('Token: $response');
      final auth_token = response['token'];
      if (response['token'] != null) {
        await TokenManager.saveToken(auth_token);
        return {'message': response['message'], 'status': true};
      } else {
        return {'message': response['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error Logging in: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCourses() async {
    _courses = [];
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _superService.getCourseService();
      if (response['status']) {
        _courses = response['courses'];
        return {'message': response['message'], 'courses': response['courses']};
      } else {
        return {'message': response['status']};
      }
    } catch (e) {
      throw Exception('Error fetching courses in provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createCourse(
    String? title,
    String? description,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.createCourseService(
        title,
        description,
        token,
      );
      if (res['status']) {
        await fetchCourses();
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in course provider: $e');
      throw Exception('Error in course creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateCourse(
    int? courseId,
    String? title,
    String? description,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.updateCourseService(
        courseId,
        title,
        description,
        token,
      );
      if (res['status']) {
        await fetchCourses();
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in course provider: $e');
      throw Exception('Error in course creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> deleteCourse(
    int? courseId,
    String? title,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = await TokenManager.getToken();
      final response = await _superService.deleteCourseService(courseId, token);
      if (response) {
        await fetchCourses();
        return {'status': response, 'message': 'Deleted Course $title'};
      } else {
        return {'status': response, 'message': 'Error deleting course $title'};
      }
    } catch (e) {
      throw Exception('Error in deleting provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCourseModule(int? courseId) async {
    _modules = [];
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _superService.getModuleService(courseId);
      if (response['status']) {
        _modules = response['data'];
        return {'modules': response['data']};
      } else {
        return {'message': response['data']};
      }
    } catch (e) {
      throw Exception('Error fetching modules:$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createModule(
    int? courseId,
    String? title,
    String? description,
  ) async {
    _isLoading = true;
    notifyListeners();
    print(courseId);
    print(title);
    print(description);
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.createModuleService(
        courseId,
        title,
        description,
        token,
      );
      if (res['status']) {
        await fetchCourseModule(courseId);
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in module provider: $e');
      throw Exception('Error in module creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateModule(
    int? courseId,
    int? moduleId,
    String? title,
    String? description,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.updateModuleService(
        courseId,
        moduleId,
        title,
        description,
        token,
      );
      if (res['status']) {
        await fetchCourseModule(courseId);
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in course provider: $e');
      throw Exception('Error in course creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> deleteModule(
    int? courseId,
    int? moduleId,
    String? title,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = await TokenManager.getToken();
      final response = await _superService.deleteModuleService(
        courseId,
        moduleId,
        token,
      );
      if (response) {
        await fetchCourseModule(courseId);
        return {'status': response, 'message': 'Deleted Course $title'};
      } else {
        return {'status': response, 'message': 'Error deleting course $title'};
      }
    } catch (e) {
      throw Exception('Error in deleting provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getLessons(int? moduleId, int? courseId) async {
    _lessons = [];
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _superService.getLessonService(courseId, moduleId);
      if (response['status']) {
        _lessons = response['lessons'];
        return {'message': response['message'], 'data': response['lessons']};
      } else {
        return {'message': response['message']};
      }
    } catch (e) {
      throw Exception('Error in Lessons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createLessons(
    int? courseId,
    int? moduleId,
    String? title,
    String? content,
    String? videoLink,
    String? pdfFile,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.createLessonsService(
        courseId,
        moduleId,
        title,
        content,
        videoLink,
        pdfFile,
        token,
      );
      if (res['status']) {
        await getLessons(moduleId, courseId);
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in module provider: $e');
      throw Exception('Error in module creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateLessons(
    int? courseId,
    int? moduleId,
    int? lessonId,
    String? title,
    String? description,
    String? videoLink,
    String? pdfUrl,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.updateLessonsService(
        courseId,
        moduleId,
        lessonId,
        title,
        description,
        videoLink,
        pdfUrl,
        token,
      );
      if (res['status']) {
        await getLessons(moduleId, courseId);
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in course provider: $e');
      throw Exception('Error in course creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> deleteLessons(
    int? courseId,
    int? moduleId,
    int? lessonId,
    String? title,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = await TokenManager.getToken();
      final response = await _superService.deleteLessonsService(
        lessonId,
        token,
      );
      if (response) {
        await getLessons(moduleId, courseId);
        return {'status': response, 'message': 'Deleted Course $title'};
      } else {
        return {'status': response, 'message': 'Error deleting course $title'};
      }
    } catch (e) {
      throw Exception('Error in deleting provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getAssignments(
    int? moduleId,
    int? courseId,
  ) async {
    _assignments = [];
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _superService.getAssignmentService(
        courseId,
        moduleId,
      );
      if (response['status']) {
        _assignments = response['assignments'];
        return {'message': response['message']};
      } else {
        return {'message': response['message']};
      }
    } catch (e) {
      throw Exception('Error in Assignments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createAssignment(
    int? courseId,
    int? moduleId,
    String? title,
    String? description,
    String? dueDate,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.createAssignmentService(
        courseId,
        moduleId,
        title,
        description,
        dueDate,
        token,
      );
      if (res['status']) {
        await getAssignments(moduleId, courseId);
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in module provider: $e');
      throw Exception('Error in module creation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateAssignments(
    int? courseId,
    int? moduleId,
    int? assignmentId,
    String? title,
    String? description,
    String? dueDate,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenManager.getToken();
      final res = await _superService.updateAssignmentService(
        courseId,
        moduleId,
        assignmentId,
        title,
        description,
        dueDate,
        token,
      );
      if (res['status']) {
        await getAssignments(moduleId, courseId);
        return {'message': res['message'], 'status': res['status']};
      } else {
        return {'message': res['message'], 'status': res['status']};
      }
    } catch (e) {
      print('Error in assignment provider: $e');
      throw Exception('Error in assignment update: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> deleteAssignments(
    int? courseId,
    int? moduleId,
    int? assignmentId,
    String? title,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = await TokenManager.getToken();
      final response = await _superService.deleteAssignmentService(
        courseId,
        moduleId,
        assignmentId,
        token,
      );
      if (response) {
        await getAssignments(moduleId, courseId);
        return {'status': response, 'message': 'Deleted Assignment $title'};
      } else {
        return {
          'status': response,
          'message': 'Error deleting assignment $title',
        };
      }
    } catch (e) {
      throw Exception('Error in deleting provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubmissions(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await TokenManager.getToken();
      final submissions = await _superService.fetchAssignmentSubmissions(
        assignmentId,
        token!,
      );
      _submissions[assignmentId] = submissions;
    } catch (e) {
      print('Error fetching submissions: $e');
      _submissions[assignmentId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
