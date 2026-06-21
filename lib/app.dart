import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/verification/admit_card_verification_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class DigitalAdmitCardApp extends StatefulWidget {
  const DigitalAdmitCardApp({super.key});

  @override
  State<DigitalAdmitCardApp> createState() => _DigitalAdmitCardAppState();
}

class _DigitalAdmitCardAppState extends State<DigitalAdmitCardApp> {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  Widget? _homeScreen;

  @override
  void initState() {
    super.initState();

    _prepareInitialScreen();
    _listenForDeepLinks();
    _listenForPasswordRecovery();
  }

  Future<void> _prepareInitialScreen() async {
    try {
      final initialUri = await _appLinks.getInitialLink();

      if (!mounted) return;

      if (initialUri != null && _isVerificationLink(initialUri)) {
        final requestId = _extractRequestId(initialUri);

        setState(() {
          _homeScreen = AdmitCardVerificationScreen(
            requestId: requestId,
          );
        });
        return;
      }

      setState(() {
        _homeScreen = const SplashScreen();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _homeScreen = const SplashScreen();
      });
    }
  }

  void _listenForPasswordRecovery() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          appNavigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ResetPasswordScreen(),
            ),
            (route) => false,
          );
        }
      },
    );
  }

  Future<void> _listenForDeepLinks() async {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingLink(uri);
      },
      onError: (_) {},
    );
  }

  bool _isVerificationLink(Uri uri) {
  return uri.scheme == 'digitaladmitcard' && uri.host == 'verify';
}

  String _extractRequestId(Uri uri) {
  if (uri.scheme == 'digitaladmitcard' &&
      uri.host == 'verify' &&
      uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.first.trim();
  }

  return '';
}

  void _handleIncomingLink(Uri uri) {
  debugPrint('Incoming link: $uri');
  debugPrint('Scheme: ${uri.scheme}');
  debugPrint('Host: ${uri.host}');
  debugPrint('Path segments: ${uri.pathSegments}');

  if (_isVerificationLink(uri)) {
    final requestId = _extractRequestId(uri);

    debugPrint('Extracted request ID: $requestId');

    if (requestId.isEmpty) {
      debugPrint('Request ID is empty');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AdmitCardVerificationScreen(
            requestId: requestId,
          ),
        ),
        (route) => false,
      );
    });

    return;
  }

  debugPrint('Not a verification link');
}

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    if (_isVerificationLink(uri)) {
      final requestId = _extractRequestId(uri);

      return MaterialPageRoute(
        builder: (_) => AdmitCardVerificationScreen(
          requestId: requestId,
        ),
      );
    }

    return MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Digital Admit Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: _homeScreen ??
          const Scaffold(
            backgroundColor: AppColors.darkBlue,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      onGenerateRoute: _onGenerateRoute,
    );
  }
}