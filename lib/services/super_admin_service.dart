import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pb_lms/models/models.dart';
import 'package:pb_lms/utilities/token_manager.dart';

class SuperAdminService {
  final baseUrl = 'https://api.portfoliobuilders.in/api/superadmin';

  Future<Map<String, dynamic>> loginService(
    String? email,
    String? password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'],
          'token': responseData['token'],
        };
      } else {
        return {'message': responseData['message'], 'token': null};
      }
    } catch (e) {
      throw Exception('Error Logging In: $e');
    }
  }

  Future<Map<String, dynamic>> getCourseService() async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/getAllCourses'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> body = responseData['courses'];
        List<CourseModel> courses =
            body.map((dynamic item) => CourseModel.fromJson(item)).toList();
        return {
          'message': responseData['message'],
          'courses': courses,
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error fetching courses in service: $e');
    }
  }

  Future<Map<String, dynamic>> createCourseService(
    String? title,
    String? description,
    String? token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createCourse'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title, 'description': description}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'] ?? 'Course created successfully',
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      print('Error in service: $e');
      throw Exception('Error creating course: $e');
    }
  }

  Future<Map<String, dynamic>> updateCourseService(
    int? courseId,
    String? title,
    String? description,
    String? token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateCourse/$courseId'),
        body: jsonEncode({'title': title, 'description': description}),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'],
          'data': responseData['course'],
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error in service update course: $e');
    }
  }

  Future<bool> deleteCourseService(int? courseId, String? token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteCourse/$courseId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error in deleting service course: $e');
    }
  }

  Future<Map<String, dynamic>> getModuleService(int? courseId) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/getmodules/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> body = responseData['modules'];
        List<ModuleModel> module =
            body.map((dynamic item) => ModuleModel.fromJson(item)).toList();
        return {'data': module, 'status': true};
      } else {
        return {'data': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<Map<String, dynamic>> createModuleService(
    int? courseId,
    String? title,
    String? description,
    String? token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createModule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'title': title,
          'content': description,
        }),
      );
      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'] ?? 'Module created successfully',
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      print('Error in service: $e');
      throw Exception('Error creating course: $e');
    }
  }

  Future<Map<String, dynamic>> updateModuleService(
    int? courseId,
    int? moduleId,
    String? title,
    String? description,
    String? token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateModule'),
        body: jsonEncode({
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'content': description,
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'],
          'data': responseData['course'],
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error in service update course: $e');
    }
  }

  Future<bool> deleteModuleService(
    int? courseId,
    int? moduleId,
    String? token,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteModule/$courseId/$moduleId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error in deleting service module: $e');
    }
  }

  Future<Map<String, dynamic>> getLessonService(
    int? courseId,
    int? moduleId,
  ) async {
    final token = await TokenManager.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getLesson/$courseId/$moduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> body = responseData['lessons'];
        List<LessonModel> lessons =
            body.map((dynamic item) => LessonModel.fromJson(item)).toList();
        return {
          'lessons': lessons,
          'message': responseData['message'],
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  Future<Map<String, dynamic>> createLessonsService(
    int? courseId,
    int? moduleId,
    String? title,
    String? content,
    String? videoLink,
    String? pdfFile,
    String? token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createLesson'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'content': content,
          'videoLink': videoLink,
          'pdfUrl': pdfFile,
        }),
      );
      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'message': 'Lesson created successfully', 'status': true};
      } else {
        return {'message': 'Error creating Lesson', 'status': false};
      }
    } catch (e) {
      print('Error in service: $e');
      throw Exception('Error creating course: $e');
    }
  }

  Future<Map<String, dynamic>> updateLessonsService(
    int? courseId,
    int? moduleId,
    int? lessonId,
    String? title,
    String? description,
    String? videoLink,
    String? pdfUrl,
    String? token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateLesson'),
        body: jsonEncode({
          'lessonId': lessonId,
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'content': description,
          'videoLink': videoLink,
          'pdfUrl': pdfUrl,
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'],
          'data': responseData['course'],
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error in service update lessons: $e');
    }
  }

  Future<bool> deleteLessonsService(int? lessonId, String? token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteLesson/$lessonId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error in deleting service module: $e');
    }
  }

  Future<Map<String, dynamic>> getAssignmentService(
    int? courseId,
    int? moduleId,
  ) async {
    final token = await TokenManager.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/viewAssignments/$courseId/$moduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> body = responseData['assignments'];
        List<AssignmentModel> assignments =
            body.map((dynamic item) => AssignmentModel.fromJson(item)).toList();
        return {
          'assignments': assignments,
          'message': responseData['message'],
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error fetching assignments: $e');
    }
  }

  Future<Map<String, dynamic>> createAssignmentService(
    int? courseId,
    int? moduleId,
    String? title,
    String? description,
    String? dueDate,
    String? token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createAssignment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'description': description,
          'dueDate': dueDate,
        }),
      );
      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'message': 'Assignment created successfully', 'status': true};
      } else {
        return {'message': 'Error creating assignment', 'status': false};
      }
    } catch (e) {
      print('Error in assignment service: $e');
      throw Exception('Error creating assignment: $e');
    }
  }

  Future<Map<String, dynamic>> updateAssignmentService(
    int? courseId,
    int? moduleId,
    int? assignmentId,
    String? title,
    String? description,
    String? dueDate,
    String? token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateAssignment/$assignmentId'),
        body: jsonEncode({
          'assignmentId': assignmentId,
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'description': description,
          'dueDate':dueDate
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'message': responseData['message'],
          'data': responseData['course'],
          'status': true,
        };
      } else {
        return {'message': responseData['message'], 'status': false};
      }
    } catch (e) {
      throw Exception('Error in service update course: $e');
    }
  }

  Future<bool> deleteAssignmentService(
    int? courseId,
    int? moduleId,
    int? assignmentId,
    String? token,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteAssignment/$assignmentId/$courseId/$moduleId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error in deleting service module: $e');
    }
  }

  Future<List<AssignmentSubmission>> fetchAssignmentSubmissions(
    int assignmentId,
    String token,
  ) async {
    final url = Uri.parse(
      '$baseUrl/getSubmittedAssignments/$assignmentId',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Extract the submissions array from the response
        final List<dynamic> submissions = responseData['submissions'];
        print('Submissions array: $submissions'); // Debug print
        return submissions.map((item) => AssignmentSubmission.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load submissions: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

}