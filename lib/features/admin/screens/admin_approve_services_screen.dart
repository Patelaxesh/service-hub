import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// =========================================================================
// MAIN SCREEN: ADMIN APPROVE SERVICES SCREEN
// =========================================================================
class AdminApproveServicesScreen extends StatefulWidget {
  const AdminApproveServicesScreen({super.key});

  @override
  AdminApproveServicesScreenState createState() =>
      AdminApproveServicesScreenState();
}

class AdminApproveServicesScreenState
    extends State<AdminApproveServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CollectionReference _servicesCollection =
      FirebaseFirestore.instance.collection('services');

  String _searchQuery = "";
  String _selectedStatusTab =
      "Pending"; // Matches 'Pending', 'Approved', 'Rejected'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showConfirmationBottomSheet({
    required String id,
    required String serviceName,
    required bool isApproveAction,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text(
                isApproveAction ? 'Approve Service?' : 'Reject Service?',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to update "$serviceName"?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);

                          if (isApproveAction) {
                            await _servicesCollection.doc(id).update({
                              'status': 'Approved',
                              'approvedAt': FieldValue.serverTimestamp(),
                            });
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Service Approved!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            await _servicesCollection.doc(id).update({
                              'status': 'Rejected',
                              'rejectedAt': FieldValue.serverTimestamp(),
                            });
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Service Rejected!'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }

                          navigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApproveAction
                              ? Colors.blue[600]
                              : Colors.red[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          isApproveAction ? 'Approve' : 'Reject',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToDetailScreen(
      BuildContext context, Map<String, dynamic> serviceData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: ServiceDetailsScreen(
                serviceData: serviceData,
                onApprove: () => _showConfirmationBottomSheet(
                  id: serviceData['serviceId'],
                  serviceName: serviceData['serviceName'],
                  isApproveAction: true,
                ),
                onReject: () => _showConfirmationBottomSheet(
                  id: serviceData['serviceId'],
                  serviceName: serviceData['serviceName'],
                  isApproveAction: false,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _servicesCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildGlobalShimmerFrame();
            }

            final docs = snapshot.data?.docs ?? [];

            final allServices = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return {
                'serviceId': doc.id,
                'serviceName': data?['serviceName']?.toString() ?? 'N/A',
                'category': data?['category']?.toString() ?? 'N/A',
                'supplierId': data?['supplierId']?.toString() ?? 'N/A',
                'supplierName': data?['supplierName']?.toString() ?? 'N/A',
                'supplierContact':
                    data?['supplierContact']?.toString() ?? 'N/A',
                'status': data?['status']?.toString() ?? 'Pending',
                'description': data?['description']?.toString() ??
                    'No description provided.',
                'price': data?['price']?.toString() ?? 'TBD',
                'createdAt': data?['createdAt'],
              };
            }).toList();

            allServices.sort((a, b) {
              final tsA = a['createdAt'] as Timestamp?;
              final tsB = b['createdAt'] as Timestamp?;
              if (tsA == null || tsB == null) return 0;
              return tsB.compareTo(tsA);
            });

            final countTotal = allServices.length;
            final pendingList =
                allServices.where((s) => s['status'] == 'Pending').toList();
            final approvedList =
                allServices.where((s) => s['status'] == 'Approved').toList();
            final rejectedList =
                allServices.where((s) => s['status'] == 'Rejected').toList();

            List<Map<String, dynamic>> contextWorkingList;
            if (_selectedStatusTab == "Approved") {
              contextWorkingList = approvedList;
            } else if (_selectedStatusTab == "Rejected") {
              contextWorkingList = rejectedList;
            } else {
              contextWorkingList = pendingList;
            }

            final filteredServicesList = contextWorkingList.where((service) {
              final sName = service['serviceName'].toLowerCase();
              final supName = service['supplierName'].toLowerCase();
              final cat = service['category'].toLowerCase();
              return sName.contains(_searchQuery) ||
                  supName.contains(_searchQuery) ||
                  cat.contains(_searchQuery);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Approve Services",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$countTotal Services",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
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
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search service, supplier, category...",
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentedTabItem("Pending", pendingList.length),
                        _buildSegmentedTabItem("Approved", approvedList.length),
                        _buildSegmentedTabItem("Rejected", rejectedList.length),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: allServices.isEmpty
                      ? _buildGlobalEmptyState()
                      : filteredServicesList.isEmpty
                          ? _buildSearchEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              itemCount: filteredServicesList.length,
                              itemBuilder: (context, index) {
                                final item = filteredServicesList[index];
                                return ServiceListItemCard(
                                  itemData: item,
                                  onTap: () =>
                                      _navigateToDetailScreen(context, item),
                                  onApprove: () => _showConfirmationBottomSheet(
                                    id: item['serviceId'],
                                    serviceName: item['serviceName'],
                                    isApproveAction: true,
                                  ),
                                  onReject: () => _showConfirmationBottomSheet(
                                    id: item['serviceId'],
                                    serviceName: item['serviceName'],
                                    isApproveAction: false,
                                  ),
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

  Widget _buildSegmentedTabItem(String label, int totalCount) {
    final isSelected = _selectedStatusTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatusTab = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            "$label ($totalCount)",
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("📂", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text("No services matched search",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text("Try clarifying filters or terminology.",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🛠", style: TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          const Text("No Services Available",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text('New operations registrations show up here.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
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
          const Text("Unable to load services",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
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

  Widget _buildGlobalShimmerFrame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 200, height: 28, color: Colors.grey[200]),
          const SizedBox(height: 6),
          Container(width: 80, height: 16, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14))),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(
                    height: 104,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
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

// =========================================================================
// WIDGET: POLISHED COMPACT SERVICE LIST ITEM CARD (HEIGHT 104)
// =========================================================================
class ServiceListItemCard extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ServiceListItemCard({
    required this.itemData,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  @override
  State<ServiceListItemCard> createState() => _ServiceListItemCardState();
}

class _ServiceListItemCardState extends State<ServiceListItemCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final sName = widget.itemData['serviceName'] ?? 'N/A';
    final supplier = widget.itemData['supplierName'] ?? 'N/A';
    final category = widget.itemData['category'] ?? 'N/A';
    final status = widget.itemData['status'] ?? 'Pending';
    final avatarLetter = sName.isNotEmpty ? sName[0].toUpperCase() : "?";

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 104,
          // Optimized dense height constraint
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x04000000),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              // Enhanced Avatar Module
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue[700]),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Supplier Name, and Category Info Stack
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildStatusChipLayout(status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            supplier,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Small Category Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Vertically Stacked Action Buttons Column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (status == 'Pending') ...[
                    SizedBox(
                      height: 36,
                      width: 70, // Balanced equal widths
                      child: ElevatedButton(
                        onPressed: widget.onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Approve',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 36,
                      width: 70, // Balanced equal widths
                      child: OutlinedButton(
                        onPressed: widget.onReject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reject',
                            style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else
                    // Trailing navigation chevron for non-pending items
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(Icons.chevron_right_rounded,
                          color: Colors.grey[400], size: 20),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChipLayout(String status) {
    Color bg;
    Color text;
    if (status == "Approved") {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (status == "Rejected") {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}

// =========================================================================
// DETAILS SCREEN: PRODUCTION COMPLIANT SERVICE DETAILS SCREEN
// =========================================================================
class ServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ServiceDetailsScreen({
    required this.serviceData,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sName = serviceData['serviceName'] ?? 'N/A';
    final category = serviceData['category'] ?? 'N/A';
    final supplier = serviceData['supplierName'] ?? 'N/A';
    final contact = serviceData['supplierContact'] ?? 'N/A';
    final description =
        serviceData['description'] ?? 'No description provided.';
    final price = serviceData['price'] ?? 'TBD';
    final status = serviceData['status'] ?? 'Pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Service Details",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(category,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 16),
                          Text(sName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Rate Reference: $price",
                              style: TextStyle(
                                  color: Colors.blue[100],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Operational Information"),
                    _buildInformationCard([
                      _buildInlineDetailRow(
                          Icons.person_outline_rounded, "Supplier", supplier),
                      _buildInlineDetailRow(Icons.phone_android_rounded,
                          "Contact Number", contact),
                      _buildInlineDetailRow(
                          Icons.info_outline_rounded, "Current Status", status,
                          customColor: _getStatusTextColor(status)),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Service Description"),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x02000000),
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (status == 'Pending')
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 20,
                        offset: Offset(0, -4))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onReject();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFEF4444), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Reject Service',
                              style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onApprove();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Approve Service',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildInformationCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x02000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(children: rows),
    );
  }

  Widget _buildInlineDetailRow(IconData icon, String label, String value,
      {Color? customColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: customColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Color _getStatusTextColor(String status) {
    if (status == "Approved") return const Color(0xFF16A34A);
    if (status == "Rejected") return const Color(0xFFDC2626);
    return const Color(0xFFD97706);
  }
}
