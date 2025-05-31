class Admincoursemodel {
  final int courseId;
  final String name;
  final String description;

  Admincoursemodel({
    required this.courseId,
    required this.name,
    required this.description,
  });

  factory Admincoursemodel.fromJson(Map<String, dynamic> json) {
    return Admincoursemodel(
      courseId: json['courseId'],
      name:
          json['title'], // Changed from 'name' to 'title' to match API response
      description: json['description'],
    );
  }
}

class AdminCourseBatch {
  final int batchId;
  final String batchName;
  final String? medium; // Made nullable
  final DateTime? startTime; // Made nullable
  final DateTime? endTime; // Made nullable

  AdminCourseBatch({
    required this.batchId,
    required this.batchName,
    this.medium,
    this.startTime,
    this.endTime,
  });

  factory AdminCourseBatch.fromJson(Map<String, dynamic> json) {
    return AdminCourseBatch(
      batchId: json['batchId'] ?? 0,
      batchName: json['batchName'] ?? '',
      medium: json['medium'], // Allow null
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'batchName': batchName,
      'medium': medium,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}

class BatchStudentModel {
  final String message;
  final int courseId;
  final String courseName;
  final int batchId;
  final String batchName;
  final List<Student> students;

  BatchStudentModel({
    required this.message,
    required this.courseId,
    required this.courseName,
    required this.batchId,
    required this.batchName,
    required this.students,
  });

  factory BatchStudentModel.fromJson(Map<String, dynamic> json) {
    return BatchStudentModel(
      message: json['message'] as String,
      courseId: json['courseId'] as int,
      courseName: json['courseName'] as String,
      batchId: json['batchId'] as int,
      batchName: json['batchName'] as String,
      students:
          (json['students'] as List<dynamic>)
              .map(
                (student) => Student.fromJson(student as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

class Student {
  final int studentId;
  final String name;
  final String email;
  final String status;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
      'status': status,
    };
  }
}

class AdminAllusersmodel {
  final int userId;
  final String? profilePicture; // Made nullable - API returns this field
  final String name;
  final String email;
  final String password;
  final String? phoneNumber; // Made nullable - API can return null
  final String role;
  final bool approved;
  final String registrationId;
  final String? resetOtp; // Added - API returns this field (null)
  final String? otpExpires; // Added - API returns this field (null)
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminAllusersmodel({
    required this.userId,
    this.profilePicture, // Made nullable
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber, // Made nullable
    required this.role,
    required this.approved,
    required this.registrationId,
    this.resetOtp, // Made nullable
    this.otpExpires, // Made nullable
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminAllusersmodel.fromJson(Map<String, dynamic> json) {
    try {
      return AdminAllusersmodel(
        userId: json['userId'] as int,
        profilePicture: json['profilePicture'] as String?, // Handle null
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        phoneNumber: json['phoneNumber'] as String?, // Handle null
        role: json['role'] as String,
        approved: json['approved'] as bool,
        registrationId: json['registrationId'] as String,
        resetOtp: json['resetOtp'] as String?, // Handle null - THIS FIELD WAS MISSING
        otpExpires: json['otpExpires'] as String?, // Handle null - THIS FIELD WAS MISSING
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing AdminAllusersmodel from JSON: $json');
      print('Parsing error: $e');
      rethrow;
    }
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
      'resetOtp': resetOtp, // Added
      'otpExpires': otpExpires, // Added
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class LeaveRequest {
  int leaveId;
  int studentId;
  DateTime leaveDate;
  String reason;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  Students student; // Ensure this matches the class name

  LeaveRequest({
    required this.leaveId,
    required this.studentId,
    required this.leaveDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.student,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
    leaveId: json["id"],
    studentId: json["studentId"],
    leaveDate: DateTime.parse(json["leaveDate"]),
    reason: json["reason"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    student: Students.fromJson(json["student"]), // Fix class name
  );

  Map<String, dynamic> toJson() => {
    "id": leaveId,
    "studentId": studentId,
    "leaveDate":
        "${leaveDate.year.toString().padLeft(4, '0')}-${leaveDate.month.toString().padLeft(2, '0')}-${leaveDate.day.toString().padLeft(2, '0')}",
    "reason": reason,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "student": student.toJson(),
  };
}

class Students {
  int id;
  String name;
  String email;
  String? registrationId; // Changed from int? to String?

  Students({
    required this.id,
    required this.name,
    required this.email,
    this.registrationId,
  });

  factory Students.fromJson(Map<String, dynamic> json) => Students(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    registrationId:
        json["registrationId"]?.toString(), // Convert to String or keep as null
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "registrationId": registrationId,
  };
}

class Transaction {
  final int id;
  final int studentId;
  final String transactionId;
  final double amountPaid;
  final DateTime paymentDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.studentId,
    required this.transactionId,
    required this.amountPaid,
    required this.paymentDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      transactionId: json['transactionId'] ?? '',
      amountPaid: _parseDouble(json['amountPaid']),
      paymentDate: _parseDateTime(json['paymentDate']),
      status: json['status'] ?? 'unknown',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return value is DateTime ? value : DateTime.parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'transactionId': transactionId,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AdminLiveLinkResponse {
  final String message;
  final String liveLink;
  final DateTime liveStartTime;

  AdminLiveLinkResponse({
    required this.message,
    required this.liveLink,
    required this.liveStartTime,
  });

  factory AdminLiveLinkResponse.fromJson(Map<String, dynamic> json) {
    return AdminLiveLinkResponse(
      message: json['message'] as String,
      liveLink: json['liveLink'] as String,
      liveStartTime: DateTime.parse(json['liveStartTime'] as String),
    );
  }
}