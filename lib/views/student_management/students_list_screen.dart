import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/utilities/constants.dart';
import 'package:provider/provider.dart';

class AdminAllUsersPage extends StatefulWidget {
  const AdminAllUsersPage({
    super.key,
    required this.courseId,
    required this.batchId,
  });

  final int courseId;
  final int batchId;

  @override
  _AdminAllUsersPageState createState() => _AdminAllUsersPageState();
}

class _AdminAllUsersPageState extends State<AdminAllUsersPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<int> studentsInBatch = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      provider.AdminfetchallusersProvider();
      _fetchCurrentBatchStudents();
    });
  }

  Future<void> _fetchCurrentBatchStudents() async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    try {
      await provider.AdminfetchallusersBatchProvider(
        widget.courseId,
        widget.batchId,
      );
      setState(() {
        studentsInBatch =
            provider.students.map((student) => student.studentId).toSet();
      });
    } catch (e) {
      print('Error fetching batch students: $e');
    }
  }

  void _showActionConfirmation({
    required String title,
    required String message,
    required Function() onConfirm,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 235, 235, 235),
            borderRadius: BorderRadius.circular(30),
          ),
          width: screenWidth < 700 ? null : screenWidth * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: (screenWidth < 700)
                        ? double.infinity
                        : (screenWidth * 0.2 - 35),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (screenWidth < 700)
                            ? Colors.redAccent
                            : const Color.fromARGB(255, 12, 201, 70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: (screenWidth < 700)
                          ? () => Navigator.pop(context)
                          : () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                      child: Text(
                        (screenWidth < 700) ? 'Cancel' : 'Confirm',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: (screenWidth < 700)
                        ? double.infinity
                        : (screenWidth * 0.2 - 35),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (screenWidth < 700)
                            ? const Color.fromARGB(255, 12, 201, 70)
                            : Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: (screenWidth < 700)
                          ? () {
                              Navigator.pop(context);
                              onConfirm();
                            }
                          : () => Navigator.pop(context),
                      child: Text(
                        (screenWidth < 700) ? 'Confirm' : 'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _assignUser(int userId) {
    _showActionConfirmation(
      title: 'Add to Batch',
      message: 'Are you sure you want to add this user to the batch?',
      onConfirm: () async {
        final provider = Provider.of<AdminAuthProvider>(context, listen: false);
        try {
          await provider.assignUserToBatchProvider(
            courseId: widget.courseId,
            batchId: widget.batchId,
            userId: userId,
          );
          setState(() {
            studentsInBatch.add(userId);
          });
          _showSnackBar('User added to batch successfully!', isError: false);
        } catch (e) {
          _showSnackBar('Failed to add user: $e', isError: true);
        }
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor:
            isError ? Colors.redAccent : const Color.fromARGB(255, 12, 201, 70),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

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
              // Breadcrumb navigation
              Row(
                children: [
                  GestureDetector(
                    onTap: () => navProvider.navigateBackToStudentManagement(),
                    child: Text(
                      '< Students management',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Text(
                    ' > ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'All Users',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Page title and description
              Text(
                'Students management',
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.headingLarge(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Add students to the batch here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // All Users section title
              Text(
                'All Users',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Search bar and user count - responsive layout
              SizedBox(
                width: double.infinity,
                height: 44,
                child: screenWidth < 600 
                    ? Column(
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
                                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                                contentPadding: const EdgeInsets.only(
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
                        ],
                      )
                    : Row(
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
                                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                                contentPadding: const EdgeInsets.only(
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
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth < 800 ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                screenWidth < 800 
                                    ? '${provider.users.length} users'
                                    : 'Total approved users : ${provider.users.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth < 800 ? 12 : 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              
              // Add spacing for mobile layout
              if (screenWidth < 600) ...[
                const SizedBox(height: 10),
                Container(
                  height: 44,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Total approved users : ${provider.users.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),

              // Users list - responsive design
              provider.users == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 12, 201, 70),
                      ),
                    )
                  : provider.users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.person_2,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: provider.users
                                .where(
                                  (user) =>
                                      user.name.toLowerCase().contains(
                                        searchQuery,
                                      ) ||
                                      user.email.toLowerCase().contains(
                                        searchQuery,
                                      ),
                                )
                                .map((user) {
                                  final bool isInBatch = studentsInBatch.contains(
                                    user.userId,
                                  );

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth < 600 ? 12 : 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: screenWidth < 600
                                        ? _buildMobileUserCard(user, isInBatch)
                                        : _buildDesktopUserRow(user, isInBatch, screenWidth),
                                  );
                                })
                                .toList(),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile layout for user card
  Widget _buildMobileUserCard(dynamic user, bool isInBatch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getAvatarImageForUser(user.userId),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
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
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (user.phoneNumber != null) ...[
                    Icon(
                      CupertinoIcons.phone,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        user.phoneNumber!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isInBatch ? Colors.grey[400]! : Colors.black,
                  width: 1,
                ),
              ),
              child: TextButton(
                onPressed: isInBatch ? null : () => _assignUser(user.userId),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  isInBatch ? 'Added' : 'Add',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isInBatch ? Colors.grey[600] : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopUserRow(dynamic user, bool isInBatch, double screenWidth) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              _getAvatarImageForUser(user.userId),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                children: [
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (screenWidth > 800) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user.phoneNumber != null) ...[
                      Icon(
                        CupertinoIcons.phone,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phoneNumber!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      user.role.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (screenWidth <= 800) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (user.phoneNumber != null) ...[
                      Icon(
                        CupertinoIcons.phone,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phoneNumber!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      user.role.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Add to batch button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isInBatch ? Colors.grey[400]! : Colors.black,
              width: 1,
            ),
          ),
          child: TextButton(
            onPressed: isInBatch ? null : () => _assignUser(user.userId),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 800 ? 12 : 20,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              isInBatch ? 'Added' : (screenWidth < 800 ? 'Add' : 'Add to batch'),
              style: GoogleFonts.poppins(
                fontSize: screenWidth < 800 ? 12 : 14,
                color: isInBatch ? Colors.grey[600] : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getAvatarImageForUser(int userId) {
    final avatarImages = [
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

    return avatarImages[userId % avatarImages.length];
  }
}