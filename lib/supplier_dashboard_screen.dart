import 'supplier side/report_issues_screen.dart';
import 'supplier side/notifications_screen.dart';
import 'supplier side/settings_screen.dart';
import 'supplier side/earnings_payment_screen.dart' as earnings;
import 'supplier side/service_management_screen.dart' as service;
import 'supplier side/order_requests_screen.dart';
import 'supplier side/ratings_reviews_screen.dart';
import 'supplier side/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load supplier data"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final int crossAxisCount = isTablet ? 3 : 2;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Supplier Dashboard"),
          backgroundColor: Colors.redAccent,
          elevation: 4,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $firstName $lastName!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Manage all aspects of your services, requests, earnings and profile",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0,
                        children: [
                          _buildDashboardCard(
                            context,
                            icon: Icons.home_repair_service,
                            label: "Service Management",
                            destination: service.ServiceManagementScreen(),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.assignment,
                            label: "Service Requests",
                            destination: OrderRequestScreen(),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.currency_rupee,
                            label: "Earnings & Payments",
                            destination: earnings.EarningsAndPaymentScreen(),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.star,
                            label: "Ratings & Reviews",
                            destination: RatingsAndReviewsScreen(),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.notifications,
                            label: "Notifications",
                            destination: NotificationsScreen(),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.report_problem,
                            label: "Report Issues",
                            destination: const ReportIssuesScreen(),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.person,
                            label: "Profile",
                            destination: SupplierProfileScreen(uid: widget.uid),
                          ),
                          _buildDashboardCard(
                            context,
                            icon: Icons.settings,
                            label: "Settings",
                            destination: const SettingsScreen(),
                          ),
                        ],
                      ),
                    ),
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _navigateWithAnimation(context, destination),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.0,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text("Close Application"),
        content: const Text(
          "Are you sure you want to close the app?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Cancel",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              "Close",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
