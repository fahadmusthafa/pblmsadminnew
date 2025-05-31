import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pb_lms/models/user_managemet_model/UserManagerModel.dart';

class userApiService {
  final String baseUrl = 'https://api.portfoliobuilders.in/api';

  Future<List<AdminAllusersmodel>> fetchAdminUsers(String token) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllUsers');

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
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (!responseBody.containsKey('users') ||
            responseBody['users'] == null) {
          throw Exception('Invalid response format: Missing "users" key');
        }

        final List<dynamic> users = responseBody['users'];

        return users.map((user) => AdminAllusersmodel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<bool> adminApproveUser({
    required String token,
    required int userId,
    required String role,
    required String action,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/manageUserApproval');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'role': role,
          'action': action.toLowerCase(), // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to process user: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<AttendanceHistory>> fetchAttendanceHistory(
    int studentId,
    String token,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/getStudentAttendanceHistory/$studentId',
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Extract the attendance history array from the response
        final List<dynamic> historyList = responseData['attendanceHistory'];
        print('Attendance History array: $historyList'); // Debug print

        return historyList
            .map((item) => AttendanceHistory.fromMap(item))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load attendance history: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> updateStudentAttendance(
    String token,
    int attendanceId,
    String status,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/editStudentAttendance');

    // Prepare the request payload
    final payload = jsonEncode({
      'attendanceId': attendanceId,
      'status': status,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception(
          'Failed to update attendance: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }
}
