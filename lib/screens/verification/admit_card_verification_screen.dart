import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../models/admit_card_request_model.dart';
import '../../models/course_model.dart';
import '../../services/admit_card_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/course_table.dart';

class AdmitCardVerificationScreen extends StatefulWidget {
  final String requestId;

  const AdmitCardVerificationScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<AdmitCardVerificationScreen> createState() =>
      _AdmitCardVerificationScreenState();
}

class _AdmitCardVerificationScreenState
    extends State<AdmitCardVerificationScreen> {
  final AdmitCardService _admitCardService = AdmitCardService();

  AdmitCardRequestModel? _request;
  List<CourseModel> _courses = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyAdmitCard();
  }

  Future<void> _verifyAdmitCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.requestId.trim().isEmpty) {
        throw Exception('Invalid QR code.');
      }

      final request = await _admitCardService.verifyAdmitCard(
        widget.requestId.trim(),
      );

      if (request == null) {
        throw Exception('Invalid Admit Card. No record found.');
      }

      if (request.status != 'approved') {
        throw Exception('This admit card is not approved.');
      }

      final courses = await _admitCardService.getVerificationCourses(
        request.id,
      );

      if (!mounted) return;

      setState(() {
        _request = request;
        _courses = courses;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildVerifiedHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Image.asset(
            AppAssets.luLogo,
            width: isMobile ? 82 : 100,
            height: isMobile ? 82 : 100,
          ),
          const SizedBox(height: 18),
          Icon(
            Iconsax.tick_circle,
            color: AppColors.successGreen,
            size: isMobile ? 54 : 68,
          ),
          const SizedBox(height: 14),
          Text(
            'Admit Card Verified',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 25 : 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This admit card exists in the university database and is approved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        color: AppColors.dangerRed,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Image.asset(
            AppAssets.luLogo,
            width: isMobile ? 82 : 100,
            height: isMobile ? 82 : 100,
          ),
          const SizedBox(height: 18),
          Icon(
            Iconsax.close_circle,
            color: Colors.white,
            size: isMobile ? 54 : 68,
          ),
          const SizedBox(height: 14),
          Text(
            'Verification Failed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 25 : 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Invalid Admit Card.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final request = _request;

    if (request == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow('Student Name', request.studentName),
          _divider(),
          _infoRow('Student ID', request.studentId),
          _divider(),
          _infoRow('Batch', request.batch),
          _divider(),
          _infoRow('Semester', request.semester.toString()),
          _divider(),
          _infoRow('Status', 'Approved'),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.hintText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.navyText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: AppColors.borderColor.withOpacity(0.8),
      height: 20,
    );
  }

  Widget _buildCoursesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Approved Courses',
            style: TextStyle(
              color: AppColors.navyText,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          CourseTable(
            courses: _courses,
            showRemoveButton: false,
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedContent(bool isMobile) {
    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              _buildVerifiedHeader(isMobile),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildCoursesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent(bool isMobile) {
    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              _buildInvalidHeader(isMobile),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: const Text(
                  'Please contact the exam controller or university admin if you believe this is a mistake.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : _errorMessage == null
              ? _buildVerifiedContent(isMobile)
              : _buildErrorContent(isMobile),
    );
  }
}