import 'dart:convert';

class AdminAllusersmodel {
  final int userId;
  final String? profilePicture;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String role;
  final bool approved;
  final String registrationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminAllusersmodel({
    required this.userId,
    this.profilePicture,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
    required this.approved,
    required this.registrationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminAllusersmodel.fromJson(Map<String, dynamic> json) {
    return AdminAllusersmodel(
      userId: json['userId'] ?? 0,
      profilePicture: json['profilePicture']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      approved: json['approved'] ?? false,
      registrationId: json['registrationId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profilePicture': profilePicture,
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'role': role,
      'approved': approved,
      'registrationId': registrationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

}
class AdminUserResponse {
  final List<User> users;

  AdminUserResponse({required this.users});

  factory AdminUserResponse.fromJson(String source) {
    final Map<String, dynamic> jsonData = json.decode(source);
    final List<dynamic> userList = jsonData['users'];

    return AdminUserResponse(
      users: userList.map((user) => User.fromJson(user)).toList(),
    );
  }

  String toJson() {
    return json.encode({'users': users.map((user) => user.toJson()).toList()});
  }
}
class User {
  final int userId;
  final String? registrationId;
  final String name;
  final String email;
  final String role;
  final List<Course> courses;

  User({
    required this.userId,
    this.registrationId,
    required this.name,
    required this.email,
    required this.role,
    required this.courses,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      registrationId: json['registrationId'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      courses:
          (json['courses'] as List)
              .map((course) => Course.fromJson(course))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'registrationId': registrationId,
      'name': name,
      'email': email,
      'role': role,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }
}

class Course {
  final int batchId;
  final String? batchName;
  final int courseId;
  final String courseName;
  final Assignments? assignments;
  final Quizzes? quizzes;

  Course({
    required this.batchId,
    this.batchName,
    required this.courseId,
    required this.courseName,
    this.assignments,
    this.quizzes,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      batchId: json['batchId'],
      batchName: json['batchName'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      assignments:
          json.containsKey('assignments')
              ? Assignments.fromJson(json['assignments'])
              : null,
      quizzes:
          json.containsKey('quizzes')
              ? Quizzes.fromJson(json['quizzes'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'batchName': batchName,
      'courseId': courseId,
      'courseName': courseName,
      if (assignments != null) 'assignments': assignments!.toJson(),
      if (quizzes != null) 'quizzes': quizzes!.toJson(),
    };
  }
}

class Assignments {
  final int totalAssignments;
  final int submittedAssignments;
  final int pendingAssignments;

  Assignments({
    required this.totalAssignments,
    required this.submittedAssignments,
    required this.pendingAssignments,
  });

  factory Assignments.fromJson(Map<String, dynamic> json) {
    return Assignments(
      totalAssignments: json['totalAssignments'],
      submittedAssignments: json['submittedAssignments'],
      pendingAssignments: json['pendingAssignments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAssignments': totalAssignments,
      'submittedAssignments': submittedAssignments,
      'pendingAssignments': pendingAssignments,
    };
  }
}

class Quizzes {
  final int totalQuizzes;
  final int submittedQuizzes;
  final int pendingQuizzes;

  Quizzes({
    required this.totalQuizzes,
    required this.submittedQuizzes,
    required this.pendingQuizzes,
  });

  factory Quizzes.fromJson(Map<String, dynamic> json) {
    return Quizzes(
      totalQuizzes: json['totalQuizzes'],
      submittedQuizzes: json['submittedQuizzes'],
      pendingQuizzes: json['pendingQuizzes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuizzes': totalQuizzes,
      'submittedQuizzes': submittedQuizzes,
      'pendingQuizzes': pendingQuizzes,
    };
  }
}

class AttendanceHistory {
  final int id;
  final int studentId;
  final int batchId;
  final String date;
  final String status;
  final String createdAt;
  final String updatedAt;
  final dynamic studentBatch;

  AttendanceHistory({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.studentBatch,
  });

  factory AttendanceHistory.fromJson(String source) =>
      AttendanceHistory.fromMap(json.decode(source));

  factory AttendanceHistory.fromMap(Map<String, dynamic> map) {
    return AttendanceHistory(
      id: map['id'],
      studentId: map['studentId'],
      batchId: map['batchId'],
      date: map['date'],
      status: map['status'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      studentBatch: map['StudentBatch'],
    );
  }
}