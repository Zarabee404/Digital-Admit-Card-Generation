import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/role_guard_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final RoleGuardService _roleGuardService = RoleGuardService();

  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final role = await _roleGuardService.getCurrentUserRole();

    if (!mounted) return;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
      return;
    }

    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentDashboardScreen(),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}