import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor = Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Ultra light layout background
      appBar: AppBar(
        title: const Text(
          "Help & Support",
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
            // Supplier Support Section
            _buildSectionTitle("Supplier Support"),
            _buildInfoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSupportTile(
                    Icons.email_outlined,
                    "Email: support@servicehub.com",
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildSupportTile(
                    Icons.phone_android_rounded,
                    "Phone: +91 8849590527",
                  ),
                ],
              ),
            ),

            // FAQs Section
            _buildSectionTitle("Frequently Asked Questions"),
            _buildInfoCard(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Theme(
                // Removes the default borders/lines ExpansionTile creates on expand
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: Column(
                  children: [
                    _buildFAQTile(
                      "How to list my services?",
                      'Go to "Add Service" in your dashboard, fill in the required details, and submit for approval.',
                    ),
                    _buildFAQTile(
                      "How to manage bookings?",
                      'Check your "Bookings" section to view, accept, or decline customer requests.',
                    ),
                    _buildFAQTile(
                      "How to withdraw my earnings?",
                      'Go to "Earnings", link your bank account, and request a withdrawal. Payments are processed within 3-5 business days.',
                    ),
                    _buildFAQTile(
                      "How to update my profile details?",
                      'Navigate to "Profile" and edit your details such as business name, contact info, and services offered.',
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
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

  Widget _buildInfoCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16.0),
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
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

  Widget _buildSupportTile(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      iconColor: primaryColor,
      collapsedIconColor: textMuted,
      dense: true,
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 12.0,
            top: 4.0,
          ),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14.0,
              color: textMuted,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}