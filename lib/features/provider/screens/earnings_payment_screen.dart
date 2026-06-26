import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class EarningsAndPaymentScreen extends StatefulWidget {
  const EarningsAndPaymentScreen({super.key});

  @override
  _EarningsAndPaymentScreenState createState() =>
      _EarningsAndPaymentScreenState();
}

class _EarningsAndPaymentScreenState extends State<EarningsAndPaymentScreen> {
  double totalEarnings = 0.0;
  bool isLoading = true;
  List<Map<String, dynamic>> earnings = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _fetchEarningsData();
  }

  Future<void> _fetchEarningsData() async {
    try {
      setState(() => isLoading = true);
      totalEarnings = 0.0;

      final querySnapshot = await _firestore
          .collection('bookings')
          .orderBy('bookingDate', descending: true)
          .get();

      final List<Map<String, dynamic>> fetchedEarnings = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        if (data['finalAmount'] == null || data['bookingDate'] == null) {
          continue;
        }

        try {
          DateTime bookingDate;
          double amount = _parseAmount(data['finalAmount']);

          if (data['bookingDate'] is Timestamp) {
            bookingDate = (data['bookingDate'] as Timestamp).toDate();
          } else if (data['bookingDate'] is String) {
            bookingDate = DateTime.parse(data['bookingDate'] as String);
          } else {
            continue;
          }

          fetchedEarnings.add({
            'finalAmount': amount,
            'bookingDate': bookingDate,
            'serviceName': data['serviceName'] ?? 'Unknown Service',
            'paymentMethod': data['paymentMethod'] ?? 'Unknown',
            'documentId': doc.id,
          });

          totalEarnings += amount;
        } catch (e) {
          debugPrint('Error processing document ${doc.id}: $e');
        }
      }

      if (mounted) {
        setState(() {
          earnings = fetchedEarnings;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: ${e.toString()}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  double _parseAmount(dynamic amount) {
    if (amount is int) {
      return amount.toDouble();
    } else if (amount is double) {
      return amount;
    } else if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Earnings & Payments",
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
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _fetchEarningsData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Overview Card
            isLoading
                ? _buildShimmerEarningsCard()
                : _buildInfoCard(
                    child: Column(
                      children: [
                        const Text(
                          "Total Net Earnings",
                          style: TextStyle(
                            fontSize: 13,
                            color: textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatter.format(totalEarnings),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${earnings.length} ${earnings.length == 1 ? 'booking completed' : 'bookings completed'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 8),

            // Section Header Title
            _buildSectionHeader(context),
            const SizedBox(height: 14),

            // Earnings Transactions List View
            Expanded(
              child: isLoading
                  ? _buildShimmerTransactionList()
                  : earnings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                    color: accentColor, shape: BoxShape.circle),
                                child: const Icon(Icons.receipt_long_rounded,
                                    size: 40, color: primaryColor),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No transaction details yet",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: textMuted,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: primaryColor,
                          onRefresh: _fetchEarningsData,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: earnings.length,
                            itemBuilder: (context, index) {
                              final earning = earnings[index];
                              return _buildInfoCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.currency_rupee_rounded,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            earning['serviceName'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14.5,
                                              color: textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 12,
                                                  color: textMuted),
                                              const SizedBox(width: 5),
                                              Text(
                                                DateFormat(
                                                        'dd MMM yyyy • h:mm a')
                                                    .format(
                                                        earning['bookingDate']),
                                                style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: textMuted,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Method: ${earning['paymentMethod']}",
                                            style: const TextStyle(
                                                fontSize: 11.5,
                                                color: textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatter
                                              .format(earning['finalAmount']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.green[700],
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "Completed",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 0.5),
          ),
          if (!isLoading)
            Text(
              "Total: ${earnings.length}",
              style: const TextStyle(
                  fontSize: 13, color: textMuted, fontWeight: FontWeight.w700),
            ),
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
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShimmerEarningsCard() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: _buildInfoCard(
        child: Column(
          children: [
            Container(
              width: 110,
              height: 12,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 8),
            Container(
              width: 170,
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 14),
            Container(
              width: 130,
              height: 22,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTransactionList() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: ListView.builder(
        itemCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildInfoCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 13,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 11,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 65,
                      height: 18,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
