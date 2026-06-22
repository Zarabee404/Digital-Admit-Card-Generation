import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../admin/admin_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final role = await _authService.loginAndGetRole(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        );
      }
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

  void _showForgotPasswordDialog() {
    _forgotEmailController.clear();

    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, dialogSetState) {
            Future<void> sendResetLink() async {
              if (!_forgotPasswordFormKey.currentState!.validate()) return;

              dialogSetState(() {
                isDialogLoading = true;
              });

              try {
                await _authService.resetPasswordForEmail(
                  _forgotEmailController.text,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.successGreen,
                    content: Text(
                      'Password reset link has been sent to your email.',
                    ),
                  ),
                );
              } catch (error) {
                if (!mounted) return;

                dialogSetState(() {
                  isDialogLoading = false;
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

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Reset Password',
                style: TextStyle(
                  color: AppColors.navyText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Form(
                key: _forgotPasswordFormKey,
                child: SizedBox(
                  width: 420,
                  child: CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your registered email',
                    controller: _forgotEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              actions: [
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.hintText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isDialogLoading ? null : sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isDialogLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Link',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLeftSection(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 520,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 54,
        vertical: isMobile ? 38 : 58,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(28),
          bottomLeft: Radius.circular(isMobile ? 0 : 28),
          topRight: Radius.circular(isMobile ? 28 : 0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.luLogo,
            width: isMobile ? 130 : 165,
            height: isMobile ? 130 : 165,
          ),
          const SizedBox(height: 28),
          Text(
            'Digital Admit Card\nGeneration System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 25 : 34,
              fontWeight: FontWeight.w800,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Leading University',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isMobile) {
    final formContainer = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 58,
        vertical: isMobile ? 36 : 54,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(isMobile ? 0 : 28),
          bottomRight: const Radius.circular(28),
          bottomLeft: Radius.circular(isMobile ? 28 : 0),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: AppColors.navyText,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue to your account',
                style: TextStyle(
                  color: AppColors.hintText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 34),
              CustomTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                validator: (value) =>
                    Validators.requiredField(value, 'Password'),
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Login',
                onPressed: _isLoading ? null : _login,
                isLoading: _isLoading,
                backgroundColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 26),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.hintText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register Now',
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
        ),
      ),
    );

    if (isMobile) {
      return formContainer;
    }

    return Expanded(child: formContainer);
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
                maxWidth: isMobile ? 520 : 1080,
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
                  child: isMobile
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLeftSection(true),
                            _buildLoginForm(true),
                          ],
                        )
                      : SizedBox(
                          height: 650,
                          child: Row(
                            children: [
                              _buildLeftSection(false),
                              _buildLoginForm(false),
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
