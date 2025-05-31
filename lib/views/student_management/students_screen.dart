import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/views/student_management/students_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:pb_lms/models/fahad/model.dart';

class StudentsManagementScreen extends StatefulWidget {
  const StudentsManagementScreen({super.key});

  @override
  State<StudentsManagementScreen> createState() =>
      _StudentsManagementScreenState();
}

class _StudentsManagementScreenState extends State<StudentsManagementScreen> {
  int? selectedCourseId;
  int? selectedBatchId;
  String? selectedCourseName;
  String? selectedBatchName;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  String? error;
  List<dynamic> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.AdminfetchCoursesprovider();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> _onCourseSelected(int courseId, String courseName) async {
    setState(() {
      selectedCourseId = courseId;
      selectedCourseName = courseName;
      selectedBatchId = null;
      selectedBatchName = null;
      isLoading = true;
      filteredStudents = [];
    });

    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.AdminfetchBatchForCourseProvider(courseId);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onBatchSelected(int batchId, String batchName) async {
    setState(() {
      selectedBatchId = batchId;
      selectedBatchName = batchName;
      isLoading = true;
    });

    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.AdminfetchallusersBatchProvider(
        selectedCourseId!,
        batchId,
      );
      // Update filtered students when batch data is loaded
      _updateFilteredStudents();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateFilteredStudents() {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    final students = provider.batchData?.students ?? [];
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredStudents = students;
      } else {
        filteredStudents =
            students.where((student) {
              return student.name.toLowerCase().contains(searchQuery) ||
                  student.email.toLowerCase().contains(searchQuery);
            }).toList();
      }
    });
  }

  void _onSearchChanged(String value) {
    _updateFilteredStudents();
  }

  void _showRemoveConfirmation(BuildContext context, dynamic student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Remove Student',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to remove ${student.name} from this batch?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final provider = Provider.of<AdminAuthProvider>(
                      context,
                      listen: false,
                    );
                    await provider.AdmindeleteUserFromBatchprovider(
                      courseId: selectedCourseId!,
                      batchId: selectedBatchId!,
                      userId: student.studentId,
                    );
                    await _onBatchSelected(
                      selectedBatchId!,
                      selectedBatchName!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${student.name} removed from batch'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to remove student: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  'Remove',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showAccessManagementOptions(BuildContext context, dynamic student) {
    final bool isActive = student.status == 'active';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              isActive ? 'Pause Access' : 'Resume Access',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              isActive
                  ? 'Are you sure you want to pause ${student.name}\'s access to this batch?'
                  : 'Are you sure you want to resume ${student.name}\'s access to this batch?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.orange : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final provider = Provider.of<AdminAuthProvider>(
                      context,
                      listen: false,
                    );
                    await provider.manageStudentAccess(
                      studentId: student.studentId,
                      batchId: selectedBatchId!,
                      action: isActive ? 'pause' : 'resume',
                    );
                    await _onBatchSelected(
                      selectedBatchId!,
                      selectedBatchName!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isActive
                              ? '${student.name}\'s access has been paused'
                              : '${student.name}\'s access has been resumed',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update student access: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  isActive ? 'Pause' : 'Resume',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _addStudent() {
    if (selectedCourseId == null || selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course and batch first'),
          backgroundColor: Colors.black12,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      return;
    }
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    navProvider.navigateToAllUsers(
      selectedCourseId!,
      selectedBatchId!,
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
    bool enabled = true,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: screenWidth < 600 ? 14 : 16,
            ),
          ),
          value: value,
          onChanged: enabled ? onChanged : null,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: screenWidth < 600 ? 14 : 16,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: enabled ? Colors.grey[700] : Colors.grey[400],
          ),
          items:
              items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    getLabel(item),
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth < 600 ? 14 : 16,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 600;

    final List<String> avatarImages = [
      'assets/peoples/person_1.png',
      'assets/peoples/person_2.png',
      'assets/peoples/person_3.png',
      'assets/peoples/person_4.png',
      'assets/peoples/person_5.png',
      'assets/peoples/person_6.png',
      'assets/peoples/person_7.png',
      'assets/peoples/person_8.png',
      'assets/peoples/person_9.png',
      'assets/peoples/person_10.png',
    ];

    final avatarIndex = student.name.hashCode.abs() % avatarImages.length;
    final avatarPath = avatarImages[avatarIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 40 : 48,
            height: isCompact ? 40 : 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  final colors = [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                    const Color(0xFF06B6D4),
                    const Color(0xFF10B981),
                    const Color(0xFFF59E0B),
                    const Color(0xFFEF4444),
                  ];
                  final colorIndex =
                      student.name.hashCode.abs() % colors.length;

                  return Container(
                    color: colors[colorIndex],
                    child: Center(
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: isCompact ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.email,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: isCompact ? 13 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed:
                      () => _showAccessManagementOptions(context, student),
                  icon: Icon(
                    student.status == 'active'
                        ? Icons.edit_outlined
                        : Icons.edit_outlined,
                    size: 18,
                    color:
                        student.status == 'active'
                            ? Colors.black87
                            : Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip:
                      student.status == 'active'
                          ? 'Pause Access'
                          : 'Resume Access',
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showRemoveConfirmation(context, student),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: 'Remove Student',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isCompact = screenWidth < 600;
    final navProvider = Provider.of<NavigationProvider>(context);

    if (navProvider.isViewingAllUsers) {
      return AdminAllUsersPage(
        courseId: navProvider.selectedCourseId!,
        batchId: navProvider.selectedBatchId!,
      );
    }

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: isCompact ? 16 : 20,
          top: isCompact ? 40 : 55,
          right: isCompact ? 16 : 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 235, 235, 235),
        ),
        child: Consumer<AdminAuthProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Students Management',
                    style: GoogleFonts.poppins(
                      fontSize:
                          isCompact
                              ? 32
                              : isTablet
                              ? 48
                              : 64,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Select your course and batch and manage your students here.',
                    style: GoogleFonts.poppins(
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Course and Batch Selection
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select your course',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown<Admincoursemodel>(
                                hint: 'Select Course',
                                value:
                                    provider.course.isNotEmpty &&
                                            selectedCourseId != null
                                        ? provider.course.firstWhere(
                                          (course) =>
                                              course.courseId ==
                                              selectedCourseId,
                                          orElse: () => provider.course.first,
                                        )
                                        : null,
                                items: provider.course,
                                getLabel: (course) => course.name ?? 'Untitled',
                                onChanged: (course) {
                                  if (course != null) {
                                    _onCourseSelected(
                                      course.courseId!,
                                      course.name ?? 'Untitled',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select your batch',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown<AdminCourseBatch>(
                                hint: 'Select Batch',
                                value:
                                    selectedCourseId != null &&
                                            provider.courseBatches.containsKey(
                                              selectedCourseId,
                                            ) &&
                                            selectedBatchId != null
                                        ? provider
                                            .courseBatches[selectedCourseId]!
                                            .firstWhere(
                                              (batch) =>
                                                  batch.batchId ==
                                                  selectedBatchId,
                                              orElse:
                                                  () =>
                                                      provider
                                                          .courseBatches[selectedCourseId]!
                                                          .first,
                                            )
                                        : null,
                                items:
                                    selectedCourseId != null &&
                                            provider.courseBatches.containsKey(
                                              selectedCourseId,
                                            )
                                        ? provider
                                            .courseBatches[selectedCourseId]!
                                        : [],
                                getLabel:
                                    (batch) =>
                                        batch.batchName ?? 'Untitled Batch',
                                onChanged: (batch) {
                                  if (selectedCourseId != null &&
                                      batch != null) {
                                    _onBatchSelected(
                                      batch.batchId,
                                      batch.batchName,
                                    );
                                  }
                                },
                                enabled: selectedCourseId != null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select your course',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown<Admincoursemodel>(
                              hint: 'Select Course',
                              value:
                                  provider.course.isNotEmpty &&
                                          selectedCourseId != null
                                      ? provider.course.firstWhere(
                                        (course) =>
                                            course.courseId == selectedCourseId,
                                        orElse: () => provider.course.first,
                                      )
                                      : null,
                              items: provider.course,
                              getLabel: (course) => course.name ?? 'Untitled',
                              onChanged: (course) {
                                if (course != null) {
                                  _onCourseSelected(
                                    course.courseId!,
                                    course.name ?? 'Untitled',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select your batch',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown<AdminCourseBatch>(
                              hint: 'Select Batch',
                              value:
                                  selectedCourseId != null &&
                                          provider.courseBatches.containsKey(
                                            selectedCourseId,
                                          ) &&
                                          selectedBatchId != null
                                      ? provider
                                          .courseBatches[selectedCourseId]!
                                          .firstWhere(
                                            (batch) =>
                                                batch.batchId ==
                                                selectedBatchId,
                                            orElse:
                                                () =>
                                                    provider
                                                        .courseBatches[selectedCourseId]!
                                                        .first,
                                          )
                                      : null,
                              items:
                                  selectedCourseId != null &&
                                          provider.courseBatches.containsKey(
                                            selectedCourseId,
                                          )
                                      ? provider
                                          .courseBatches[selectedCourseId]!
                                      : [],
                              getLabel:
                                  (batch) =>
                                      batch.batchName ?? 'Untitled Batch',
                              onChanged: (batch) {
                                if (selectedCourseId != null && batch != null) {
                                  _onBatchSelected(
                                    batch.batchId,
                                    batch.batchName,
                                  );
                                }
                              },
                              enabled: selectedCourseId != null,
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  Text(
                    'Students',
                    style: GoogleFonts.poppins(
                      fontSize: isCompact ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                CupertinoIcons.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                              hintText: 'Search students...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: isCompact ? 14 : 16,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed:
                                (selectedCourseId != null &&
                                        selectedBatchId != null)
                                    ? _addStudent
                                    : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              minimumSize:
                                  isCompact
                                      ? const Size(44, 44)
                                      : const Size(140, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  (selectedCourseId != null &&
                                          selectedBatchId != null)
                                      ? const Color.fromARGB(255, 12, 201, 70)
                                      : Colors.grey[400],
                            ),
                            child:
                                isCompact
                                    ? const Icon(
                                      Icons.add,
                                      size: 24,
                                      color: Colors.white,
                                    )
                                    : Text(
                                      'Add student',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Students List
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 12, 201, 70),
                        ),
                      ),
                    )
                  else if (selectedCourseId == null || selectedBatchId == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Select a course and batch to view students',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (provider.batchData?.students.isEmpty ?? true)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'No students in this batch',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add students to see them here',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filteredStudents.isEmpty &&
                      _searchController.text.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No students found',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search terms',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredStudents.length} student${filteredStudents.length != 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            return _buildStudentCard(student);
                          },
                        ),
                      ],
                    ),

                  if (error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              error!,
                              style: GoogleFonts.poppins(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                error = null;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red[700],
                              size: 20,
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
