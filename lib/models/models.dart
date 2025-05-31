class CourseModel {
  int? courseId;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? updatedAt;
  CourseModel(
    this.courseId,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  );
  CourseModel.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId'];
    title = json['title'];
    description = json['description'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class ModuleModel {
  int? moduleId;
  String? title;
  String? content;

  ModuleModel({this.moduleId, this.title, this.content});
  ModuleModel.fromJson(Map<String, dynamic> json) {
    moduleId = json['moduleId'];
    title = json['title'];
    content = json['content'];
  }
}

class LessonModel {
  int? lessonId;
  String? title;
  String? content;
  String? videoLink;
  String? pdfPath;
  String? status;
  String? courseId;
  String? moduleId;
  LessonModel({
    this.lessonId,
    this.title,
    this.content,
    this.videoLink,
    this.pdfPath,
    this.status,
    this.courseId,
    this.moduleId,
  });
  LessonModel.fromJson(Map<String, dynamic> json) {
    lessonId = json['lessonId'];
    title = json['title'];
    content = json['content'];
    videoLink = json['videoLink'];
    pdfPath = json['pdfPath'];
    status = json['status'];
    courseId = json['courseId'];
    moduleId = json['moduleId'];
  }
}

class AssignmentModel {
  final int assignmentId;
  final int courseId;
  final int moduleId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? submissionLink;
  final String status;

  AssignmentModel({
    required this.assignmentId,
    required this.courseId,
    required this.moduleId,
    required this.title,
    required this.description,
    this.dueDate,
    this.submissionLink,
    required this.status,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      assignmentId: json['assignmentId'],
      courseId: json['courseId'],
      moduleId: json['moduleId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      submissionLink: json['submissionLink']?.toString(),
      status: json['status'] ?? '',
    );
  }
}


class AssignmentSubmission {
  final int submissionId;
  final int assignmentId;
  final int studentId;
  final String status;
  final String content;
  final DateTime submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String studentName;
  final String studentEmail;
  final String submissionLink;

  AssignmentSubmission({
    required this.submissionId,
    required this.assignmentId,
    required this.studentId,
    required this.status,
    required this.content,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.studentName,
    required this.studentEmail,
    required this.submissionLink
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      submissionId: json['submissionId'] ?? 0,
      assignmentId: json['assignmentId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      status: json['status'] ?? '',
      content: json['content'] ?? '',
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      studentName: json['Student']?['name'] ?? 'Unknown',
      studentEmail: json['Student']?['email'] ?? 'No email',
      submissionLink:json['submissionLink']?? 0
    );
  }
}