import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class BreadCrumb extends StatelessWidget {
  final String courseName;
  const BreadCrumb({super.key, required this.courseName});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (screenWidth < 400)
          GestureDetector(
            onTap: () => navProvider.navigateBackToCourses(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                SizedBox(width: 4),
                Text(
                  'Courses',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 12, 201, 70),
                  ),
                ),
              ],
            ),
          ),
        if (screenWidth < 400) SizedBox(height: 10),

        Wrap(
          // spacing: 6,
          // runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (screenWidth > 400)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => navProvider.navigateBackToCourses(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  ),
                  SizedBox(width: 4),
                  TextButton(
                    onPressed: () => navProvider.navigateBackToCourses(),
                    child: Text(
                      'Courses',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 12, 201, 70),
                      ),
                    ),
                  ),
                ],
              ),

            if (screenWidth > 400)
              Icon(Icons.arrow_forward_ios_rounded, size: 16),

            Text(
              courseName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            Icon(Icons.arrow_forward_ios_rounded, size: 16),

            TextButton(
              onPressed: navProvider.isViewingLessons
                    ? navProvider.navigateBackToModules
                    : null,
              child: Text(
                'Modules',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight:
                      navProvider.isViewingLessons
                          ? FontWeight.w500
                          : FontWeight.w600,
                  color:
                      navProvider.isViewingLessons
                          ? Color.fromARGB(255, 12, 201, 70)
                          : Colors.black,
                ),
              ),
            ),

            if (navProvider.isViewingLessons)
              Icon(Icons.arrow_forward_ios_rounded, size: 16),

            if (navProvider.isViewingLessons)
              TextButton(
              onPressed: navProvider.isViewingAssignments
                    ? navProvider.navigateBackToAssignments
                    : null,
                child: Text(
                  'Lessons/Assignments',
                  style: GoogleFonts.poppins(
                    fontWeight:
                      navProvider.isViewingAssignments
                          ? FontWeight.w500
                          : FontWeight.w600,
                  color:
                      navProvider.isViewingAssignments
                          ? Color.fromARGB(255, 12, 201, 70)
                          : Colors.black,
                  ),
                ),
              ),

              
            if (navProvider.isViewingAssignments)
              Icon(Icons.arrow_forward_ios_rounded, size: 16),

            if (navProvider.isViewingAssignments)
              Text(
                navProvider.selectedAssignmentName!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ],
    );
  }
}