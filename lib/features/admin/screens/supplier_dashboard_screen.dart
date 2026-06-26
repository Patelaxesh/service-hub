
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serviceshub/features/provider/screens/earnings_payment_screen.dart'
as earnings;
import 'package:serviceshub/features/provider/screens/notifications_screen.dart';
import 'package:serviceshub/features/provider/screens/order_requests_screen.dart';
import 'package:serviceshub/features/provider/screens/profile_screen.dart';
import 'package:serviceshub/features/provider/screens/ratings_reviews_screen.dart';
import 'package:serviceshub/features/provider/screens/report_issues_screen.dart';
import 'package:serviceshub/features/provider/screens/service_management_screen.dart'
as service;
import 'package:serviceshub/features/provider/screens/settings_screen.dart';

class SupplierDashboardScreen extends StatefulWidget {
  final String uid;

  const SupplierDashboardScreen({super.key, required this.uid});

  @override
  _SupplierDashboardScreenState createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  String firstName = '';
  String lastName = '';
  bool isLoading = true;

  // Modern Premium Color Palette
  static const Color primaryColor = Color(0xFFE53935); // Rich Red
  static const Color accentColor = Color(0xFFFFF3F3); // Soft Warm Rose container background
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _fetchSupplierData();
  }

  Future<void> _fetchSupplierData() async {
    try {
      DocumentSnapshot supplierDoc = await FirebaseFirestore.instance
          .collection('Suppliers')
          .doc(widget.uid)
          .get();

      if (!mounted) return;

      if (supplierDoc.exists) {
        setState(() {
          firstName = supplierDoc['firstName'] ?? '';
          lastName = supplierDoc['lastName'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load supplier data"),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Modern Responsive Breakpoints
    int crossAxisCount = 2;
    double itemHeight = 140.0;

    if (screenWidth > 900) {
      crossAxisCount = 4; // Desktop / Landscape Tablets
      itemHeight = 150.0;
    } else if (screenWidth > 600) {
      crossAxisCount = 3; // Portrait Tablets
      itemHeight = 145.0;
    }

    // Dynamic horizontal padded width math for exact aspect ratios
    final double gridPadding = 40.0; // 20.0 padding on left + right
    final double totalSpacing = (crossAxisCount - 1) * 16.0;
    final double itemWidth = (screenWidth - gridPadding - totalSpacing) / crossAxisCount;
    final double childAspectRatio = itemWidth / itemHeight;

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Supplier Portal",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false, // Ensures native back arrow does not show up
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                final shouldExit = await _showExitConfirmationDialog(context);
                if (shouldExit == true) {
                  SystemNavigator.pop();
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: isLoading
            ? const Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Welcome Header Banner
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 32.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : "S",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "$firstName $lastName",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Operations Header Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                child: const Text(
                  "Operations Dashboard",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      letterSpacing: 0.3),
                ),
              ),

              // Responsive Dashboard Grid Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildDashboardCard(
                      context,
                      icon: Icons.home_repair_service_rounded,
                      label: "Services",
                      destination: const service.ServiceManagementScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.assignment_rounded,
                      label: "Requests",
                      destination: OrderRequestScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      label: "Earnings",
                      destination: earnings.EarningsAndPaymentScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.star_rounded,
                      label: "Reviews",
                      destination: RatingsAndReviewsScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.notifications_rounded,
                      label: "Alerts",
                      destination: NotificationsScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.gpp_maybe_rounded,
                      label: "Issues",
                      destination: const ReportIssuesScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.person_rounded,
                      label: "Profile",
                      destination: SupplierProfileScreen(uid: widget.uid),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.settings_suggest_rounded,
                      label: "Settings",
                      destination: const SettingsScreen(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Widget destination,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          highlightColor: primaryColor.withOpacity(0.05),
          splashColor: primaryColor.withOpacity(0.1),
          onTap: () => _navigateWithAnimation(context, destination),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 26.0,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateWithAnimation(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: primaryColor),
            SizedBox(width: 12),
            Text("Exit Portal",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: const Text(
          "Are you sure you want to close the console and sign out?",
          style: TextStyle(fontSize: 15, color: textMuted, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: textMuted, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              "Exit",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

