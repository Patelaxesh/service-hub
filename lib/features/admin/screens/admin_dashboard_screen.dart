import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serviceshub/features/admin/screens/admin_approve_services_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_manage_categories_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_manage_customers_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_manage_suppliers_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_notifications_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_report_analytics_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_settings_screen.dart';
import 'package:serviceshub/features/admin/screens/admin_view_payments_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Structural Branding Colors
  static const Color colorBg = Color(0xffF8FAFC);
  static const Color colorPrimary = Color(0xff1976D2);
  static const Color colorText = Color(0xff1F2937);
  static const Color colorSubtitle = Color(0xff6B7280);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Responsive cross axis alignment mapping
    int crossAxisCount = 2;
    if (screenWidth > 1100) {
      crossAxisCount = 4;
    } else if (screenWidth > 650) {
      crossAxisCount = 3;
    }

    // Centered alignment layout targets ~140-150px layout card constraints beautifully on mobile viewports
    double childAspectRatio = 0.95;
    if (screenWidth > 1200) {
      childAspectRatio = 1.35;
    } else if (screenWidth > 900) {
      childAspectRatio = 1.20;
    } else if (screenWidth > 650) {
      childAspectRatio = 1.10;
    } else if (screenWidth < 380) {
      childAspectRatio =
          0.88; // Safety cushion against extreme small-screen text squeezing
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: colorBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Clean Header Block
              _buildCustomHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Statistics Strips Header Panel
                      _buildQuickStatsRibbon(screenWidth),

                      const SizedBox(height: 28),

                      // 3. Management Workspace Core Grid (Centered Icons + Labels)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _AnimatedGridCard(
                            icon: Icons.groups_rounded,
                            label: "Manage Suppliers",
                            accentColor: colorPrimary,
                            destination: const AdminManageSuppliersScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.people_alt_rounded,
                            label: "Manage Customers",
                            accentColor: Colors.amberAccent,
                            destination: const AdminManageCustomersScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.category_rounded,
                            label: "Categories",
                            accentColor: Colors.purple,
                            destination: const AdminManageCategoriesScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.gavel_rounded,
                            label: "Approve Services",
                            accentColor: Colors.orange,
                            destination: const AdminApproveServicesScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.payments_rounded,
                            label: "Payments",
                            accentColor: Colors.pink,
                            destination: const AdminViewPaymentsScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.analytics_rounded,
                            label: "Reports",
                            accentColor: Colors.indigo,
                            destination: const AdminReportsAnalyticsScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.notifications_active_rounded,
                            label: "Notifications",
                            accentColor: Colors.redAccent,
                            destination: AdminNotificationsScreen(),
                          ),
                          _AnimatedGridCard(
                            icon: Icons.settings_suggest_rounded,
                            label: "Settings",
                            accentColor: Colors.grey.shade600,
                            destination: const AdminSettingsScreen(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Good Morning",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorSubtitle),
                  ),
                  const SizedBox(width: 4),
                  const Text("👋", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                "Administrator",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorText,
                    letterSpacing: -0.5),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminNotificationsScreen()),
                  );
                },
                icon: Badge(
                  backgroundColor: Colors.redAccent,
                  label: const Text('99+'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: colorText, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Hero(
                tag: 'service_hub_logo',
                child: Image.asset(
                  'assets/images/servicehub_logo.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: colorPrimary, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.bolt, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickStatsRibbon(double screenWidth) {
    final int columns = screenWidth > 900 ? 4 : 2;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      childAspectRatio: screenWidth > 600 ? 2.8 : 2.1,
      children: [
        _buildStatCard(
            "Pending", "12", Icons.pending_actions_rounded, Colors.amber),
        _buildStatCard(
            "Suppliers", "54", Icons.assignment_ind_rounded, colorPrimary),
        _buildStatCard("Customers", "845", Icons.assignment_turned_in_rounded,
            Colors.amberAccent),
        _buildStatCard("Revenue", "₹58K", Icons.monetization_on_rounded,
            Colors.deepPurple),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color highlightColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x031E293B), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorSubtitle)),
              Icon(icon, size: 16, color: highlightColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorText,
                letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.exit_to_app_rounded,
                    color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Exit App',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: colorText)),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to exit Service Hub?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorSubtitle,
                    height: 1.3),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: Colors.grey.shade200, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: colorText, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Exit',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedGridCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final Widget destination;

  const _AnimatedGridCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.destination,
  });

  @override
  State<_AnimatedGridCard> createState() => _AnimatedGridCardState();
}

class _AnimatedGridCardState extends State<_AnimatedGridCard> {
  bool _isPressed = false;

  void _navigateToDestination() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero)
                    .animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: animation, curve: const Interval(0.0, 0.65)),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _navigateToDestination();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x051E293B),
                  blurRadius: 14,
                  offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // Vertically centered
            crossAxisAlignment: CrossAxisAlignment.center,
            // Horizontally centered
            children: [
              // Premium 52x52 Box Container Token
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 26.0, // Large, clean, balanced icon token
                    color: widget.accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                // Center aligned label string block
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1F2937),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
