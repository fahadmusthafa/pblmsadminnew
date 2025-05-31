import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
 // Add this import
import 'package:pb_lms/utilities/nav_data.dart';
import 'package:pb_lms/views/login_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _handleLogout(BuildContext context) {
    Provider.of<AdminAuthProvider>(context, listen: false).Adminlogout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    bool isLargeScreen = screenWidth > 600 && screenHeight > 600;
    return Scaffold(
      appBar:
          screenWidth < 600 || screenHeight < 600
              ? AppBar(
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Image.asset(
                      'assets/portfolixlms.png',
                      width: 127,
                      height: 56,
                    ),
                  ),
                ],
              )
              : null,
      drawer:
          screenWidth < 600 || screenHeight < 600
              ? Drawer(
                width: 285,
                child: SideNav(
                  selectedIndex: navProvider.selectedIndex,
                  onItemTap: navProvider.setIndex,
                  onLogout: () => _handleLogout(context),
                ),
              )
              : null,
      body: Row(
        children: [
          if (isLargeScreen)
            SideNav(
              selectedIndex: navProvider.selectedIndex,
              onItemTap: navProvider.setIndex,
              onLogout: () => _handleLogout(context),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child:
                  pages[navProvider.selectedIndex], // This line stays the same
            ),
          ),
        ],
      ),
    );
  }
}

class SideNav extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback onLogout;
  const SideNav({
    super.key, 
    this.selectedIndex, 
    required this.onItemTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isLargeScreen = screenWidth > 600 && screenHeight > 600;

    return SingleChildScrollView(
      child: ConstrainedBox(
        // Force the Column to be at least screen-height tall
        constraints: BoxConstraints(minHeight: screenHeight),
        child: SizedBox(
          width: 285,
          child: Column(
            // Fill parent height so spaceBetween works
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) Top logo
              Padding(
                padding: const EdgeInsets.only(left: 7, top: 20),
                child: Image.asset(
                  'assets/portfolixlms.png',
                  width: 127,
                  height: 56,
                ),
              ),

              if (!isLargeScreen) SizedBox(height: 20),

              // Center nav items (not individually scrollable;
              // the entire view scrolls as needed)
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    navData.map((nav) {
                      return InkWell(
                        // onTap: () => onItemTap(nav.index),
                        onTap: () {
                          onItemTap(nav.index);
                          if (!isLargeScreen) {
                            Navigator.pop(context);
                          }
                        },
                        child: _NavItem(
                          icon: nav.image,
                          label: nav.label,
                          isSelected: selectedIndex == nav.index,
                        ),
                      );
                    }).toList(),
              ),

              // Bottom super‑admin & logout
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLargeScreen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 224, 224, 224),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color.fromARGB(255, 255, 199, 214),
                                ),
                                child: Image.asset(
                                  'assets/peoples/person_7.png',
                                  width: 49,
                                  height: 49,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Super Admin',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 187,
                                  child: Text(
                                    'superAdmin@gmail.com',
                                    style: GoogleFonts.poppins(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!isLargeScreen) SizedBox(height: 20),
                  // Updated logout button with InkWell
                  InkWell(
                    onTap: onLogout,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/logout.png',
                            height: 18,
                            width: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
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
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
      width: 304,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Opacity(
            opacity: isSelected ? 1 : 0,
            child: Container(
              width: 9,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Image.asset(
            icon,
            height: 18,
            width: 24,
            color: isSelected ? Colors.black : Colors.grey.shade700,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.black : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}