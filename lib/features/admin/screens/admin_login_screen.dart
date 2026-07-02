import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isButtonPressed = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Orchestrated Staggered Animations
  late AnimationController _animationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  // Design Tokens / Colors
  static const Color colorPrimary = Color(0xff1976D2);
  static const Color colorPrimaryDark = Color(0xff1565C0);
  static const Color colorBg = Color(0xffF8FAFC);
  static const Color colorField = Color(0xffF4F6F8);
  static const Color colorText = Color(0xff1F2937);
  static const Color colorSubtitle = Color(0xff6B7280);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _cardSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Structural lock preventing concurrent parallel dispatch streams
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        _emailController.clear();
        _passwordController.clear();
      }

      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AdminDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No admin found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      if (mounted) {
        _showCustomErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showCustomErrorDialog("An unexpected error occurred.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCustomErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: colorSubtitle,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    // Web/Desktop standard optimization factor
    final double contentWidth = screenWidth > 600 ? 480 : screenWidth;
    final bool isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: colorBg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Ambient background layout graphics
            Positioned(
              top: -screenHeight * 0.1,
              right: -screenWidth * 0.15,
              child: Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.lightBlue.shade100.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -screenHeight * 0.15,
              left: -screenWidth * 0.2,
              child: Container(
                width: screenWidth * 0.7,
                height: screenWidth * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.lightBlue.shade100.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Interface Tree Container
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth * 0.06).clamp(24.0, 40.0),
                  ),
                  child: Container(
                    width: contentWidth,
                    alignment: Alignment.center,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.02),

                          // Segment 1: Animated Hero Transparent Logo Core Component
                          FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'service_hub_logo',
                                  child: Image.asset(
                                    'assets/images/servicehub_logo.png',
                                    width: isDesktop ? 100 : 90,
                                    height: isDesktop ? 100 : 90,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Clean fallback layout structure if asset isn't mounted
                                      return Icon(
                                        Icons.layers_rounded,
                                        size: isDesktop ? 60 : 54,
                                        color: colorPrimary,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                    fontSize:
                                        (screenWidth * 0.065).clamp(24.0, 30.0),
                                    fontWeight: FontWeight.bold,
                                    color: colorText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Admin Portal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Sign in to continue managing Service Hub",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: colorSubtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Segment 2: Custom Modernized Sliding Login Card Container
                          SlideTransition(
                            position: _cardSlideAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F1E293B),
                                    blurRadius: 24,
                                    offset: Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Color(0x0A1E293B),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildEmailInput(),
                                  const SizedBox(height: 20),
                                  _buildPasswordInput(),

                                  // Hiding "Forgot Password" cleanly until the module is ready.
                                  // To enable, simply wrap this in a padding container and provide logic.
                                  /*
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isLoading ? null : () {},
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 4),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: colorPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  */

                                  const SizedBox(height: 24),

                                  // Segment 3: Fading CTA Interaction Element
                                  FadeTransition(
                                    opacity: _buttonFadeAnimation,
                                    child: _buildAnimatedLoginButton(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          // Brand Footer Section
                          const SizedBox(
                            width: 120,
                            child: Divider(
                                color: Color(0xffE2E8F0), thickness: 1.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "© 2026 Service Hub",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorSubtitle,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Version 1.0.0",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: colorSubtitle,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Admin Email",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colorText),
        ),
        const SizedBox(height: 8),
        AutofillGroup(
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autofocus: kIsWeb ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux,
            enabled: !_isLoading,
            style: const TextStyle(color: colorText, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined,
                  color: colorSubtitle, size: 22),
              hintText: "admin@servicehub.com",
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              filled: true,
              fillColor: colorField,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: colorPrimary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
            validator: (email) {
              if (email == null || email.trim().isEmpty) {
                return "Email cannot be empty";
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
                return "Enter a valid email address";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colorText),
        ),
        const SizedBox(height: 8),
        AutofillGroup(
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            enabled: !_isLoading,
            style: const TextStyle(color: colorText, fontSize: 15),
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: colorSubtitle, size: 22),
              hintText: "••••••••",
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              filled: true,
              fillColor: colorField,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorSubtitle,
                  size: 22,
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: colorPrimary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
            validator: (password) {
              if (password == null || password.isEmpty) {
                return "Password cannot be empty";
              }
              if (password.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLoginButton() {
    return AbsorbPointer(
      absorbing: _isLoading,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isButtonPressed = true),
        onTapUp: (_) {
          setState(() => _isButtonPressed = false);
          _handleLogin();
        },
        onTapCancel: () => setState(() => _isButtonPressed = false),
        child: AnimatedScale(
          scale: _isButtonPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: _isLoading
                  ? null
                  : const LinearGradient(
                      colors: [colorPrimary, colorPrimaryDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: _isLoading ? Colors.grey.shade400 : null,
              boxShadow: _isLoading
                  ? []
                  : [
                      const BoxShadow(
                        color: Color(0x221976D2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
            ),
            child: Center(
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Signing In...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.75,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
