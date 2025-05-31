import 'package:flutter/material.dart';
import 'package:pb_lms/providers/super_admin_provider.dart';
import 'package:pb_lms/utilities/token_manager.dart';
import 'package:pb_lms/views/home_screen.dart';
import 'package:pb_lms/views/login_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _splashScreeLoading();
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
  }

  Future<void> _splashScreeLoading() async {
    Future.delayed(Duration(seconds: 3), () async {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/green_pattern2.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Image.asset(
            'assets/portfolixwhite.png',
            fit: BoxFit.contain,
            width: screenWidth < 600 ? screenWidth * 0.4 : screenWidth * 0.2,
          ),
        ),
      ),
    );
  }
}
