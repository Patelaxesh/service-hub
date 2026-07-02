import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class SupplierOrderRequestScreen extends StatefulWidget {
  const SupplierOrderRequestScreen({super.key});

  @override
  State<SupplierOrderRequestScreen> createState() =>
      _SupplierOrderRequestScreenState();
}

class _SupplierOrderRequestScreenState extends State<SupplierOrderRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> pendingBookings = [];
  List<Map<String, dynamic>> completedBookings = [];
  bool isLoading = true;

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  // List of static Indian names
  final List<String> indianNames = [
    'Rahul Sharma',
    'Priya Patel',
    'Amit Singh',
    'Anjali Gupta',
    'Vikram Yadav',
    'Sneha Desai',
    'Rajesh Kumar',
    'Pooja Mehta',
    'Sanjay Verma',
    'Kavita Joshi',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      setState(() {
        isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('bookingDate', descending: true)
          .get();

      List<Map<String, dynamic>> tempPending = [];
      List<Map<String, dynamic>> tempCompleted = [];

      snapshot.docs.asMap().entries.forEach((entry) {
        final index = entry.key;
        final doc = entry.value;
        final booking = doc.data();
        booking['id'] = doc.id;
        booking['customerName'] = indianNames[index % indianNames.length];

        if (booking['status'] == 'completed') {
          tempCompleted.add(booking);
        } else {
          tempPending.add(booking);
        }
      });

      if (mounted) {
        setState(() {
          pendingBookings = tempPending;
          completedBookings = tempCompleted;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching bookings: $e',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.black87,
          ),
        );
      }
    }
  }

  Future<void> completeBooking(Map<String, dynamic> booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBgColor,
        surfaceTintColor: Colors.transparent,
        title: const Text('Mark as Completed?',
            style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
        content: const Text(
            'Are you sure you want to change this booking status to completed?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style:
                    TextStyle(color: textMuted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
          ),
        );

        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(booking['id'])
            .update({'status': 'completed'});

        await fetchBookings();

        if (mounted) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Booking marked as completed!',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error updating booking: $e'),
                backgroundColor: primaryColor),
          );
        }
      }
    }
  }

  String _formatBookingDate(dynamic rawDate) {
    if (rawDate is Timestamp) {
      return DateFormat('dd MMM yyyy • hh:mm a').format(rawDate.toDate());
    } else if (rawDate is String) {
      try {
        final parsed = DateTime.parse(rawDate);
        return DateFormat('dd MMM yyyy • hh:mm a').format(parsed);
      } catch (_) {
        return rawDate;
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
              indicatorColor: Colors.white,
              indicatorWeight: 3.5,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.3),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "Completed"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoading
              ? _buildShimmerList()
              : _buildOrderList(pendingBookings, true),
          isLoading
              ? _buildShimmerList()
              : _buildOrderList(completedBookings, false),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4))),
                    Container(
                        width: 70,
                        height: 20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6))),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(
                    4,
                    (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Container(
                                  width: i == 2 ? 200 : 110,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4))),
                            ],
                          ),
                        )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> bookings, bool isPending) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: accentColor, shape: BoxShape.circle),
              child: Icon(
                isPending
                    ? Icons.hourglass_empty_rounded
                    : Icons.check_circle_outline_rounded,
                size: 38,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPending
                  ? 'No pending bookings found'
                  : 'No completed bookings found',
              style: const TextStyle(
                  fontSize: 15, color: textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchBookings,
      color: primaryColor,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          final dynamic rawAmount = booking['finalAmount'];
          final double finalAmt = rawAmount is num
              ? rawAmount.toDouble()
              : (double.tryParse(rawAmount?.toString() ?? '') ?? 0.0);

          return _buildInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        booking['serviceName'] ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.0,
                          color: textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            isPending ? accentColor : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPending ? 'Pending' : 'Completed',
                        style: TextStyle(
                          color: isPending ? primaryColor : Colors.green[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildInfoRow(Icons.person_outline_rounded,
                    booking['customerName'] ?? 'N/A'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.calendar_today_rounded,
                    _formatBookingDate(booking['bookingDate'])),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.location_on_outlined,
                    booking['address'] ?? 'No address supplied'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.credit_card_rounded,
                    'Payment via: ${booking['paymentMethod'] ?? 'Unknown'}'),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.currency_rupee_rounded,
                  NumberFormat.currency(symbol: '₹', decimalDigits: 2)
                      .format(finalAmt),
                  isAmount: true,
                ),
                if (isPending) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => completeBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        "Complete Job",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isAmount = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isAmount ? FontWeight.w800 : FontWeight.w500,
              color: isAmount ? Colors.green[700] : textDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
