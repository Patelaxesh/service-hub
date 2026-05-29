import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manage_suppliers_screen.dart';
import 'manage_customers_screen.dart';
import 'approve_services_screen.dart';
import 'reports_analytics_screen.dart';
import 'settings_screen.dart';
import 'manage_categories_screen.dart';
import 'notifications_screen.dart';
import 'view_payments_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.lightBlue,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.group,
                label: "Manage Suppliers",
                destination: const ManageSuppliersScreen(),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.person,
                label: "Manage Customers",
                destination: const ManageCustomersScreen(),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.category,
                label: "Manage Categories",
                destination: const ManageCategoriesScreen(),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.check_circle,
                label: "Approve Services",
                destination: const ApproveServicesScreen(),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.notifications,
                label: "Notifications",
                destination: const NotificationsScreen(),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.bar_chart,
                label: "View Reports",
                destination: const ReportsAnalyticsScreen(),
              ),
              _buildDashboardCard(
                context,
                icon: Icons.payment,
                label: "View Payments",
                destination: const ViewPaymentsScreen(),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.0,
                color: Colors.lightBlue,
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
              backgroundColor: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              "Close",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
