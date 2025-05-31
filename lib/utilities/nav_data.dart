import 'package:pb_lms/views/dashboard_screen.dart';
import 'package:pb_lms/views/course_management/courses_screen.dart';
import 'package:pb_lms/views/batch_management/batch_screen.dart';
import 'package:pb_lms/views/live_management/live_screen.dart';
import 'package:pb_lms/views/student_management/students_screen.dart';
import 'package:pb_lms/views/user_management/user_mg_screen.dart';
import 'package:pb_lms/views/grievence_management.dart/grievance_screen.dart';

class NavData {
  final int index;
  final String image;
  final String label;
  const NavData({
    required this.index,
    required this.image,
    required this.label,
  });
}

final List<NavData> navData = [
  NavData(index: 0, image: 'assets/icons/dashboard.png', label: 'Dashboard'),
  NavData(
    index: 1,
    image: 'assets/icons/course_mg.png',
    label: 'Course Management',
  ),
  NavData(
    index: 2,
    image: 'assets/icons/batch_mg.png',
    label: 'Batch Management',
  ),
  NavData(
    index: 3,
    image: 'assets/icons/live_mg.png',
    label: 'Live Management',
  ),
  NavData(
    index: 4,
    image: 'assets/icons/students_mg.png',
    label: 'Students Management',
  ),
  NavData(
    index: 5,
    image: 'assets/icons/user_mg.png',
    label: 'User Management',
  ),
  NavData(
    index: 6,
    image: 'assets/icons/grievance_mg.png',
    label: 'Grievance Management',
  ),
];

final List pages = [
  DashboardScreen(),
  CoursesScreen(),
  BatchScreen(),
  LiveScreen(),
  StudentsManagementScreen(),
  UserMgScreen(),
  GrievanceScreen(),
];

