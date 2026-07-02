import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serviceshub/features/admin/screens/admin_customer_details_screen.dart';

class AdminManageCustomersScreen extends StatefulWidget {
  const AdminManageCustomersScreen({super.key});

  @override
  AdminManageCustomersScreenState createState() =>
      AdminManageCustomersScreenState();
}

class AdminManageCustomersScreenState
    extends State<AdminManageCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _navigateToDetails(Map<String, dynamic> customer) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AdminCustomerDetailsScreen(
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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('customers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            }

            final docs = snapshot.data?.docs ?? [];

// Total master list mapping configuration
            final allCustomers = docs.map((doc) {
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

// Handle pure empty database state early
            if (allCustomers.isEmpty) {
              return _buildGlobalEmptyState();
            }

// High-performance local filtering logic
            final filteredCustomers = allCustomers.where((customer) {
              final fullName =
                  "${customer["firstName"]} ${customer["lastName"]}"
                      .toLowerCase();
              final email = (customer["email"] ?? "").toLowerCase();
              final phone = (customer["contactNumber"] ?? "").toLowerCase();
              final city = (customer["city"] ?? "").toLowerCase();

              return fullName.contains(_searchQuery) ||
                  email.contains(_searchQuery) ||
                  phone.contains(_searchQuery) ||
                  city.contains(_searchQuery);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// Custom Premium Application Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Manage Customers",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${allCustomers.length} Customers",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

// Redesigned Core Search Input Block
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search by name, email or phone",
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.grey[400], size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

// Core Data Feed Switch View
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? _buildSearchEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("👥", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            "No customers found",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "Try another search.",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("👥", style: TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          const Text(
            "No Customers",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            "No customers have registered yet.",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("⚠", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            "Unable to load customers",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "Check your internet connection.",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 180, height: 28, color: Colors.grey[200]),
          const SizedBox(height: 6),
          Container(width: 80, height: 16, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomerListItem extends StatefulWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onTap;

  const CustomerListItem({
    required this.customer,
    required this.onTap,
    super.key,
  });

  @override
  State<CustomerListItem> createState() => _CustomerListItemState();
}

class _CustomerListItemState extends State<CustomerListItem> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final name =
        "${widget.customer["firstName"]} ${widget.customer["lastName"]}";
    final mobile = widget.customer["contactNumber"];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedScale(
        scale: _isTapped ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
// 52x52 Rounded Rectangle Initial Avatar Block
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

// Two-Line Text Block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              mobile,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

// Trailing Minimal Chevron Indicator
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
