import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviceshub/features/admin/screens/admin_screen.dart';
import 'package:serviceshub/features/admin/screens/supplier_screen.dart';
import '../../admin/screens/customer_screen.dart';

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  // Design constants
  static const double buttonMargin = 24.0; // Increased margin for more space
  static const double buttonPadding = 24.0; // Added padding inside buttons
  static const double buttonBorderRadius = 20.0;
  static const double buttonTextSize = 36.0; // Slightly smaller text
  static const double appBarTitleSize = 22.0; // Smaller app bar title
  static const double buttonElevation = 2.0; // Reduced elevation
  static const double iconSize = 48.0; // Smaller icons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Your Role",
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: appBarTitleSize,
            fontWeight: FontWeight.w500, // Lighter font weight
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        // Very subtle shadow
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[50], // Very light background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoleButton(
              context,
              role: "Admin",
              color: Colors.lightBlue, // Softer blue
              icon: Icons.admin_panel_settings,
              screen: const AdminScreen(),
            ),
            const SizedBox(height: buttonMargin),
            _buildRoleButton(
              context,
              role: "Customer",
              color: Colors.greenAccent, // Softer green
              icon: Icons.person,
              screen: const CustomerScreen(),
            ),
            const SizedBox(height: buttonMargin),
            _buildRoleButton(
              context,
              role: "Supplier",
              color: Colors.redAccent, // Softer orange instead of red
              icon: Icons.miscellaneous_services,
              screen: const SupplierScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String role,
    required Color color,
    required IconData icon,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration:
                const Duration(milliseconds: 300), // Faster transition
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(buttonBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(buttonPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9), // Solid color instead of gradient
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Lighter shadow
              offset: const Offset(1, 1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Takes only needed space
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                role,
                style: GoogleFonts.roboto(
                  fontSize: buttonTextSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w600, // Medium weight
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
