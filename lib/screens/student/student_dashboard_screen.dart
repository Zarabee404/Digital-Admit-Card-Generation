import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_colors.dart';
import '../../models/admit_card_request_model.dart';
import '../../models/course_model.dart';
import '../../models/student_model.dart';
import '../../services/admit_card_service.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/student_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/course_table.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/sidebar_drawer.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';
import '../../services/pdf_service.dart';
import '../../services/role_guard_service.dart';
import '../admin/admin_dashboard_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final StudentService _studentService = StudentService();
  final CourseService _courseService = CourseService();
  final AdmitCardService _admitCardService = AdmitCardService();
  final AuthService _authService = AuthService();
  final PdfService _pdfService = PdfService();
  final RoleGuardService _roleGuardService = RoleGuardService();

  StudentModel? _student;
  AdmitCardRequestModel? _currentRequest;

  List<CourseModel> _semesterCourses = [];
  List<CourseModel> _allCourses = [];
  List<CourseModel> _selectedCourses = [];

  CourseModel? _extraSelectedCourse;

  bool _isLoading = true;
  bool _isApplying = false;

  @override
  @override
void initState() {
  super.initState();
  _checkAccessAndLoadData();
}

  Future<void> _checkAccessAndLoadData() async {
  final role = await _roleGuardService.getCurrentUserRole();

  if (!mounted) return;

  if (role == null) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
    return;
  }

  if (role == 'admin') {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardScreen(),
      ),
      (route) => false,
    );
    return;
  }

  if (role == 'student') {
    await _loadDashboardData();
  }
}

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final student = await _studentService.getCurrentStudent();

      if (student == null) {
        await _authService.logout();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );

        return;
      }

      final semesterCourses =
          await _courseService.getCoursesBySemester(student.semester);

      final allCourses = await _courseService.getAllCourses();

      final currentRequest =
          await _admitCardService.getCurrentStudentRequest(
        studentAuthId: student.authUserId,
        semester: student.semester,
      );

      List<CourseModel> selectedCourses = List.from(semesterCourses);

      if (currentRequest != null) {
        selectedCourses =
            await _admitCardService.getCoursesForRequest(currentRequest.id);
      }

      if (!mounted) return;

      setState(() {
        _student = student;
        _semesterCourses = semesterCourses;
        _allCourses = allCourses;
        _selectedCourses = selectedCourses;
        _currentRequest = currentRequest;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text(
            error.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _addExtraCourse() {
    if (_extraSelectedCourse == null) return;

    final alreadyAdded = _selectedCourses.any(
      (course) => course.courseCode == _extraSelectedCourse!.courseCode,
    );

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.pendingOrange,
          content: Text('This course is already added.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedCourses.add(_extraSelectedCourse!);
      _extraSelectedCourse = null;
    });
  }

  void _removeCourse(CourseModel course) {
    final isSemesterCourse = _semesterCourses.any(
      (semesterCourse) => semesterCourse.courseCode == course.courseCode,
    );

    if (isSemesterCourse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.pendingOrange,
          content: Text('Semester offered courses cannot be removed.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedCourses.removeWhere(
        (selectedCourse) => selectedCourse.courseCode == course.courseCode,
      );
    });
  }

  Future<void> _applyForAdmitCard() async {
    final student = _student;

    if (student == null) return;

    if (_currentRequest != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.pendingOrange,
          content: Text('You have already applied for this semester.'),
        ),
      );
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      final request = await _admitCardService.applyForAdmitCard(
        student: student,
        selectedCourses: _selectedCourses,
      );

      if (!mounted) return;

      setState(() {
        _currentRequest = request;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text('Application submitted successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text(
            error.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  Future<void> _downloadAdmitCard() async {
  final student = _student;
  final request = _currentRequest;

  if (student == null || request == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.dangerRed,
        content: Text('Student or request information is missing.'),
      ),
    );
    return;
  }

  if (request.status != 'approved') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.pendingOrange,
        content: Text('Your admit card is not approved yet.'),
      ),
    );
    return;
  }

  try {
    await _pdfService.generateAndDownloadAdmitCard(
      student: student,
      request: request,
      courses: _selectedCourses,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.successGreen,
        content: Text('Admit card downloaded successfully.'),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dangerRed,
        content: Text(
          error.toString().replaceAll('Exception: ', ''),
        ),
      ),
    );
  }
}


  String get _status {
    final request = _currentRequest;

    if (request == null) {
      return 'not_applied';
    }

    return request.status;
  }

  bool get _hasApplied {
    return _currentRequest != null;
  }

  bool get _isApproved {
    return _currentRequest?.status == 'approved';
  }

  List<CourseModel> get _extraCourseOptions {
    return _allCourses.where((course) {
      final alreadyAdded = _selectedCourses.any(
        (selectedCourse) => selectedCourse.courseCode == course.courseCode,
      );

      return !alreadyAdded;
    }).toList();
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Iconsax.menu_1,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Student Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!isMobile)
            Text(
              _student?.name ?? '',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatusCard(bool isMobile) {
    String title;
    String description;
    IconData icon;
    Color iconColor;

    if (_isApproved) {
      title = 'Successful';
      description = 'Your admit card is ready to download.';
      icon = Iconsax.tick_circle;
      iconColor = AppColors.successGreen;
    } else if (_status == 'pending') {
      title = 'Pending';
      description = 'Your application is under admin review.';
      icon = Iconsax.timer_1;
      iconColor = AppColors.pendingOrange;
    } else {
      title = 'Not Applied';
      description = 'You have not applied for your admit card yet.';
      icon = Iconsax.document_upload;
      iconColor = AppColors.primaryBlue;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
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
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(status: _status),
                const SizedBox(height: 18),
                _buildStatusContent(title, description, icon, iconColor),
                if (_isApproved) ...[
                  const SizedBox(height: 22),
                  CustomButton(
                    text: 'Download Admit Card',
                    onPressed: _downloadAdmitCard,
                    backgroundColor: AppColors.successGreen,
                  ),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildStatusContent(
                    title,
                    description,
                    icon,
                    iconColor,
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(status: _status),
                    if (_isApproved) ...[
                      const SizedBox(height: 22),
                      SizedBox(
                        width: 230,
                        child: CustomButton(
                          text: 'Download Admit Card',
                          onPressed: _downloadAdmitCard,
                          backgroundColor: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatusContent(
    String title,
    String description,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navyText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.hintText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.teacher,
            color: AppColors.primaryBlue,
            size: 34,
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Semester Number',
                style: TextStyle(
                  color: AppColors.hintText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_student?.semester ?? ''}',
                style: const TextStyle(
                  color: AppColors.navyText,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraCourseDropdown(bool isDisabled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Course Code',
            style: TextStyle(
              color: AppColors.navyText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<CourseModel>(
                  value: _extraSelectedCourse,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: isDisabled
                        ? 'Course selection disabled after application'
                        : 'Choose extra course',
                    filled: true,
                    fillColor: isDisabled
                        ? Colors.grey.shade100
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  items: _extraCourseOptions.map((course) {
                    return DropdownMenuItem<CourseModel>(
                      value: course,
                      child: Text(
                        '${course.courseCode} - ${course.courseTitle}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          setState(() {
                            _extraSelectedCourse = value;
                          });
                        },
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 110,
                child: CustomButton(
                  text: 'Add',
                  onPressed: isDisabled ? null : _addExtraCourse,
                  backgroundColor: AppColors.primaryBlue,
                  height: 52,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSection() {
    final bool disableApplyButton = _hasApplied || _isApplying;

    String buttonText = 'Apply for Admit Card';

    if (_status == 'pending') {
      buttonText = 'Application Pending';
    } else if (_isApproved) {
      buttonText = 'Application Approved';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instruction',
            style: TextStyle(
              color: AppColors.navyText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Review your offered courses carefully before applying. After submitting your application, you cannot apply again for the same semester.',
            style: TextStyle(
              color: AppColors.hintText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          CustomButton(
            text: buttonText,
            onPressed: disableApplyButton ? null : _applyForAdmitCard,
            isLoading: _isApplying,
            backgroundColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    final bool lockedAfterApplication = _hasApplied;

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 24),
              _buildApplicationStatusCard(isMobile),
              const SizedBox(height: 22),
              _buildSemesterCard(),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Offered Courses',
                      style: TextStyle(
                        color: AppColors.navyText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    CourseTable(
                      courses: _selectedCourses,
                      showRemoveButton: !lockedAfterApplication,
                      onRemove: _removeCourse,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildExtraCourseDropdown(lockedAfterApplication),
              const SizedBox(height: 22),
              _buildInstructionSection(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _student;
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: student == null
          ? null
          : SidebarDrawer(
              student: student,
              onLogout: _logout,
            ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : _buildMainContent(isMobile),
    );
  }
}