import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/widgets/notched_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isLargeScreen = screenWidth > 600 && screenHeight > 600;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 235, 235, 235), // Add background color
          borderRadius: BorderRadius.all(Radius.circular(20)),
          
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)), // Clip content to curved shape
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  HeaderSection(),
                  
                  SizedBox(height: 28),
                  
                  // Stats Cards
                  TotalDetails(),
                  
                  SizedBox(height: 24),
                  
                  // Main Content Row - Made responsive
                  if (screenWidth > 1000) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: TaskDetails()),
                        SizedBox(width: 20),
                        Expanded(flex: 1, child: TeamCard()),
                      ],
                    ),
                  ] else ...[
                    TaskDetails(),
                    SizedBox(height: 24),
                    TeamCard(),
                  ],
                  
                  SizedBox(height: 24),
                  
                  // Additional Widgets Row - Made responsive
                  if (screenWidth > 800) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: RecentActivities()),
                        SizedBox(width: 20),
                        Expanded(flex: 1, child: QuickActions()),
                      ],
                    ),
                  ] else ...[
                    RecentActivities(),
                    SizedBox(height: 24),
                    QuickActions(),
                  ],
                  
                  SizedBox(height: 24), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, Super Admin !',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth > 600 ? 64 : 32,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1D23),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
    
      ],
    );
  }
}

class TotalDetails extends StatelessWidget {
  TotalDetails({super.key});

