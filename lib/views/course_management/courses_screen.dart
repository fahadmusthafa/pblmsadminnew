import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/models/models.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/super_admin_provider.dart';
import 'package:pb_lms/utilities/constants.dart';
import 'package:pb_lms/views/course_management/modules_screen.dart';
import 'package:pb_lms/widgets/notched_container.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<SuperAdminProvider>(context, listen: false);
      provider.fetchCourses().then((_) {
        setState(() {
          filteredCourses = provider.courses;
        });
      });
    });
    searchController.addListener(() {
      filterCourses(searchController.text);
    });
  }

  void filterCourses(String query) {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final allCourses = provider.courses;
    setState(() {
      filteredCourses =
          allCourses.where((course) {
            final title = course.title?.toLowerCase() ?? '';
            return title.contains(query.toLowerCase());
          }).toList();
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<CourseModel> filteredCourses = [];
  TextEditingController searchController = TextEditingController();
  int? editId;

  void createCourse() async {
    try {
      final title = _titleController.text;
      final description = _descController.text;
      if (title.isNotEmpty && description.isNotEmpty || _descController.text.isNotEmpty && _titleController.text.isNotEmpty) {
        final provider = Provider.of<SuperAdminProvider>(
          context,
          listen: false,
        );
        Map<String, dynamic> response = {};
        if (editId != null) {
          response = await provider.updateCourse(editId, title, description);
        } else {
          response = await provider.createCourse(title, description);
        }
        if (response['status']) {
          setState(() {
            filteredCourses = provider.courses;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 3),
              content: Text(response['message']),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Enter all fields'),
          ),
        );
      }
    } catch (e) {
      print('Error in ui: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(seconds: 3), content: Text('$e')),
      );
    }
  }

  void createCourseView() {
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
                  editId != null ? 'Add a New Course' : 'Add a New Course',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter Course Name',
                    labelText: 'Course Name',
                    suffixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Description',
                    hintText: 'Enter description for course',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                                ? createCourse
                                : () => Navigator.pop(context),
                        child: Text(
                          (screenWidth < 700)
                              ? editId != null
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
                                : createCourse,
                        child: Text(
                          (screenWidth < 700)
                              ? 'Close'
                              : editId != null
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
      _titleController.clear();
      _descController.clear();
    });
  }

  void editCourse(int? courseId, String? title, String? description) {
    editId = courseId;
    _titleController.text = title.toString();
    _descController.text = description.toString();
    createCourseView();
  }

  void deleteCourse(String? title, int? courseId) async {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final response = await provider.deleteCourse(courseId, title);
    if (response['status']) {
      setState(() {
        filteredCourses = provider.courses;
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

  void deleteCourseAlert(String? title, int? courseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete course $title?',
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
                deleteCourse(title, courseId);
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
    _titleController.dispose();
    _descController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuperAdminProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    // If viewing modules, show ModulesScreen
    if (navProvider.isViewingModules) {
      return ModulesScreen(
        courseId: navProvider.selectedCourseId!,
        courseName: navProvider.selectedCourseName!,
      );
    }

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 20,
          top: 55,
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
              Text(
                'Course Management',
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.headingLarge(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Manage your courses here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Courses',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: searchController,
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
                          suffixIcon:
                              searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      filterCourses('');
                                    },
                                  )
                                  : null,

                          hintText: 'Search',
                          contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: createCourseView,
                        style: ElevatedButton.styleFrom(
                          elevation: 1,
                          maximumSize: Size(254, 44),
                          minimumSize: screenWidth < 800 ? null : Size(200, 44),
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
                                  'Create Course',
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
              const SizedBox(height: 20),
              Align(
                alignment:
                    provider.isLoading
                        ? Alignment.center
                        : filteredCourses.length < 4
                        ? Alignment.topLeft
                        : Alignment.topCenter,
                child:
                    provider.isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 12, 201, 70),
                          ),
                        )
                        : filteredCourses.isEmpty
                        ? Center(
                          child: Text(
                            'No courses available',
                            style: GoogleFonts.poppins(
                              fontSize: TextStyles.headingSmall(context),
                            ),
                          ),
                        )
                        : Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          runAlignment: WrapAlignment.spaceEvenly,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ...filteredCourses.map((course) {
                              final title = course.title ?? 'Untitled';
                              final iconPath =
                                  title.trim().toLowerCase().startsWith('ui ux')
                                      ? 'assets/courses/uiux.svg'
                                      : 'assets/courses/course.svg';

                              return // Replace your NotchedContainer GestureDetector section with this:
                              GestureDetector(
                                onTap: () {
                                  // Navigate to modules using the provider
                                  navProvider.navigateToModules(
                                    course.courseId!,
                                    title,
                                  );
                                },
                                child: NotchedContainer(
                                  width: 254,
                                  height: 254,
                                  backgroundColor: Colors.white,
                                  iconBackgroundColor: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(
                                    30,
                                    10,
                                    10,
                                    10,
                                  ),
                                  topRightIcon: Text(
                                    course.courseId?.toString() ?? '',
                                  ),
                                  child: Stack(
                                    children: [
                                      // Main content
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            iconPath,
                                            height: 100,
                                            width: 100,
                                            placeholderBuilder:
                                                (context) =>
                                                    const CircularProgressIndicator(),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Bottom right positioned icons
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                editCourse(
                                                  course.courseId,
                                                  course.title,
                                                  course.description,
                                                );
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.grey.shade600,
                                              ),
                                              iconSize: 20,
                                              padding: EdgeInsets.all(4),
                                              constraints: BoxConstraints(),
                                            ),
                                            SizedBox(width: 4),
                                            IconButton(
                                              onPressed: () {
                                                deleteCourseAlert(
                                                  course.title,
                                                  course.courseId,
                                                );
                                              },
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                                color: Colors.grey.shade800,
                                              ),
                                              iconSize: 20,
                                              padding: EdgeInsets.all(4),
                                              constraints: BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}