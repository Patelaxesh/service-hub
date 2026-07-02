import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// =========================================================================
// MAIN SCREEN: ADMIN VIEW PAYMENTS SCREEN (MOBILE-FIRST REFINEMENTS)
// =========================================================================
class AdminViewPaymentsScreen extends StatefulWidget {
  const AdminViewPaymentsScreen({super.key});

  @override
  State<AdminViewPaymentsScreen> createState() =>
      _AdminViewPaymentsScreenState();
}

class _AdminViewPaymentsScreenState extends State<AdminViewPaymentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = "";
  String _selectedFilterChip = "All"; // 'All', 'COD', 'UPI', 'Card'
  List<String> selectedBookings = [];

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

  Future<void> _requestPayout() async {
    if (selectedBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one booking to request payout'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final batch = _firestore.batch();
      final requestDate = FieldValue.serverTimestamp();

      for (String bookingId in selectedBookings) {
        final payoutRef = _firestore.collection('payoutRequests').doc();
        final commission = await _getBookingCommission(bookingId);

        batch.set(payoutRef, {
          'bookingId': bookingId,
          'adminId': _auth.currentUser?.uid,
          'requestDate': requestDate,
          'status': 'pending',
          'amount': commission,
        });

        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        batch.update(bookingRef, {
          'payoutRequested': true,
          'payoutRequestedAt': requestDate,
        });
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payout request sent successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        selectedBookings.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting payout: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<double> _getBookingCommission(String bookingId) async {
    var doc = await _firestore.collection('bookings').doc(bookingId).get();
    return (doc.data()?['commission'] as num?)?.toDouble() ?? 0.0;
  }

  void _toggleBookingSelection(String bookingId) {
    setState(() {
      if (selectedBookings.contains(bookingId)) {
        selectedBookings.remove(bookingId);
      } else {
        selectedBookings.add(bookingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('bookings')
              .where('commission', isGreaterThan: 0)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildGlobalErrorState();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildGlobalShimmerFrame();
            }

            final docs = snapshot.data?.docs ?? [];

            // Single Source of Truth Calculation Loop
            double calculatedTotalCommission = 0.0;
            final allPaymentsRaw = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final commValue = (data['commission'] as num?)?.toDouble() ?? 0.0;

              final bool alreadyRequested = data['payoutRequested'] ?? false;
              if (!alreadyRequested &&
                  (data['paymentMethod'] as String?)?.toUpperCase() == 'COD') {
                calculatedTotalCommission += commValue;
              }

              return {
                'id': doc.id,
                'bookingNumber': data['bookingNumber']?.toString() ??
                    doc.id.substring(0, min(doc.id.length, 6)),
                'bookingDate': data['bookingDate'],
                'payoutRequestedAt': data['payoutRequestedAt'],
                'finalAmount': (data['finalAmount'] as num?)?.toDouble() ?? 0.0,
                'commission': commValue,
                'paymentMethod': data['paymentMethod']?.toString() ?? 'Unknown',
                'supplierName': data['supplierName']?.toString() ?? 'N/A',
                'payoutRequested': alreadyRequested,
              };
            }).toList();

            // Filters Execution Matrix
            final filteredPaymentsList = allPaymentsRaw.where((payment) {
              final method = payment['paymentMethod'].toString().toUpperCase();

              if (_selectedFilterChip == "COD" && method != "COD") return false;
              if (_selectedFilterChip == "UPI" && method != "UPI") return false;
              if (_selectedFilterChip == "Card" && !method.contains("CARD")) {
                return false;
              }

              if (_searchQuery.isNotEmpty) {
                final bNum = payment['bookingNumber'].toString().toLowerCase();
                final sup = payment['supplierName'].toString().toLowerCase();
                return bNum.contains(_searchQuery) ||
                    sup.contains(_searchQuery);
              }

              return true;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean Header (Duplicate Subtitle Amount Removed)
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    "Payments",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),

                // Simplified Available Commission Summary Card Block
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 12,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Commission',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${calculatedTotalCommission.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ready for payout',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),

                // Shortened Search Component
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
                            color: Color(0x04000000),
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search bookings...",
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

                // Horizontal Filter Segment Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildFilterChipItem("All"),
                        _buildFilterChipItem("COD"),
                        _buildFilterChipItem("UPI"),
                        _buildFilterChipItem("Card"),
                      ],
                    ),
                  ),
                ),

                // Restructured Card-Based Payment Feed List
                Expanded(
                  child: allPaymentsRaw.isEmpty
                      ? _buildGlobalEmptyState()
                      : filteredPaymentsList.isEmpty
                          ? _buildSearchEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                              itemCount: filteredPaymentsList.length,
                              itemBuilder: (context, index) {
                                final item = filteredPaymentsList[index];
                                final bool isCOD = item['paymentMethod']
                                        .toString()
                                        .toUpperCase() ==
                                    'COD';
                                final bool isRequested =
                                    item['payoutRequested'] as bool;
                                final bool isSelected =
                                    selectedBookings.contains(item['id']);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    // Standardized to 20 radius
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x03000000),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row 1: Booking Number & Selector Checkbox Location Alignment
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Booking #${item['bookingNumber']}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87),
                                          ),
                                          if (isCOD && !isRequested)
                                            Transform.scale(
                                              scale: 0.9,
                                              child: Checkbox(
                                                value: isSelected,
                                                activeColor: Colors.blue[600],
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                onChanged: (val) =>
                                                    _toggleBookingSelection(
                                                        item['id']),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),

                                      // Row 2: Date & Payment Method Badges Layout
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDateString(
                                                item['bookingDate']),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w500),
                                          ),
                                          _buildPaymentMethodBadge(
                                              item['paymentMethod'],
                                              isRequested,
                                              item['payoutRequestedAt']),
                                        ],
                                      ),

                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            color: Color(0xFFEDF2F7)),
                                      ),

                                      // Enhanced Focal Financial Rows & Metadata Stack Block
                                      _buildFinDataRow("Amount",
                                          "₹${item['finalAmount'].toStringAsFixed(2)}",
                                          isBoldAmount: true),
                                      const SizedBox(height: 8),
                                      _buildFinDataRow("Commission",
                                          "₹${item['commission'].toStringAsFixed(2)}",
                                          textCustomColor:
                                              const Color(0xFF16A34A)),
                                      const SizedBox(height: 8),
                                      _buildFinDataRow(
                                          "Supplier", item['supplierName'],
                                          labelCustomColor: Colors.grey[500],
                                          isFadedValue: true),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),

                // Sticky Footer Execution Button
                if (selectedBookings.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 20,
                            offset: Offset(0, -4))
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _requestPayout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          "Request Payout (${selectedBookings.length})",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinDataRow(String label, String value,
      {Color? textCustomColor,
      Color? labelCustomColor,
      bool isBoldAmount = false,
      bool isFadedValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: labelCustomColor ?? Colors.grey[400],
              fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBoldAmount ? 15 : 13,
            fontWeight: (isBoldAmount || textCustomColor != null)
                ? FontWeight.bold
                : FontWeight.w600,
            color: textCustomColor ??
                (isFadedValue ? Colors.grey[700] : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChipItem(String label) {
    final isSelected = _selectedFilterChip == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterChip = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
              width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.blue[600]!.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodBadge(
      String method, bool isRequested, dynamic requestedAtTimestamp) {
    if (isRequested) {
      String dateContextStr = "";
      if (requestedAtTimestamp != null) {
        dateContextStr = " • ${_formatDateString(requestedAtTimestamp)}";
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          "Payout Requested$dateContextStr",
          style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold),
        ),
      );
    }

    Color bg;
    Color txt;
    final mStr = method.toUpperCase();

    if (mStr == 'COD') {
      bg = const Color(0xFFFFF1F2);
      txt = const Color(0xFFE11D48);
    } else if (mStr == 'UPI') {
      bg = const Color(0xFFF0FDF4);
      txt = const Color(0xFF16A34A);
    } else if (mStr.contains('CARD')) {
      bg = const Color(0xFFEEF2FF);
      txt = const Color(0xFF4F46E5);
    } else {
      bg = const Color(0xFFF8FAFC);
      txt = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(mStr,
          style:
              TextStyle(fontSize: 10, color: txt, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDateString(dynamic date) {
    if (date == null) return 'N/A';
    DateTime parsed;
    if (date is Timestamp) {
      parsed = date.toDate();
    } else if (date is String) {
      parsed = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return 'N/A';
    }

    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${parsed.day} ${months[parsed.month - 1]} ${parsed.year}";
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("📂", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text("No payments found.",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text("Try another search or filter.",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildBoxIllustrationIcon(String emoji, Color baseColor) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.3), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBoxIllustrationIcon("💳", const Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          const Text("No Payments Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text('Withdrawn or completed bookings will appear here.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildGlobalErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBoxIllustrationIcon("⚠️", const Color(0xFFFEE2E2)),
            const SizedBox(height: 16),
            const Text("Unable to load payments.",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              width: 140,
              child: ElevatedButton(
                onPressed: () => setState(() {}),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: const Text("Retry",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalShimmerFrame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 140, height: 28, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 16),
          Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
                4,
                (index) => Container(
                    width: 65,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)))),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