  final List<Map<String, dynamic>> detailCardList = [
    {
      'index': 0,
      'count': 2847,
      'label': 'Total Students',
      'icon': 'assets/icons/student.svg',
      'change': '+12.5%',
      'trend': 'up',
      'color': Color(0xFF4F46E5),
    },
    {
      'index': 1,
      'count': 24,
      'label': 'Active Batches',
      'icon': 'assets/icons/layers.svg',
      'change': '+8.2%',
      'trend': 'up',
      'color': Color(0xFF059669),
    },
    {
      'index': 2,
      'count': 12,
      'label': 'Total Courses',
      'icon': 'assets/icons/carbon_course.svg',
      'change': '+2.4%',
      'trend': 'up',
      'color': Color(0xFFDC2626),
    },
    {
      'index': 3,
      'count': 18,
      'label': 'Faculty Members',
      'icon': 'assets/icons/chalkboard_teacher.svg',
      'change': '+5.1%',
      'trend': 'up',
      'color': Color(0xFFD97706),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        crossAxisCount: screenWidth < 1200
            ? screenWidth < 800
                ? screenWidth < 600 && screenWidth > 500
                    ? 2
                    : 1
                : 2
            : 4,
        mainAxisExtent: 170,
      ),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: detailCardList.length,
      itemBuilder: (context, index) {
        final item = detailCardList[index];
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1A1D23).withOpacity(0.04),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: item['color'],
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFF10B981),
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          item['change'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                item['count'].toString(),
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D23),
                  height: 1.0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item['label'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TaskDetails extends StatelessWidget {
  const TaskDetails({super.key});

  final List<Map<String, dynamic>> tasks = const [
    {
      'title': 'Review Student Applications',
      'description': '12 new applications pending review',
      'priority': 'high',
      'time': '09:00 AM',
      'completed': false,
    },
    {
      'title': 'Faculty Meeting Preparation',
      'description': 'Prepare agenda for monthly faculty meeting',
      'priority': 'medium',
      'time': '11:30 AM',
      'completed': false,
    },
    {
      'title': 'System Maintenance',
      'description': 'Schedule routine database maintenance',
      'priority': 'low',
      'time': '02:00 PM',
      'completed': true,
    },
    {
      'title': 'Budget Review',
      'description': 'Q2 budget analysis and planning',
      'priority': 'high',
      'time': '04:00 PM',
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * 0.6; // Dynamic height based on screen
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight.clamp(400.0, 600.0), // Min 400, Max 600
      ),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A1D23).withOpacity(0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Tasks",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D23),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tasks.where((task) => !task['completed']).length} pending',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: tasks.map((task) => TaskItem(task: task)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor = task['priority'] == 'high'
        ? Color(0xFFDC2626)
        : task['priority'] == 'medium'
            ? Color(0xFFD97706)
            : Color(0xFF10B981);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task['completed'] ? Color(0xFFF8FAFC) : Color(0xFFFAFBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task['completed'] ? Color(0xFFE2E8F0) : Color(0xFFE0E7FF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: task['completed'] ? Color(0xFF10B981) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: task['completed'] ? Color(0xFF10B981) : Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: task['completed']
                ? Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task['completed'] ? Color(0xFF64748B) : Color(0xFF1A1D23),
                    decoration: task['completed'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  task['description'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task['priority'].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                task['time'],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TeamData {
  final int? id;
  final String? name;
  final String? image;
  final Color? colors;
  final String? role;
  final bool? isOnline;
  
  TeamData({this.id, this.name, this.image, this.colors, this.role, this.isOnline});
}

class TeamCard extends StatelessWidget {
  TeamCard({super.key});
  
  final List<TeamData> team = [
    TeamData(
      id: 1,
      name: 'Abhijith Kumar',
      image: 'assets/peoples/person_9.png',
      colors: Color(0xFF4F46E5),
      role: 'Lead Developer',
      isOnline: true,
    ),
    TeamData(
      id: 2,
      name: 'Annjish Raj',
      image: 'assets/peoples/person_8.png',
      colors: Color(0xFF059669),
      role: 'UI/UX Designer',
      isOnline: true,
    ),
    TeamData(
      id: 3,
      name: 'Athul Krishna',
      image: '',
      colors: Color(0xFFDC2626),
      role: 'Backend Dev',
      isOnline: false,
    ),
    TeamData(
      id: 4,
      name: 'Akshay Nair',
      image: 'assets/peoples/person_1.png',
      colors: Color(0xFFD97706),
      role: 'DevOps Engineer',
      isOnline: true,
    ),
    TeamData(
      id: 5,
      name: 'Arshad Ali',
      image: 'assets/peoples/person_6.png',
      colors: Color(0xFF7C3AED),
      role: 'QA Tester',
      isOnline: false,
    ),
    TeamData(
      id: 6,
      name: 'Jomon Joseph',
      image: 'assets/peoples/person_10.png',
      colors: Color(0xFF0891B2),
      role: 'Product Manager',
      isOnline: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * 0.6; // Dynamic height based on screen
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight.clamp(400.0, 600.0), // Min 400, Max 600
      ),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A1D23).withOpacity(0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Members',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D23),
                ),
              ),
              Text(
                '${team.where((member) => member.isOnline == true).length} online',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: team.length,
              itemBuilder: (context, index) {
                final member = team[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE0E7FF), width: 1),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: member.colors,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: member.image != null && member.image != ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      member.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            member.name!.split(' ').map((n) => n[0]).join().toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      member.name!.split(' ').map((n) => n[0]).join().toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          if (member.isOnline == true)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              member.name!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1D23),
                              ),
                            ),
                            Text(
                              member.role!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
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
    );
  }
}

class RecentActivities extends StatelessWidget {
  final List<Map<String, dynamic>> activities = [
    {
      'action': 'New student enrolled',
      'details': 'Sarah Johnson joined Advanced Flutter Course',
      'time': '2 min ago',
      'icon': Icons.person_add_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'action': 'Assignment submitted',
      'details': '24 students completed Module 3 assignment',
      'time': '15 min ago',
      'icon': Icons.assignment_turned_in_outlined,
      'color': Color(0xFF4F46E5),
    },
    {
      'action': 'Course updated',
      'details': 'React Fundamentals course content revised',
      'time': '1 hour ago',
      'icon': Icons.update_outlined,
      'color': Color(0xFFD97706),
    },
    {
      'action': 'System alert',
      'details': 'Server maintenance scheduled for tonight',
      'time': '3 hours ago',
      'icon': Icons.warning_outlined,
      'color': Color(0xFFDC2626),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A1D23).withOpacity(0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added this
        children: [
          Text(
            'Recent Activities',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D23),
            ),
          ),
          SizedBox(height: 20),
          ...activities.map((activity) => ActivityItem(activity: activity)).toList(),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityItem({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'],
              size: 16,
              color: activity['color'],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D23),
                  ),
                ),
                Text(
                  activity['details'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  final List<Map<String, dynamic>> actions = [
    {
      'title': 'Add Student',
      'icon': Icons.person_add_outlined,
      'color': Color(0xFF4F46E5),
    },
    {
      'title': 'Create Batch',
      'icon': Icons.group_add_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Schedule Class',
      'icon': Icons.schedule_outlined,
      'color': Color(0xFFD97706),
    },
    {
      'title': 'Generate Report',
      'icon': Icons.assessment_outlined,
      'color': Color(0xFFDC2626),
    },
    {
      'title': 'Send Notification',
      'icon': Icons.notifications_outlined,
      'color': Color(0xFF7C3AED),
    },
    {
      'title': 'Backup Data',
      'icon': Icons.backup_outlined,
      'color': Color(0xFF0891B2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A1D23).withOpacity(0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added this
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D23),
            ),
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: action['color'].withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: action['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        action['icon'],
                        color: action['color'],
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      action['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D23),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}