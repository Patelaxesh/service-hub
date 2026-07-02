import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serviceshub/features/supplier/screens/supplier_Help_Support.dart';
import 'package:serviceshub/features/supplier/screens/supplier_feedback_Screen.dart';

import 'supplier_about_screen.dart';

class SupplierSettingsScreen extends StatelessWidget {
  const SupplierSettingsScreen({super.key});

// Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'Privacy',
        'subtitle': 'Adjust your privacy settings',
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Privacy settings coming soon!"),
                backgroundColor: primaryColor,
              ),
            ),
      },
      {
        'icon': Icons.brightness_6_rounded,
        'title': 'Theme',
        'subtitle': 'Switch between light and dark mode',
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Theme settings coming soon!"),
                backgroundColor: primaryColor,
              ),
            ),
      },
      {
        'icon': Icons.feedback_outlined,
        'title': 'Feedback',
        'subtitle': 'Send your feedback to us',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupplierFeedbackScreen()),
            ),
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Support',
        'subtitle': 'Get assistance and support',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SupplierHelpSupportScreen()),
            ),
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'About',
        'subtitle': 'Learn more about this app',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupplierAboutUsScreen()),
            ),
      },
      {
        'icon': Icons.language_rounded,
        'title': 'Language',
        'subtitle': 'English (Default)',
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Language settings coming soon!"),
                backgroundColor: primaryColor,
              ),
            ),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Ultra light layout background
      appBar: AppBar(
        title: const Text(
          "Settings",
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        itemCount: settingsOptions.length,
        itemBuilder: (context, index) {
          final item = settingsOptions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18.0),
                highlightColor: primaryColor.withValues(alpha: 0.03),
                splashColor: primaryColor.withValues(alpha: 0.06),
                onTap: item['onTap'],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            Icon(item['icon'], color: primaryColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCCCCCC),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
