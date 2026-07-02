import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serviceshub/features/admin/screens/admin_settings_screen.dart';
import 'package:serviceshub/features/customer/screens/customer_browse_services_screen.dart';
import 'package:serviceshub/features/customer/screens/customer_cart_screen.dart';
import 'package:serviceshub/features/customer/screens/customer_my_bookings_screen.dart';
import 'package:serviceshub/features/customer/screens/customer_order_history_screen.dart';
import 'package:serviceshub/features/customer/screens/customer_profile_screen.dart';

// Custom route for right-to-left animation
Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class CustomerDashboardScreen extends StatefulWidget {
  final String
      uid; // Renamed 'documentId' to 'uid' to match the usage in ProfileScreen

  const CustomerDashboardScreen({super.key, required this.uid});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ServiceCategoriesScreen(),
      const CustomerCartScreen(),
      CustomerMyBookingsScreen(
        serviceName: 'Sample Service',
        finalAmount: 90,
        bookingDate: '2023-10-15',
        serviceProvider: 'John Doe',
        paymentMethod: 'Credit Card',
        bookingStatus: 'Confirmed',
      ),
      CustomerOrderHistoryScreen(),
      CustomerProfileScreen(uid: widget.uid),
      // Passing the uid to ProfileScreen
      const AdminSettingsScreen(),
    ];
  }

  final List<String> _titles = [
    'Service Categories',
    'Cart',
    'My Booking',
    'Order History',
    'Profile',
    'Settings',
  ];

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Close Application'),
            content: const Text(
              'Are you sure you want to close the app?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    SystemNavigator.pop();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitConfirmationDialog();

        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: _currentIndex == 0
            ? AppBar(
                title: Text(_titles[_currentIndex]),
                backgroundColor: Colors.greenAccent,
              )
            : null,
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'My Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Order History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCategoriesScreen extends StatelessWidget {
  ServiceCategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Home Services', 'icon': Icons.home_repair_service},
    {'name': 'Cleaning Services', 'icon': Icons.cleaning_services},
    {'name': 'Health & Beauty Services', 'icon': Icons.spa},
    {'name': 'Event Services', 'icon': Icons.event},
    {'name': 'Delivery Services', 'icon': Icons.delivery_dining},
    {'name': 'Educational Services', 'icon': Icons.school},
    {'name': 'Automotive Services', 'icon': Icons.directions_car},
    {'name': 'Childcare Services', 'icon': Icons.child_care},
    {'name': 'Pet Services', 'icon': Icons.pets},
    {'name': 'Travel Services', 'icon': Icons.flight},
    {'name': 'Legal Services', 'icon': Icons.gavel},
    {'name': 'Financial Services', 'icon': Icons.payments},
    {'name': 'Technology Services', 'icon': Icons.computer},
    {'name': 'Real Estate Services', 'icon': Icons.home_work},
    {'name': 'Creative Services', 'icon': Icons.brush},
    {'name': 'Repair and Maintenance Services', 'icon': Icons.build},
    {'name': 'Medical Services', 'icon': Icons.medical_services},
    {'name': 'Logistics and Transportation', 'icon': Icons.local_shipping},
    {'name': 'Environmental Services', 'icon': Icons.eco},
    {'name': 'Entertainment Services', 'icon': Icons.music_note},
    {'name': 'Security Services', 'icon': Icons.security},
    {'name': 'Agricultural Services', 'icon': Icons.agriculture},
    {
      'name': 'Non-Profit and Social Services',
      'icon': Icons.volunteer_activism
    },
    {'name': 'Miscellaneous Services', 'icon': Icons.miscellaneous_services},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Explore Service Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      _createRoute(CustomerBrowseServicesScreen(
                        selectedCategory: category['name'],
                      )),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          size: 48.0,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          category['name'],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
