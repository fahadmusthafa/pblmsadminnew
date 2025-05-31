import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/models/models.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/super_admin_provider.dart';
import 'package:pb_lms/utilities/constants.dart';
import 'package:pb_lms/views/bread_crumb.dart';
import 'package:pb_lms/views/course_management/view_assignments_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonsAssignmentsScreen extends StatefulWidget {
  final int moduleId;
  final int courseId;
  final String moduleName;
  final String courseName;
  const LessonsAssignmentsScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.moduleName,
    required this.courseName,
  });

  @override
  State<LessonsAssignmentsScreen> createState() =>
      _LessonsAssignmentsScreenState();
}

class _LessonsAssignmentsScreenState extends State<LessonsAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    assignmentView = false;
    lessonView = false;
    Future.microtask(() {
      final provider = Provider.of<SuperAdminProvider>(context, listen: false);
      final navProvider = Provider.of<NavigationProvider>(
        context,
        listen: false,
      );
      provider
          .getLessons(
            navProvider.selectedModuleId,
            navProvider.selectedCourseId,
          )
          .then((_) {
            setState(() {
              filteredLessons = provider.lessons;
            });
          });
      provider
          .getAssignments(
            navProvider.selectedModuleId,
            navProvider.selectedCourseId,
          )
          .then((_) {
            filteredAssignments = provider.assignments;
          });
      lessonSearchController.addListener(() {
        filterLessons(lessonSearchController.text);
      });
      assignmentSearchController.addListener(() {
        filterAssignments(assignmentSearchController.text);
      });
    });
  }

  void filterLessons(String query) {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final allLessons = provider.lessons;
    setState(() {
      filteredLessons =
          allLessons.where((lesson) {
            final title = lesson.title?.toLowerCase() ?? '';
            return title.contains(query.toLowerCase());
          }).toList();
    });
  }

  void filterAssignments(String query) {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final allAssignments = provider.assignments;
    setState(() {
      filteredAssignments =
          allAssignments.where((assignment) {
            final title = assignment.title?.toLowerCase() ?? '';
            return title.contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _launchVideoLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch the live link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<LessonModel> filteredLessons = [];
  TextEditingController lessonSearchController = TextEditingController();

  bool assignmentView = false;
  int? selectedAssignment;
  bool lessonView = false;
  int? selectedLesson;

  int? editLessonId;
  int? editAssignmentId;
  List<AssignmentModel> filteredAssignments = [];
  TextEditingController assignmentSearchController = TextEditingController();
  TextEditingController _lessonTitleController = TextEditingController();
  TextEditingController _lessonContentController = TextEditingController();
  TextEditingController _pdfController = TextEditingController();
  TextEditingController _videoController = TextEditingController();

  TextEditingController _assignmentContentController = TextEditingController();
  TextEditingController _assignmentTitleController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();

  void createLesson() async {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final title = _lessonTitleController.text;
    final content = _lessonContentController.text;
    final videoLink = _videoController.text;
    final pdfFile = _pdfController.text;
    try {
      if (_lessonTitleController.text.isNotEmpty ||
          _lessonContentController.text.isNotEmpty) {
        Map<String, dynamic> response = {};
        if (editLessonId != null) {
          response = await provider.updateLessons(
            navProvider.selectedCourseId,
            navProvider.selectedModuleId,
            editLessonId,
            title,
            content,
            videoLink,
            pdfFile,
          );
        } else {
          response = await provider.createLessons(
            navProvider.selectedCourseId,
            navProvider.selectedModuleId,
            title,
            content,
            videoLink,
            pdfFile,
          );
        }

        if (response['status']) {
          setState(() {
            filteredLessons = provider.lessons;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color.fromARGB(255, 12, 201, 70),
              duration: Duration(seconds: 3),
              content: Text(response['message']),
            ),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              content: Text(response['message']),
            ),
          );
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            content: Text('Enter all required fields'),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          content: Text('Error in creating Lesson'),
        ),
      );
    }
  }

  void createLessonView() {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<SuperAdminProvider>(context);
        final screenWidth = MediaQuery.sizeOf(context).width;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.circular(30),
            ),
            width: screenWidth < 700 ? null : screenWidth * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editLessonId != null ? 'Update Lesson' : 'Add a New Lesson',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _lessonTitleController,
                  decoration: InputDecoration(
                    hintText: 'Enter Lesson Name',
                    labelText: 'Lesson Name',
                    suffixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _lessonContentController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Content',
                    hintText: 'Enter content for lesson',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _videoController,
                  decoration: InputDecoration(
                    hintText: 'Enter Video Link(Optional)',
                    labelText: 'Video Link',
                    suffixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),
                TextFormField(
                  controller: _pdfController,
                  decoration: InputDecoration(
                    hintText: 'Enter Pdf Link (Optional)',
                    labelText: 'PDF Link',
                    suffixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width:
                          (screenWidth < 700)
                              ? double.infinity
                              : (screenWidth * 0.2 - 35),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (screenWidth < 700)
                                  ? Color.fromARGB(255, 12, 201, 70)
                                  : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            (screenWidth < 700)
                                ? createLesson
                                : () => Navigator.pop(context),
                        child: Text(
                          (screenWidth < 700)
                              ? editLessonId != null
                                  ? 'Update'
                                  : 'Create'
                              : 'Close',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width:
                          (screenWidth < 700)
                              ? double.infinity
                              : (screenWidth * 0.2 - 35),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (screenWidth < 700)
                                  ? Colors.redAccent
                                  : Color.fromARGB(255, 12, 201, 70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            (screenWidth < 700)
                                ? () => Navigator.pop(context)
                                : createLesson,
                        child: Text(
                          (screenWidth < 700)
                              ? 'Close'
                              : editLessonId != null
                              ? 'Update'
                              : 'Create',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _lessonTitleController.clear();
      _lessonContentController.clear();
      editLessonId = null;
      _videoController.clear();
      _pdfController.clear();
    });
  }

  void updateLesson(
    int lessonId,
    String title,
    String content,
    String? videoLink,
    String? pdfPath,
  ) {
    editLessonId = lessonId;
    _lessonTitleController.text = title;
    _lessonContentController.text = content;
    _videoController.text = videoLink ?? '';
    _pdfController.text = pdfPath ?? '';
    createLessonView();
  }

  void deleteLesson(
    String? title,
    int? courseId,
    int? moduleId,
    int? lessonId,
  ) async {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final response = await provider.deleteLessons(
      courseId,
      moduleId,
      lessonId,
      title,
    );
    if (response['status']) {
      setState(() {
        filteredLessons = provider.lessons;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${response['message']}"),
          backgroundColor: Color.fromARGB(255, 12, 201, 70),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${response['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void deleteLessonAlert(
    String? title,
    int? courseId,
    int? moduleId,
    int? lessonId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete lesson $title?',
            style: GoogleFonts.poppins(
              fontSize: TextStyles.regularText(context),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.regularText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: TextStyles.regularText(context),
                ),
              ),
              onPressed: () {
                deleteLesson(title, courseId, moduleId, lessonId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateAssignment(
    int assignmentId,
    String title,
    String description,
    String dueDate,
  ) {
    editAssignmentId = assignmentId;
    _assignmentTitleController.text = title;
    _assignmentContentController.text = description;
    _dueDateController.text = dueDate;
    createAssignmentView();
  }

  void createAssignment() async {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final title = _assignmentTitleController.text;
    final content = _assignmentContentController.text;
    final dueDate = _dueDateController.text;
    try {
      if (_assignmentTitleController.text.isNotEmpty ||
          _assignmentContentController.text.isNotEmpty ||
          _dueDateController.text.isNotEmpty) {
        Map<String, dynamic> response = {};
        if (editAssignmentId != null) {
          response = await provider.updateAssignments(
            navProvider.selectedCourseId,
            navProvider.selectedModuleId,
            editAssignmentId,
            title,
            content,
            dueDate,
          );
        } else {
          response = await provider.createAssignment(
            navProvider.selectedCourseId,
            navProvider.selectedModuleId,
            title,
            content,
            dueDate,
          );
        }
        if (response['status']) {
          setState(() {
            filteredAssignments = provider.assignments;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color.fromARGB(255, 12, 201, 70),
              duration: Duration(seconds: 3),
              content: Text(response['message']),
            ),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              content: Text(response['message']),
            ),
          );
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            content: Text('Enter all required fields'),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          content: Text('Error in creating assignment'),
        ),
      );
    }
  }

  void createAssignmentView() {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<SuperAdminProvider>(context);
        final screenWidth = MediaQuery.sizeOf(context).width;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.circular(30),
            ),
            width: screenWidth < 700 ? null : screenWidth * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editAssignmentId != null
                      ? 'Update Assignment'
                      : 'Add a New Assignment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _assignmentTitleController,
                  decoration: InputDecoration(
                    hintText: 'Enter Assignment Title',
                    labelText: 'Assignment Title',
                    suffixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _assignmentContentController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Description',
                    hintText: 'Enter description for assignment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _dueDateController,
                  decoration: InputDecoration(
                    hintText: 'Enter Due Date',
                    labelText: 'Due Date',
                    suffixIcon: Icon(Icons.calendar_month_rounded),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickDate != null) {
                      String formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickDate);

                      setState(() {
                        _dueDateController.text = formattedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width:
                          (screenWidth < 700)
                              ? double.infinity
                              : (screenWidth * 0.2 - 35),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (screenWidth < 700)
                                  ? Color.fromARGB(255, 12, 201, 70)
                                  : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            (screenWidth < 700)
                                ? createAssignment
                                : () => Navigator.pop(context),
                        child: Text(
                          (screenWidth < 700)
                              ? editAssignmentId != null
                                  ? 'Update'
                                  : 'Create'
                              : 'Close',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width:
                          (screenWidth < 700)
                              ? double.infinity
                              : (screenWidth * 0.2 - 35),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (screenWidth < 700)
                                  ? Colors.redAccent
                                  : Color.fromARGB(255, 12, 201, 70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            (screenWidth < 700)
                                ? () => Navigator.pop(context)
                                : createAssignment,
                        child: Text(
                          (screenWidth < 700)
                              ? 'Close'
                              : editAssignmentId != null
                              ? 'Update'
                              : 'Create',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _assignmentTitleController.clear();
      _assignmentContentController.clear();
      _dueDateController.clear();
      editAssignmentId = null;
    });
  }

  void deleteAssignment(
    String? title,
    int? courseId,
    int? moduleId,
    int? assignmentId,
  ) async {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final response = await provider.deleteAssignments(
      courseId,
      moduleId,
      assignmentId,
      title,
    );
    if (response['status']) {
      setState(() {
        filteredAssignments = provider.assignments;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${response['message']}"),
          backgroundColor: Color.fromARGB(255, 12, 201, 70),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${response['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void deleteAssignmentAlert(
    String? title,
    int? courseId,
    int? moduleId,
    int? assignmentId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete assignment $title?',
            style: GoogleFonts.poppins(
              fontSize: TextStyles.regularText(context),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.regularText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: TextStyles.regularText(context),
                ),
              ),
              onPressed: () {
                deleteAssignment(title, courseId, moduleId, assignmentId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    lessonSearchController.dispose();
    assignmentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuperAdminProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    final lessons = provider.lessons;
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (navProvider.isViewingAssignments) {
      return ViewAssignmentScreen(
        assignmentId: navProvider.selectedAssignmentId!,
        title: navProvider.selectedAssignmentName!,
      );
    }

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 20,
          top: 32,
          right: 20,
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
              BreadCrumb(courseName: widget.courseName),

              Text(
                'Module Management',
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.headingLarge(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Manage your lessons and assignments here',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Lessons',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: lessonSearchController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hoverColor: Colors.white,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            size: 24,
                          ),
                          hintText: 'Search',
                          contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 44, // Match the parent SizedBox height
                      child: ElevatedButton(
                        onPressed: () {
                          createLessonView();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 1,
                          maximumSize: Size(254, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            12,
                            201,
                            70,
                          ),
                        ),
                        child:
                            screenWidth < 800
                                ? Icon(
                                  CupertinoIcons.add,
                                  size: 24,
                                  color: Colors.white,
                                )
                                : Text(
                                  'Create Lesson',
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

              SizedBox(height: 20),

              provider.isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 12, 201, 70),
                    ),
                  )
                  : buildLessonsWidget(filteredLessons),

              SizedBox(height: 40),
              Text(
                'Assignments',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: assignmentSearchController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hoverColor: Colors.white,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            size: 24,
                          ),
                          hintText: 'Search',
                          contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 44, // Match the parent SizedBox height
                      child: ElevatedButton(
                        onPressed: () {
                          createAssignmentView();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 1,
                          maximumSize: Size(254, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            12,
                            201,
                            70,
                          ),
                        ),
                        child:
                            screenWidth < 800
                                ? Icon(
                                  CupertinoIcons.add,
                                  size: 24,
                                  color: Colors.white,
                                )
                                : Text(
                                  'Create Assignment',
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

              SizedBox(height: 20),
              provider.isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 12, 201, 70),
                    ),
                  )
                  : buildAssignmentsWidget(filteredAssignments),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLessonsWidget(List<LessonModel> lessons) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (lessons.isEmpty) {
      return Container(
        alignment: Alignment.center,
        height: 60,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Text(
          'No lessons found',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      height: lessons.length <= 5 ? null : 300,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        itemCount: lessons.length,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return InkWell(
            onTap: () {
              setState(() {
                final bool isSameLesson = selectedLesson == lesson.lessonId;
                final bool isCurrentlyExpanded = lessonView && isSameLesson;

                if (isCurrentlyExpanded) {
                  lessonView = false;
                  selectedLesson =
                      null; // Uncomment if you want to clear selection
                } else {
                  selectedLesson = lesson.lessonId;
                  lessonView = true;
                }
              });
            },
            child: Padding(
              padding:
                  lessons.length >= 2
                      ? const EdgeInsets.fromLTRB(0, 5, 0, 5)
                      : EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:
                        lessonView && selectedLesson == lesson.lessonId
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title ?? 'Untitled Lesson',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 8),
                                      width: double.infinity,
                                      child: Text(
                                        lesson.content!,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        // Video Link Button
                                        if (lesson.videoLink != null)
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              final screenWidth =
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        Colors.black,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      color: Colors.black,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                  ),
                                                  onPressed:
                                                      () => _launchVideoLink(
                                                        lesson.videoLink!,
                                                      ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (screenWidth > 700)
                                                        Text('Video Link'),
                                                      if (screenWidth > 700)
                                                        SizedBox(width: 4),
                                                      Icon(
                                                        Icons
                                                            .play_arrow_rounded,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                        // PDF Link Button
                                        if (lesson.pdfPath != null)
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              final screenWidth =
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        Colors.black,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      color: Colors.black,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                  ),
                                                  onPressed:
                                                      () => _launchVideoLink(
                                                        lesson.pdfPath!,
                                                      ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (screenWidth > 700)
                                                        Text('Pdf Link'),
                                                      if (screenWidth > 700)
                                                        SizedBox(width: 4),
                                                      Icon(
                                                        Icons
                                                            .picture_as_pdf_rounded,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                              ],
                            )
                            : Text(
                              lesson.title ?? 'Untitled Lesson',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap:
                            () => updateLesson(
                              lesson.lessonId!,
                              lesson.title ?? '',
                              lesson.content ?? '',
                              lesson.videoLink,
                              lesson.pdfPath,
                            ),
                        child: Image.asset(
                          'assets/icons/lesson_edit.png',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap:
                            () => deleteLessonAlert(
                              lesson.title,
                              navProvider.selectedCourseId,
                              navProvider.selectedModuleId,
                              lesson.lessonId,
                            ),
                        child: SvgPicture.asset(
                          'assets/icons/lesson_delete.svg',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        lessonView && selectedLesson == lesson.lessonId
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_right_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildAssignmentsWidget(List<AssignmentModel> assignments) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (assignments.isEmpty) {
      return Container(
        alignment: Alignment.center,
        height: 60,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Text(
          'No assignments found',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      height: assignments.length <= 5 ? null : 300,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        itemCount: assignments.length,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return InkWell(
            onTap: () {
              setState(() {
                final bool isSameAssignment =
                    selectedAssignment == assignment.assignmentId;
                final bool isCurrentlyExpanded =
                    assignmentView && isSameAssignment;

                if (isCurrentlyExpanded) {
                  // Case 1: Clicking expanded lesson → Collapse
                  assignmentView = false;
                  selectedAssignment = null;
                } else {
                  // Case 2: Clicking different lesson OR clicking collapsed lesson → Expand
                  selectedAssignment = assignment.assignmentId;
                  assignmentView = true;
                }
              });
            },
            child: Padding(
              padding:
                  assignments.length >= 2
                      ? const EdgeInsets.fromLTRB(0, 5, 0, 5)
                      : EdgeInsets.zero,
              child: Column(
                children: [
                  // Main row with title and actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title section - takes most space but leaves room for actions
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines:
                              assignmentView &&
                                      selectedAssignment ==
                                          assignment.assignmentId
                                  ? 3
                                  : 1,
                        ),
                      ),

                      // Fixed width for actions to prevent overflow
                      SizedBox(
                        //width: 200, // Fixed width for action buttons
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (screenWidth > 700)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  side: const BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                onPressed: () =>navProvider.navigateToSubmissions(assignment.assignmentId,assignment.title),
                                child: Text('View Submissions'),
                              ),
                            if (screenWidth > 700) SizedBox(width: 8),
                            GestureDetector(
                              onTap:
                                  () => updateAssignment(
                                    assignment.assignmentId,
                                    assignment.title,
                                    assignment.description,
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(assignment.dueDate!),
                                  ),
                              child: Image.asset(
                                'assets/icons/lesson_edit.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap:
                                  () => deleteAssignmentAlert(
                                    assignment.title,
                                    navProvider.selectedCourseId,
                                    navProvider.selectedModuleId,
                                    assignment.assignmentId,
                                  ),
                              child: SvgPicture.asset(
                                'assets/icons/lesson_delete.svg',
                                height: 24,
                                width: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              assignmentView &&
                                      selectedAssignment ==
                                          assignment.assignmentId
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Expanded details section (shown only when expanded)
                  if (assignmentView &&
                      selectedAssignment == assignment.assignmentId) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  assignment.description,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Due date section
                          Row(
                            children: [
                              Text(
                                'Due Date: ',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(assignment.dueDate!),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // View Submission section
                          if (screenWidth < 700)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                side: const BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onPressed: () {},
                              child: Text('View Submissions'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}