import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pb_lms/models/fahad/model.dart';
import 'package:pb_lms/models/models.dart';

class AdminAPI {
  final String baseUrl = 'https://api.portfoliobuilders.in/api';

  Future<List<Admincoursemodel>> AdminfetchCoursesAPI(String token) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllCourses');
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
        final List<dynamic> courses = jsonDecode(response.body)['courses'];
        return courses.map((item) => Admincoursemodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch courses: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<AdminCourseBatch>> AdminfetctBatchForCourseAPI(
    String token,
    int courseId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getBatchesByCourseId/$courseId');
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

        if (!responseData.containsKey('batches')) {
          print('Response does not contain batches key: $responseData');
          throw Exception('Invalid response format: missing batches key');
        }

        final List<dynamic> batches = responseData['batches'];

        return batches.map((item) {
          try {
            return AdminCourseBatch.fromJson(item);
          } catch (e) {
            print('Error parsing batch item: $item');
            print('Error details: $e');
            rethrow;
          }
        }).toList();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to fetch batches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in AdminfetctBatchForCourseAPI: $e');
      rethrow;
    }
  }

  Future<BatchStudentModel> AdminfetchUsersBatchAPI(
    String token,
    int courseId,
    int batchId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/getStudentsByBatchId/$courseId/$batchId',
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
        final Map<String, dynamic> data = jsonDecode(response.body);
        return BatchStudentModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> AdmindeleteUserFromBatch({
    required String token,
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/removeStudentFromBatch/$courseId/$batchId/$userId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId,
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Indicates success
      } else {
        throw Exception('Failed to delete user to batch: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> manageStudentAccessAPI({
    required String token,
    required int studentId,
    required int batchId,
    required String action,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/manageStudentAccess');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'batchId': batchId,
          'action': action,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Student access updated successfully: ${response.body}');
        return true;
      } else {
        print('Failed to update student access: ${response.body}');
        throw Exception(
          'Failed to update student access: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error in manageStudentAccessAPI: $e');
      throw Exception('Failed to update student access: $e');
    }
  }

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

        // Parse all users first
        final List<AdminAllusersmodel> allUsers =
            users.map((user) => AdminAllusersmodel.fromJson(user)).toList();

        // Filter to return only approved users
        final List<AdminAllusersmodel> approvedUsers =
            allUsers.where((user) => user.approved == true).toList();

        print('Total users: ${allUsers.length}');
        print('Approved users: ${approvedUsers.length}');

        return approvedUsers;
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<bool> AdminassignUserToBatch({
    required String token,
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/assignStudentToBatch');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId,
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Indicates success
      } else {
        throw Exception('Failed to assign user to batch: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<LeaveRequest>> AdminfetchgetAllLeaveRequestssAPI(
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllLeaveRequests');
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
        final List<dynamic> leave = jsonDecode(response.body)['leaveRequests'];
        return leave.map((item) => LeaveRequest.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch LeaveRequest: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> adminApprovependingleave({
    required String token,
    required int leaveId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/updateLeaveStatus/$leaveId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status, // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to update leaveId: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<http.Response> Adminlogout() async {
    final url = Uri.parse("$baseUrl/logoutUser");
    return await http.post(url, headers: {'Content-Type': 'application/json'});
  }

  Future<List<Transaction>> fetchTransactions(
    String token,
    int studentId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getTransactions/$studentId');
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

        if (responseBody['transactions'] is List) {
          final List<dynamic> transactions = responseBody['transactions'];
          return transactions
              .map((item) => Transaction.fromJson(item))
              .whereType<Transaction>()
              .toList();
        } else {
          print('No transactions found or invalid format');
          return [];
        }
      } else {
        print('Failed to fetch transactions: ${response.body}');
        throw Exception('Failed to fetch transactions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  Future adminCreateBatch(
    String token,
    int courseId,
    String batchName,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/createBatch');
    final requestBody = {
      'courseId': courseId,
      'name': batchName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AdminCourseBatch.fromJson(jsonDecode(response.body));
      } else {
        Map errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create batch');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      }
      rethrow;
    }
  }

  Future<String> AdminupdateBatchAPI(
    String token,
    int courseId,
    int batchId,
    String batchName,
    String medium,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/updateBatch');

    final payload = jsonEncode({
      'courseId': courseId,
      'batchId': batchId,
      'name': batchName,
      'medium': medium,
      'startDate': startTime.toIso8601String(),
      'endDate': endTime.toIso8601String(),
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
        throw Exception('Failed to update batch: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating batch: $e');
      rethrow;
    }
  }

  Future<String> deleteAdminBatch(
    int courseId,
    String token,
    int batchId,
  ) async {
    final url = Uri.parse("$baseUrl/superadmin/deleteBatch/$batchId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Module deleted successfully";
      } else {
        throw Exception(
          "Failed to delete Module. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting Module: $e");
    }
  }

  Future<AdminLiveLinkResponse?> AdminfetchLiveAdmin(
    String token,
    int batchId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getLiveLinkBatch/$batchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched live data: $data');
        if (data == null || data.isEmpty) {
          return null;
        }
        return AdminLiveLinkResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching live data: $e');
      return null;
    }
  }

  Future<String> AdminpostLiveLink(
    String token,
    int batchId,
    String liveLink,
    DateTime? liveStartTime,
  ) async {
    if (liveStartTime == null) {
      throw Exception('Live start time cannot be null');
    }

    final url = Uri.parse('$baseUrl/superadmin/postLiveLink/$batchId');

    // Ensure the date-time is in IST (local time in India)
    DateTime istDateTime = liveStartTime.toLocal();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'liveLink': liveLink,
        'liveStartTime': DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        ).format(istDateTime), // Correct format
      }),
    );

    print('IST Time Sent: $istDateTime');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Live link posted successfully: ${response.body}');
      return response.body;
    } else {
      print('Failed to create Live link: ${response.body}');
      throw Exception('Failed to create Live link: ${response.body}');
    }
  }

  Future<String> AdminupdateLIveAPI(
    String token,
    int batchId,
    String liveLink,
    DateTime startTime,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/updateLiveLink/$batchId');

    // Convert DateTime to ISO 8601 string format
    final payload = jsonEncode({
      'batchId': batchId,
      'liveLink': liveLink,
      'startTime': startTime.toIso8601String(), // Convert DateTime to string
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
          'Failed to update live session: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error updating live session: $e');
      rethrow;
    }
  }

  Future<String> AdmindeleteAdminLive(
    int batchId,
    int courseId,
    String token,
  ) async {
    final url = Uri.parse(
      "$baseUrl/superadmin/deleteLiveLink/$batchId/$courseId",
    );
    print("Delete URL: $url");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Live deleted successfully";
      } else {
        throw Exception(
          "Failed to delete live course. Status Code: ${response.statusCode}. Response: ${response.body}",
        );
      }
    } catch (e) {
      print("Exception details: $e");
      throw Exception("Error deleting Live: $e");
    }
  }
}
