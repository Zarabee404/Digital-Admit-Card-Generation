import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updatePassword(_passwordController.text);

      await _authService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text('Password changed successfully. Please login again.'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                maxWidth: isMobile ? 520 : 620,
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
                      vertical: isMobile ? 36 : 52,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.luLogo,
                            width: isMobile ? 95 : 115,
                            height: isMobile ? 95 : 115,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Reset Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.navyText,
                              fontSize: isMobile ? 28 : 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create a new password for your account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.hintText,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 34),
                          CustomTextField(
                            label: 'New Password',
                            hintText: 'Enter new password',
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
                                _isPasswordHidden
                                    ? Iconsax.eye_slash
                                    : Iconsax.eye,
                                color: AppColors.hintText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Confirm Password',
                            hintText: 'Re-enter new password',
                            controller: _confirmPasswordController,
                            obscureText: _isConfirmPasswordHidden,
                            validator: _confirmPasswordValidator,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordHidden =
                                      !_isConfirmPasswordHidden;
                                });
                              },
                              icon: Icon(
                                _isConfirmPasswordHidden
                                    ? Iconsax.eye_slash
                                    : Iconsax.eye,
                                color: AppColors.hintText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: 'Reset',
                            onPressed: _isLoading ? null : _resetPassword,
                            isLoading: _isLoading,
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 22),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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
