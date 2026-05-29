import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // dependency in pubspec.yaml
import 'next_screen.dart'; // Import the next_screen file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and tween animation
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start animation
    _controller.forward();

    // Navigate to next screen after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NextScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFF0288D1)], // Custom colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'serviceHubTag',
                  child: Icon(
                    Icons.star,
                    size: 100, // Adjusted for better visibility
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Hero(
                  tag: 'serviceHubTextTag',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Service Hub',
                      style: GoogleFonts.roboto(
                        fontSize: 40, // Increased font size for better impact
                        fontWeight: FontWeight.w900, // Stronger weight
                        color: Colors.white,
                        letterSpacing: 3, // Enhanced spacing
                        shadows: [
                          Shadow(
                            offset: const Offset(3, 3),
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
