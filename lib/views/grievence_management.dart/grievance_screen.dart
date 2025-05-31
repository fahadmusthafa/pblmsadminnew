import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pb_lms/models/fahad/model.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:pb_lms/utilities/constants.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class GrievanceScreen extends StatefulWidget {
  const GrievanceScreen({super.key});

  @override
  _GrievanceScreenState createState() => _GrievanceScreenState();
}

class _GrievanceScreenState extends State<GrievanceScreen> {
  int? expandedLeaveId;
  String selectedTab = "Pending";
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  final Random _random = Random();

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
    Future.delayed(Duration.zero, () {
      Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).Adminfetchleaveprovider();
    });
  }

  String _getRandomAvatar() {
    return avatarImages[_random.nextInt(avatarImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final leaveProvider = Provider.of<AdminAuthProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    List<LeaveRequest> filteredLeaves = leaveProvider.leave.where((leave) {
      bool matchesTab;
      switch (selectedTab) {
        case "Pending":
          matchesTab = leave.status == "pending";
          break;
        case "Approved":
          matchesTab = leave.status == "approved";
          break;
        case "Rejected":
          matchesTab = leave.status == "rejected";
          break;
        default:
          matchesTab = false;
      }

      bool matchesSearch = searchQuery.isEmpty ||
          leave.student.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

      return matchesTab && matchesSearch;
    }).toList();

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
              // Header Section
              Text(
                'Grievance management',
                style: GoogleFonts.poppins(
                  fontSize: TextStyles.headingLarge(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Approve or reject users leave request here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              _buildTabSection(filteredLeaves.length, screenWidth),
              const SizedBox(height: 20),

              // Search Bar
              _buildSearchBar(screenWidth),
              const SizedBox(height: 20),

              // Leave Requests List
              _buildLeaveRequestsList(filteredLeaves, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildTabSection(int requestCount, double screenWidth) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: screenWidth < 600
          ? Row(
              children: [
                Expanded(
                  child: _buildTabButton("Pending", selectedTab == "Pending", screenWidth),
                ),
                Expanded(
                  child: _buildTabButton("Approved", selectedTab == "Approved", screenWidth),
                ),
                Expanded(
                  child: _buildTabButton("Rejected", selectedTab == "Rejected", screenWidth),
                ),
              ],
            )
          : screenWidth < 1000
              ? Container(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.9,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton("Pending", selectedTab == "Pending", screenWidth),
                      ),
                      Expanded(
                        child: _buildTabButton("Approved", selectedTab == "Approved", screenWidth),
                      ),
                      Expanded(
                        child: _buildTabButton("Rejected", selectedTab == "Rejected", screenWidth),
                      ),
                    ],
                  ),
                )
              : 
              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabButton("Pending", selectedTab == "Pending", screenWidth),
                    _buildTabButton("Approved", selectedTab == "Approved", screenWidth),
                    _buildTabButton("Rejected", selectedTab == "Rejected", screenWidth),
                  ],
                ),
    ),
  );
}

