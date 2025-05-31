import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/super_admin_provider.dart';
import 'package:pb_lms/views/bread_crumb.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/utilities/constants.dart';

class ViewAssignmentScreen extends StatefulWidget {
  final int assignmentId;
  final String title;

  const ViewAssignmentScreen({
    super.key,
    required this.assignmentId,
    required this.title,
  });

  @override
  State<ViewAssignmentScreen> createState() => _ViewAssignmentScreenState();
}

class _ViewAssignmentScreenState extends State<ViewAssignmentScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int? expandedSubmissionIndex;

  // Random avatar images - replace with your asset paths
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

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SuperAdminProvider>(
        context,
        listen: false,
      ).fetchSubmissions(widget.assignmentId),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  String _getRandomAvatar(int index) {
    return avatarImages[index % avatarImages.length];
  }

  Widget _buildSubmissionCard(
    dynamic submission,
    int index,
    double screenWidth,
  ) {
    final isExpanded = expandedSubmissionIndex == index;

    Color statusColor;
    String statusText;

    switch (submission.status.toLowerCase()) {
      case "completed":
        statusColor = Colors.black;
        statusText = "Completed";
        break;
      case "pending":
        statusColor = Colors.black;
        statusText = "Pending";
        break;
      default:
        statusColor = Colors.black;
        statusText = isExpanded ? "Close Request" : "Open Request";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Card Header
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                if (expandedSubmissionIndex == index) {
                  expandedSubmissionIndex = null;
                } else {
                  expandedSubmissionIndex = index;
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth < 600 ? 8 : 10,
                10,
                screenWidth < 600 ? 8 : 20,
                10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth < 600 ? 40 : 50,
                    height: screenWidth < 600 ? 40 : 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade300,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _getRandomAvatar(index),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDD6FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                submission.studentName[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth < 600 ? 14 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth < 600 ? 8 : 12),
                  Expanded(
                    child: Text(
                      submission.studentName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth < 600 ? 14 : 16,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 600 ? 8 : 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isExpanded ? 'Close submission' : 'Open submission',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth < 600 ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded) _buildExpandedContent(submission, screenWidth),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(dynamic submission, double screenWidth) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth < 600 ? 12 : 20,
        0,
        screenWidth < 600 ? 12 : 20,
        screenWidth < 600 ? 12 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Student Details Section
          Text(
            "Student Details",
            style: GoogleFonts.poppins(
              fontSize: screenWidth < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.person,
                    size: screenWidth < 600 ? 14 : 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submission.studentName,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth < 600 ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.mail,
                    size: screenWidth < 600 ? 14 : 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submission.studentEmail,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth < 600 ? 12 : 14,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Submission Content Section
          Text(
            "Submission Content",
            style: GoogleFonts.poppins(
              fontSize: screenWidth < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description,
                size: screenWidth < 600 ? 14 : 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.content,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth < 600 ? 12 : 14,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: ${_getFormattedDate(submission.updatedAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth < 600 ? 10 : 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Submission Link Section
          Text(
            "Submission Link",
            style: GoogleFonts.poppins(
              fontSize: screenWidth < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.link,
                size: screenWidth < 600 ? 14 : 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.submissionLink?.toString() ??
                          'No submission link provided',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth < 600 ? 12 : 14,
                        color:
                            submission.submissionLink != null
                                ? Colors.black
                                : Colors.black54,
                        fontStyle:
                            submission.submissionLink == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                      ),
                    ),
                    if (submission.submissionLink != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: screenWidth < 600 ? double.infinity : 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () async {
                            final Uri url = Uri.parse(
                              submission.submissionLink.toString(),
                            );
                            try {
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not open link: ${submission.submissionLink}',
                                      ),
                                      backgroundColor: Colors.red[400],
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error opening link: $e'),
                                    backgroundColor: Colors.red[400],
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            "Open Link",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth < 600 ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
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
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BreadCrumb(courseName: navProvider.selectedCourseName!),
              Consumer<SuperAdminProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 150,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 12, 201, 70),
                        ),
                      ),
                    );
                  }
              
                  final submissions =
                      provider.getSubmissionsByAssignmentId(widget.assignmentId) ??
                      [];
              
                  final filteredSubmissions =
                      submissions.where((submission) {
                        final studentName = submission.studentName.toLowerCase();
                        final studentEmail = submission.studentEmail.toLowerCase();
                        return searchQuery.isEmpty ||
                            studentName.contains(searchQuery) ||
                            studentEmail.contains(searchQuery);
                      }).toList();
              
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'View assignment submission',
                        style: GoogleFonts.poppins(
                          fontSize: TextStyles.headingLarge(context),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'View the submitted assignments here.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
              
                      // Search Bar and Count
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
                                  contentPadding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.toLowerCase();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${filteredSubmissions.length} Submissions',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
              
                      // Submissions List or Empty State
                      if (submissions.isEmpty)
                        SizedBox(
                          height: 400,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No submissions found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children:
                              filteredSubmissions.map((submission) {
                                final index = submissions.indexOf(submission);
                                return _buildSubmissionCard(
                                  submission,
                                  index,
                                  screenWidth,
                                );
                              }).toList(),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
