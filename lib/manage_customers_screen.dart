import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_details_screen.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  _ManageCustomersScreenState createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final querySnapshot = await _firestore.collection('customers').get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar("No customers available", false);
      }

      setState(() {
        customers = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "firstName": data['firstName'] ?? 'N/A',
            "lastName": data['lastName'] ?? 'N/A',
            "email": data['email'] ?? 'N/A',
            "contactNumber": data['mobileNumber'] ??
                data['phoneNumber'] ??
                data['contactNumber'] ??
                'N/A',
            "country": data['country'] ?? 'N/A',
            "state": data['state'] ?? 'N/A',
            "city": data['city'] ?? 'N/A',
            "docId": doc.id,
          };
        }).toList();

        filteredCustomers = customers;
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Failed to fetch customers: ${e.toString()}", false);
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _filterCustomers(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredCustomers = customers.where((customer) {
          final fullName = "${customer["firstName"]} ${customer["lastName"]}";
          return fullName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  void _navigateToDetails(Map<String, dynamic> customer) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CustomerDetailsScreen(
          customerName: "${customer["firstName"]} ${customer["lastName"]}",
          email: customer["email"],
          contactNumber: customer["contactNumber"],
          address:
              "${customer["city"]}, ${customer["state"]}, ${customer["country"]}",
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Customers"),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCustomers,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCustomers,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  labelText: "Search by name",
                  hintText: "Type customer name...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterCustomers("");
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
                onChanged: _filterCustomers,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Loading customers..."),
                        ],
                      ),
                    )
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              const Text(
                                "Failed to load customers",
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _fetchCustomers,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : filteredCustomers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_outline,
                                      size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No customers found",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterCustomers("");
                                      },
                                      child: const Text("Clear Search"),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return CustomerListItem(
                                  customer: customer,
                                  onTap: () => _navigateToDetails(customer),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerListItem extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onTap;

  const CustomerListItem({
    required this.customer,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final name = "${customer["firstName"]} ${customer["lastName"]}";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.lightBlue[100],
                foregroundColor: Colors.lightBlue[800],
                radius: 24,
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1) : "?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