Widget _buildTabButton(String title, bool isSelected, double screenWidth) {
  double horizontalPadding;
  if (screenWidth < 480) {
    horizontalPadding = 8;
  } else if (screenWidth < 600) {
    horizontalPadding = 12;
  } else if (screenWidth < 1000) {
    horizontalPadding = 16;
  } else {
    horizontalPadding = 24;
  }

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedTab = title;
        expandedLeaveId = null;
      });
    },
    child: Container(
      margin: const EdgeInsets.all(4.0),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromARGB(255, 60, 60, 60)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: screenWidth < 600 ? 14 : 16,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    ),
  );
}
  Widget _buildSearchBar(double screenWidth) {
    final leaveProvider = Provider.of<AdminAuthProvider>(context);

    int requestCount;
    switch (selectedTab) {
      case "Pending":
        requestCount = leaveProvider.leave
            .where((leave) => leave.status == "pending")
            .length;
        break;
      case "Approved":
        requestCount = leaveProvider.leave
            .where((leave) => leave.status == "approved")
            .length;
        break;
      case "Rejected":
        requestCount = leaveProvider.leave
            .where((leave) => leave.status == "rejected")
            .length;
        break;
      default:
        requestCount = 0;
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
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
                hintStyle: GoogleFonts.poppins(),
                contentPadding: EdgeInsets.only(top: 10, bottom: 10),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            height: 44,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? 8 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                screenWidth < 600 
                    ? "$requestCount"
                    : "$requestCount Leave requests",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth < 600 ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestsList(List<LeaveRequest> filteredLeaves, double screenWidth) {
    if (filteredLeaves.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.black26),
              const SizedBox(height: 16),
              Text(
                "No ${selectedTab.toLowerCase()} leave requests available",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredLeaves.map((leave) {
        final bool isExpanded = expandedLeaveId == leave.leaveId;
        return _buildLeaveRequestCard(leave, isExpanded, screenWidth);
      }).toList(),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest leave, bool isExpanded, double screenWidth) {
    Color statusColor;
    String statusText;

    switch (leave.status) {
      case "approved":
        statusColor = Colors.black;
        statusText = "Approved";
        break;
      case "rejected":
        statusColor = Colors.black;
        statusText = "Rejected";
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
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                if (expandedLeaveId == leave.leaveId) {
                  expandedLeaveId = null;
                } else {
                  expandedLeaveId = leave.leaveId;
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
                        _getRandomAvatar(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: screenWidth < 600 ? 20 : 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth < 600 ? 8 : 12),
                  Expanded(
                    child: Text(
                      leave.student.name,
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
                      statusText,
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

          if (isExpanded) _buildExpandedContent(leave, screenWidth),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(LeaveRequest leave, double screenWidth) {
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
                      leave.student.name,
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
                      leave.student.email,
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

          // Leave Details Section
          Text(
            "Leave Details",
            style: GoogleFonts.poppins(
              fontSize: screenWidth < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Leave Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today,
                size: screenWidth < 600 ? 14 : 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Requested date : ${DateFormat('d\'${_getOrdinalSuffix(leave.leaveDate.day)}\' MMMM yyyy').format(leave.leaveDate)}",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth < 600 ? 12 : 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Leave Reason
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
                child: Text(
                  "Reason for leave: ${leave.reason}",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth < 600 ? 12 : 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          // Action Buttons (only for pending requests)
          if (leave.status == "pending") ...[
            const SizedBox(height: 24),
            screenWidth < 600
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 12, 201, 70),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final provider = Provider.of<AdminAuthProvider>(
                              context,
                              listen: false,
                            );
                            await provider.adminApproveleaveprovider(
                              leaveId: leave.leaveId,
                              status: "approved",
                            );
                            provider.Adminfetchleaveprovider();
                            setState(() {
                              expandedLeaveId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Leave request approved",
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color.fromARGB(255, 12, 201, 70),
                              ),
                            );
                          },
                          child: Text(
                            "Approve",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final provider = Provider.of<AdminAuthProvider>(
                              context,
                              listen: false,
                            );
                            await provider.adminApproveleaveprovider(
                              leaveId: leave.leaveId,
                              status: "rejected",
                            );
                            provider.Adminfetchleaveprovider();
                            setState(() {
                              expandedLeaveId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Leave request rejected",
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: Text(
                            "Reject",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 12, 201, 70),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final provider = Provider.of<AdminAuthProvider>(
                              context,
                              listen: false,
                            );
                            await provider.adminApproveleaveprovider(
                              leaveId: leave.leaveId,
                              status: "approved",
                            );
                            provider.Adminfetchleaveprovider();
                            setState(() {
                              expandedLeaveId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Leave request approved",
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color.fromARGB(255, 12, 201, 70),
                              ),
                            );
                          },
                          child: Text(
                            "Approve",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final provider = Provider.of<AdminAuthProvider>(
                              context,
                              listen: false,
                            );
                            await provider.adminApproveleaveprovider(
                              leaveId: leave.leaveId,
                              status: "rejected",
                            );
                            provider.Adminfetchleaveprovider();
                            setState(() {
                              expandedLeaveId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Leave request rejected",
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: Text(
                            "Reject",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ],
      ),
    );
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}