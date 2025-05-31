import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/models/models.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/super_admin_provider.dart';
import 'package:pb_lms/utilities/constants.dart';
import 'package:pb_lms/views/bread_crumb.dart';
import 'package:pb_lms/views/course_management/lessons_assignments_screen.dart';
import 'package:pb_lms/widgets/notched_container.dart';
import 'package:provider/provider.dart';

class ModulesScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const ModulesScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<SuperAdminProvider>(context, listen: false);
      provider.fetchCourseModule(widget.courseId).then((_) {
        setState(() {
          filteredModules = provider.modules;
        });
      });
    });
    searchController.addListener(() {
      filterModules(searchController.text);
    });
  }

  TextEditingController searchController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  int? editId;

  List<ModuleModel> filteredModules = [];

  void filterModules(String query) {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final allModules = provider.modules;
    setState(() {
      filteredModules =
          allModules.where((module) {
            final title = module.title?.toLowerCase() ?? '';
            return title.contains(query.toLowerCase());
          }).toList();
    });
  }

  void createModule() async {
    final title = _titleController.text;
    final description = _descController.text;
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    if (title.isNotEmpty &&
            description.isNotEmpty &&
            title == '' &&
            description == '' ||
        _titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
      Map<String, dynamic> response = {};
      if (editId != null) {
        response = await provider.updateModule(
          widget.courseId,
          editId,
          title,
          description,
        );
      } else {
        response = await provider.createModule(
          widget.courseId,
          title,
          description,
        );
      }

      if (response['status']) {
        setState(() {
          filteredModules = provider.modules;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            content: Text(response['message']),
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
          content: Text('Enter all fields'),
        ),
      );
    }
  }

  void createModuleView() {
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
                  editId != null ? 'Update Module' : 'Add a New Course',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter Module Name',
                    labelText: 'Module Name',
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
                    hintText: 'Enter description for module',
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
                                ? createModule
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
                                : createModule,
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

  void editCourse(int? moduleId, String? title, String? description) {
    editId = moduleId;
    _titleController.text = title.toString();
    _descController.text = description.toString();
    createModuleView();
  }

  void deleteModule(String? title, int? courseId, int? moduleId) async {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    final response = await provider.deleteModule(courseId, moduleId, title);
    if (response['status']) {
      setState(() {
        filteredModules = provider.modules;
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

  void deleteCourseAlert(String? title, int? courseId, int? moduleId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete module $title?',
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
                deleteModule(title, courseId, moduleId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuperAdminProvider>(context);
    final modules = provider.modules;
    final navProvider = Provider.of<NavigationProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (navProvider.isViewingLessons) {
      return LessonsAssignmentsScreen(
        moduleId: navProvider.selectedModuleId!,
        moduleName: navProvider.selectedModuleName!,
        courseId: widget.courseId,
        courseName: widget.courseName,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Breadcrumb Navigation
              BreadCrumb(courseName: widget.courseName),
              Text(
                'Course Management',
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.headingLarge(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Manage your modules here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Modules',
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
                          hintText: 'Search',
                          contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: createModuleView,
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
                                  'Create Module',
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
                        : filteredModules.length < 4
                        ? Alignment.topLeft
                        : Alignment.topCenter,
                child:
                    provider.isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 12, 201, 70),
                          ),
                        )
                        : filteredModules.isEmpty
                        ? Center(
                          child: Text(
                            'No modules available',
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
                            ...filteredModules.map((item) {
                              final title = item.title ?? 'Untitled';
                              final iconPath =
                                  title.trim().toLowerCase().startsWith('ui ux')
                                      ? 'assets/courses/uiux.svg'
                                      : 'assets/courses/course.svg';

                              return GestureDetector(
                                onTap:
                                    () => navProvider.navigateToLessons(
                                      item.moduleId!,
                                      item.title!,
                                    ),
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
                                    (modules.indexOf(item) + 1).toString(),
                                  ),
                                  child: Stack(
                                    children: [
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
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed:
                                                  () => editCourse(
                                                    item.moduleId,
                                                    item.title,
                                                    item.content,
                                                  ),
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
                                              onPressed:
                                                  () => deleteCourseAlert(
                                                    title,
                                                    navProvider
                                                        .selectedCourseId,
                                                    item.moduleId,
                                                  ),
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