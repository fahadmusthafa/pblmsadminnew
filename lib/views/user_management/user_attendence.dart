import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/models/user_managemet_model/UserManagerModel.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/user_manager_provider/getall_user_provider.dart';
import 'package:pb_lms/utilities/constants.dart';

import 'package:provider/provider.dart';

class UserAttendence extends StatefulWidget {
  const UserAttendence({super.key});

  @override
  State<UserAttendence> createState() => _UserAttendenceState();
}

class _UserAttendenceState extends State<UserAttendence> {
  // Sample attendance data - replace with actual API data
  List<AttendanceHistory> attendanceList = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final attendanceProvider = Provider.of<AdminProvider>(
        context,
        listen: false,
      );
      final navProvider = Provider.of<NavigationProvider>(
        context,
        listen: false,
      );

      await attendanceProvider.fetchAttendanceHistoryProvider(
        navProvider.selectedUserId!,
      );

      setState(() {
        attendanceList =
            attendanceProvider.attendanceHistory; // update from provider
      });
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showStatusDropdown(AttendanceHistory attendance, Offset tapPosition) {
    final List<String> statusOptions = ['Present', 'Absent'];
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: statusOptions.map((String status) {
        return PopupMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Icon(
                status.toLowerCase() == 'present' 
                    ? Icons.check_circle 
                    : Icons.cancel,
                size: 16,
                color: status.toLowerCase() == 'present' 
                    ? Colors.green 
                    : Colors.red,
              ),
              SizedBox(width: 8),
              Text(status),
            ],
          ),
        );
      }).toList(),
    ).then((String? selectedStatus) {
      if (selectedStatus != null && selectedStatus.toLowerCase() != attendance.status.toLowerCase()) {
        _showConfirmationDialog(attendance, selectedStatus);
      }
    });
  }

  void _showConfirmationDialog(AttendanceHistory attendance, String newStatus) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Confirm Status Update',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
          ),
          content: Container(
            width: screenWidth < 600 ? double.maxFinite : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to change the attendance status from "${attendance.status}" to "$newStatus"?',
                  style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Flexible(child: Text(attendance.date)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                await _updateAttendanceStatus(attendance, newStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirm Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAttendanceStatus(AttendanceHistory attendance, String newStatus) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      
      // Call the API to update attendance
      await adminProvider.updateStudentAttendance(
        attendanceId: attendance.id,
        status: newStatus.toLowerCase(),
      );

      // Update local list immediately
      setState(() {
        final index = attendanceList.indexWhere((att) => att.id == attendance.id);
        if (index != -1) {
          attendanceList[index] = AttendanceHistory(
            id: attendance.id,
            studentId: attendance.studentId,
            batchId: attendance.batchId,
            date: attendance.date,
            status: newStatus,
            createdAt: attendance.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
            studentBatch: attendance.studentBatch,
          );
        }
      });

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      _showSuccessSnackBar('Attendance updated successfully');
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      _showErrorSnackBar('Failed to update attendance: ${e.toString()}');
      
      print('Error updating attendance: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: isMobile ? 16 : 20,
          top: isMobile ? 40 : 55,
          right: isMobile ? 16 : 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 235, 235, 235),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb - Responsive
              if (!isMobile) ...[
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        navProvider.navigateBackToUserMg();
                      },
                      child: Text(
                        'User management',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Attendance',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 12 : 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Back button for mobile
              if (isMobile) ...[
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        navProvider.navigateBackToUserMg();
                      },
                      icon: Icon(CupertinoIcons.back, color: Colors.grey[600]),
                    ),
                    Text(
                      'Back to User Management',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Main Title - Responsive
              Text(
                'User management',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 32 : (isTablet ? 36 : TextStyles.headingLarge(context)),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle - Responsive
              Text(
                "See your student's attendance here.",
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(45, 45, 45, 1),
                ),
              ),
              SizedBox(height: isMobile ? 24 : 40),

              // Attendance Section Title
              Text(
                'Attendance',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(45, 45, 45, 1),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Student Info Card - Responsive Layout
              if (isMobile) ...[
                // Mobile: Stack layout
                Column(
                  children: [
                    // Student Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange[200],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.asset(
                                    'assets/peoples/person_5.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.orange[200],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Student Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      navProvider.selectedUserName?.toString() ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      navProvider.selectedUserEmail?.toString() ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          navProvider.selectedUserPhoneNo?.toString() ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Attendance Percentage
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total attendance: ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          Consumer<AdminProvider>(
                            builder: (context, provider, child) {
                              if (attendanceList.isEmpty) {
                                return Text(
                                  '0%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                );
                              }
                              
                              final presentCount = attendanceList
                                  .where((attendance) => 
                                      attendance.status.toLowerCase() == 'present')
                                  .length;
                              final totalCount = attendanceList.length;
                              final percentage = totalCount > 0 
                                  ? ((presentCount / totalCount) * 100).round()
                                  : 0;
                              
                              return Text(
                                '$percentage%',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Desktop/Tablet: Side-by-side layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orange[200],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  'assets/peoples/person_5.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.orange[200],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Student Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    navProvider.selectedUserName?.toString() ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          navProvider.selectedUserEmail?.toString() ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: isTablet ? 12 : 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 16 : 26),
                                      Icon(
                                        Icons.phone,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        navProvider.selectedUserPhoneNo?.toString() ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: isTablet ? 12 : 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Attendance Percentage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Total attendance: ',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 12 : 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          Consumer<AdminProvider>(
                            builder: (context, provider, child) {
                              if (attendanceList.isEmpty) {
                                return Text(
                                  '0%',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 24 : 32,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                );
                              }
                              
                              final presentCount = attendanceList
                                  .where((attendance) => 
                                      attendance.status.toLowerCase() == 'present')
                                  .length;
                              final totalCount = attendanceList.length;
                              final percentage = totalCount > 0 
                                  ? ((presentCount / totalCount) * 100).round()
                                  : 0;
                              
                              return Text(
                                '$percentage%',
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 24 : 32,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: isMobile ? 24 : 30),

              // Attendance Table - Responsive
              Container(
                height: isMobile ? screenHeight - 480 : 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 12 : 16,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: isMobile ? 3 : 2,
                            child: Text(
                              'Date',
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: isMobile ? 2 : 2,
                            child: Text(
                              'Status',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Action',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Divider(height: 1, color: Colors.grey[200]),

                    // Table Body
                    Expanded(
                      child: ListView.builder(
                        itemCount: attendanceList.length,
                        itemBuilder: (context, index) {
                          final attendance = attendanceList[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 24,
                              vertical: isMobile ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Date
                                Expanded(
                                  flex: isMobile ? 3 : 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: isMobile ? 14 : 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: isMobile ? 6 : 8),
                                      Flexible(
                                        child: Text(
                                          attendance.date,
                                          style: GoogleFonts.poppins(
                                            fontSize: isMobile ? 12 : 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status
                                Expanded(
                                  flex: isMobile ? 2 : 2,
                                  child: Center(
                                    child: Container(
                                      width: isMobile ? null : 233,
                                      height: isMobile ? 32 : 44,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 8 : 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: attendance.status.toLowerCase() == 'present'
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            attendance.status.toLowerCase() == 'present'
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            size: isMobile ? 14 : 16,
                                            color: attendance.status.toLowerCase() == 'present'
                                                ? Colors.green[600]
                                                : Colors.red[600],
                                          ),
                                          SizedBox(width: isMobile ? 4 : 6),
                                          Flexible(
                                            child: Text(
                                              attendance.status,
                                              style: GoogleFonts.poppins(
                                                fontSize: isMobile ? 12 : 14,
                                                fontWeight: FontWeight.w500,
                                                color: attendance.status.toLowerCase() == 'present'
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Action
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: GestureDetector(
                                      onTapDown: (TapDownDetails details) {
                                        _showStatusDropdown(attendance, details.globalPosition);
                                      },
                                      child: Image.asset(
                                        'assets/icons/lesson_edit.png',
                                        height: isMobile ? 18 : 20.5,
                                        width: isMobile ? 17 : 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      case 'excused':
        return Icons.event_available;
      default:
        return Icons.help;
    }
  }
}