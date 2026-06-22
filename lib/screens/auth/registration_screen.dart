import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../student/student_dashboard_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int? _selectedSemester;

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  final List<int> _semesters = List.generate(12, (index) => index + 1);

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _batchController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text('Please select semester'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerStudent(
        name: _nameController.text,
        studentId: _studentIdController.text,
        email: _emailController.text,
        password: _passwordController.text,
        batch: _batchController.text,
        semester: _selectedSemester!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text('Registration successful'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text(error.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Image.asset(
          AppAssets.luLogo,
          width: isMobile ? 92 : 110,
          height: isMobile ? 92 : 110,
        ),
        const SizedBox(height: 18),
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navyText,
            fontSize: isMobile ? 28 : 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Register as a student to apply for admit card',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semester',
          style: TextStyle(
            color: AppColors.navyText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedSemester,
          validator: Validators.semester,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Select semester',
            hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.dangerRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
                width: 1.5,
              ),
            ),
          ),
          items: _semesters.map((semester) {
            return DropdownMenuItem<int>(
              value: semester,
              child: Text('Semester $semester'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSemester = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Name',
            hintText: 'Enter your full name',
            controller: _nameController,
            validator: (value) => Validators.requiredField(value, 'Name'),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Student ID',
            hintText: 'Enter your student ID',
            controller: _studentIdController,
            validator: Validators.studentId,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Email',
            hintText: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 18),
          isMobile
              ? Column(
                  children: [
                    CustomTextField(
                      label: 'Batch',
                      hintText: 'Enter your batch',
                      controller: _batchController,
                      validator: Validators.batch,
                    ),
                    const SizedBox(height: 18),
                    _buildSemesterDropdown(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Batch',
                        hintText: 'Enter your batch',
                        controller: _batchController,
                        validator: Validators.batch,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(child: _buildSemesterDropdown()),
                  ],
                ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Password',
            hintText: 'Create a strong password',
            controller: _passwordController,
            obscureText: _isPasswordHidden,
            validator: Validators.password,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
              icon: Icon(
                _isPasswordHidden ? Iconsax.eye_slash : Iconsax.eye,
                color: AppColors.hintText,
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Confirm Password',
            hintText: 'Re-enter your password',
            controller: _confirmPasswordController,
            obscureText: _isConfirmPasswordHidden,
            validator: _confirmPasswordValidator,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                });
              },
              icon: Icon(
                _isConfirmPasswordHidden ? Iconsax.eye_slash : Iconsax.eye,
                color: AppColors.hintText,
              ),
            ),
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'Register',
            onPressed: _registerStudent,
            isLoading: _isLoading,
            backgroundColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Login Now',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? 520 : 760,
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    64,
              ),
              child: Center(
                child: Card(
                  elevation: 18,
                  shadowColor: Colors.black.withOpacity(0.12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 54,
                      vertical: isMobile ? 34 : 46,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(isMobile),
                        const SizedBox(height: 34),
                        _buildRegistrationForm(isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
