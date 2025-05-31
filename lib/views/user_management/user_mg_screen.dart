import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/user_manager_provider/getall_user_provider.dart';
//import 'package:pb_lms/providers/admin_provider.dart'; // Add this import for AdminProvider
import 'package:pb_lms/utilities/constants.dart';
import 'package:pb_lms/views/user_management/user_attendence.dart';
import 'package:provider/provider.dart';

class UserMgScreen extends StatefulWidget {
  const UserMgScreen({super.key});

  @override
  State<UserMgScreen> createState() => _UserMgScreenState();
}

class _UserMgScreenState extends State<UserMgScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();

    Future.microtask(() async {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      await provider.AdminfetchallusersProvider();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getApprovedUsers(List<dynamic>? allUsers) {
    if (allUsers == null) return [];
    return allUsers.where((user) => user.approved == true).toList();
  }

  List<dynamic> _getUnapprovedUsers(List<dynamic>? allUsers) {
    if (allUsers == null) return [];
    return allUsers.where((user) => user.approved == false).toList();
  }

  // Show confirmation dialog before performing actions
  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                cancelText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? Colors.red : const Color.fromRGBO(45, 45, 45, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                confirmText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _handleApproval(int userId, String role, String action, String userName) async {
    bool shouldProceed = false;
    
    // Show appropriate confirmation dialog based on action
    switch (action) {
      case 'approve':
        shouldProceed = await _showConfirmationDialog(
          title: 'Approve User',
          content: 'Are you sure you want to approve "$userName"? This will grant them access to the system.',
          confirmText: 'Approve',
          cancelText: 'Cancel',
        );
        break;
      case 'reject':
        // Check if it's a delete or reject action based on user status
        final isDelete = _getApprovedUsers(Provider.of<AdminProvider>(context, listen: false).users ?? [])
            .any((user) => user.userId == userId);
        
        shouldProceed = await _showConfirmationDialog(
          title: isDelete ? 'Delete User' : 'Reject User',
          content: isDelete 
              ? 'Are you sure you want to delete "$userName"? This action cannot be undone.'
              : 'Are you sure you want to reject "$userName"? They will not be granted access to the system.',
          confirmText: isDelete ? 'Delete' : 'Reject',
          cancelText: 'Cancel',
          isDestructive: true,
        );
        break;
    }

    if (!shouldProceed) return;

    final provider = Provider.of<AdminProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.adminApproveUserprovider(
        userId: userId,
        role: role,
        action: action,
      );

      if (mounted) {
        await provider.AdminfetchallusersProvider();

        _showSnackBar(
          action == 'approve'
              ? 'User approved successfully'
              : 'User deleted successfully',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final query = searchQuery.toLowerCase();
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final phoneNumber = (user.phoneNumber?.toLowerCase() ?? '');
      final registrationId = (user.registrationId?.toLowerCase() ?? '');

      return name.contains(query) ||
          email.contains(query) ||
          phoneNumber.contains(query) ||
          registrationId.contains(query);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
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

  Widget _buildResponsiveUserRow(
    dynamic user,
    String listType,
    double screenWidth,
  ) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return InkWell(
      onTap: listType == 'unapproved'
          ? null
          : () {
              navProvider.navigateToAttendance(
                user.userId,
                user.name,
                user.email,
                user.phoneNumber,
              );
            },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: isMobile
            ? _buildMobileUserCard(user, listType, screenWidth)
            : _buildDesktopUserRow(user, listType, screenWidth),
      ),
    );
  }

  Widget _buildMobileUserCard(
    dynamic user,
    String listType,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _getAvatarImageForUser(user.userId),
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : "?",
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
            // User details
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
                  const SizedBox(height: 2),
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
            // Arrow for approved users
            if (listType == 'approved')
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: 14,
              ),
          ],
        ),
        if (user.phoneNumber != null && user.phoneNumber.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.phone,
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                user.phoneNumber!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.role.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        // Action buttons
        Row(
          children: [
            if (listType == 'unapproved') ...[
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: TextButton(
                    onPressed: () => _handleApproval(
                      user.userId,
                      user.role,
                      'approve',
                      user.name,
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Approve',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: TextButton(
                  onPressed: () => _handleApproval(user.userId, user.role, 'reject', user.name),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    listType == 'unapproved' ? 'Reject' : 'Delete',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopUserRow(
    dynamic user,
    String listType,
    double screenWidth,
  ) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Row(
      children: [
        // Avatar with image fallback
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
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : "?",
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
        // User details
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
                    if (user.phoneNumber != null &&
                        user.phoneNumber.isNotEmpty) ...[
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
                    if (user.phoneNumber != null &&
                        user.phoneNumber.isNotEmpty) ...[
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
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (listType == 'unapproved') ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: TextButton(
                  onPressed: () => _handleApproval(
                    user.userId,
                    user.role,
                    'approve',
                    user.name,
                  ),
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
                    screenWidth < 800 ? 'Approve' : 'Approve User',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth < 800 ? 12 : 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: TextButton(
                onPressed: () => _handleApproval(user.userId, user.role, 'reject', user.name),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 800 ? 12 : 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: listType == 'unapproved'
                    ? Text(
                        screenWidth < 800 ? 'Reject' : 'Reject User',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth < 800 ? 12 : 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (screenWidth > 800) ...[
                            const SizedBox(width: 4),
                            Text(
                              'Delete User',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            if (listType == 'approved') ...[
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: 16,
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allUsersProvider = Provider.of<AdminProvider>(context);
    final allUsers = allUsersProvider.users ?? [];
    final screenWidth = MediaQuery.sizeOf(context).width;

    final approvedUsers = _getApprovedUsers(allUsers);
    final unapprovedUsers = _getUnapprovedUsers(allUsers);
    final navProvider = Provider.of<NavigationProvider>(context);

    if (navProvider.isViewingAttendance) {
      return UserAttendence();
    }

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: screenWidth < 600 ? 16 : 20,
          top: screenWidth < 600 ? 40 : 55,
          right: screenWidth < 600 ? 16 : 20,
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
                'User Management',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth < 600 ? 20 : TextStyles.headingLarge(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Approve or reject users here..',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.w300,
                  color: const Color.fromRGBO(45, 45, 45, 1),
                ),
              ),
              const SizedBox(height: 20),
              // Responsive TabBar
              Center(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: screenWidth < 600 ? double.infinity : 528,
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color.fromRGBO(45, 45, 45, 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth < 600 ? 12 : 14,
                      ),
                      unselectedLabelStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: screenWidth < 600 ? 11 : 13,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicatorPadding: const EdgeInsets.all(4),
                      tabs: [
                        Tab(text: screenWidth < 600 ? 'Approved' : 'Approved Users'),
                        Tab(text: screenWidth < 600 ? 'Pending' : 'Pending Approvals'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Responsive Search Bar
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                : null,
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Responsive TabBarView with constrained height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(
                      approvedUsers,
                      allUsersProvider.isLoading,
                      'approved',
                    ),
                    _buildUserList(
                      unapprovedUsers,
                      allUsersProvider.isLoading,
                      'unapproved',
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

  Widget _buildUserList(List<dynamic> users, bool isLoading, String listType) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              listType == 'approved'
                  ? 'No approved users available'
                  : 'No pending approvals available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final filteredUsers = _filterUsers(users);
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(listType);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1,
          color: Colors.grey[200],
          indent: screenWidth < 600 ? 57 : 82, // Adjust based on avatar size
          endIndent: 16,
        ),
        padding: const EdgeInsets.all(0),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildResponsiveUserRow(user, listType, screenWidth);
        },
      ),
    );
  }

  Widget _buildEmptyState(String listType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? listType == 'unapproved'
                    ? 'No pending approvals'
                    : 'No approved users found'
                : 'No matching users found',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}