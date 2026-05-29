import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../supplier_details_screen.dart';

class ManageSuppliersScreen extends StatefulWidget {
  const ManageSuppliersScreen({super.key});

  @override
  _ManageSuppliersScreenState createState() => _ManageSuppliersScreenState();
}

class _ManageSuppliersScreenState extends State<ManageSuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> filteredSuppliers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final querySnapshot = await _firestore.collection('Suppliers').get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar("No suppliers available", false);
      }

      setState(() {
        suppliers = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "firstName": data['firstName'] ?? data['FirstName'] ?? 'N/A',
            "lastName": data['lastName'] ?? data['LastName'] ?? 'N/A',
            "email": data['email'] ?? data['Email'] ?? 'N/A',
            "contactNumber": data['mobileNumber'] ??
                data['phoneNumber'] ??
                data['contactNumber'] ??
                'N/A',
            "country": data['country'] ?? 'N/A',
            "state": data['state'] ?? 'N/A',
            "city": data['city'] ?? 'N/A',
            "services": data['services'] ?? ["No services listed"],
            "docId": doc.id,
          };
        }).toList();

        filteredSuppliers = suppliers;
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Failed to fetch suppliers: ${e.toString()}", false);
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _filterSuppliers(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredSuppliers = suppliers.where((supplier) {
          final fullName = "${supplier["firstName"]} ${supplier["lastName"]}";
          return fullName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  void _navigateToDetails(Map<String, dynamic> supplier) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SupplierDetailsScreen(
          supplierName: "${supplier["firstName"]} ${supplier["lastName"]}",
          email: supplier["email"],
          contactNumber: supplier["contactNumber"],
          country: supplier["country"],
          state: supplier["state"],
          city: supplier["city"],
          services: supplier["services"],
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
        title: const Text("Manage Suppliers"),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSuppliers,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSuppliers,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  labelText: "Search by name",
                  hintText: "Type supplier name...",
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
                            _filterSuppliers("");
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
                onChanged: _filterSuppliers,
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
                          Text("Loading suppliers..."),
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
                                "Failed to load suppliers",
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _fetchSuppliers,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : filteredSuppliers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_alt_outlined,
                                      size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No suppliers found",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterSuppliers("");
                                      },
                                      child: const Text("Clear Search"),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredSuppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = filteredSuppliers[index];
                                return SupplierListItem(
                                  supplier: supplier,
                                  onTap: () => _navigateToDetails(supplier),
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

class SupplierListItem extends StatelessWidget {
  final Map<String, dynamic> supplier;
  final VoidCallback onTap;

  const SupplierListItem({
    required this.supplier,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final name = "${supplier["firstName"]} ${supplier["lastName"]}";

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
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
