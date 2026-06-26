import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

// Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Ultra light layout background
      appBar: AppBar(
        title: const Text(
          "About Service Hub",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// App Identity Branding Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business_center_rounded,
                      size: 54,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome to Service Hub",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Connecting People, Services, and Opportunities for a Seamless Experience",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

// Content Blocks
            _buildSectionTitle("What is Service Hub?"),
            _buildInfoCard(
              child: const Text(
                "Service Hub is a platform that bridges the gap between service providers and customers globally. Whether you are looking for services or offering them, Service Hub makes the process easy, fast, and reliable.",
                style: TextStyle(
                  fontSize: 14.5,
                  color: textDark,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _buildSectionTitle("Our Mission & Vision"),
            _buildInfoCard(
              child: const Text(
                "Our mission is to simplify service access and create a seamless connection between providers and customers. We envision a world where services are just a tap away, fostering growth and accessibility for all.",
                style: TextStyle(
                  fontSize: 14.5,
                  color: textDark,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _buildSectionTitle("Key Features"),
            _buildInfoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildFeatureTile(Icons.check_circle_outline_rounded,
                      "Easy Booking of Services"),
                  _buildFeatureTile(Icons.verified_user_outlined,
                      "Verified Service Providers"),
                  _buildFeatureTile(
                      Icons.flash_on_rounded, "Fast and Reliable Connections"),
                ],
              ),
            ),

            _buildSectionTitle("App Information"),
            _buildInfoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildFeatureTile(
                      Icons.info_outline_rounded, "Version: 1.0.0",
                      iconColor: textMuted),
                  _buildFeatureTile(
                      Icons.developer_mode_rounded, "Developed by Axesh Patel",
                      iconColor: textMuted),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required Widget child,
      EdgeInsets padding = const EdgeInsets.all(16.0)}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: padding,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeatureTile(IconData icon, String title,
      {Color iconColor = Colors.green}) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
    );
  }
}
