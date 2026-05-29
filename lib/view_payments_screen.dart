import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class ViewPaymentsScreen extends StatefulWidget {
  const ViewPaymentsScreen({super.key});

  @override
  State<ViewPaymentsScreen> createState() => _ViewPaymentsScreenState();
}

class _ViewPaymentsScreenState extends State<ViewPaymentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double totalCommission = 0.0;
  bool isLoading = true;
  List<String> selectedBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('commission', isGreaterThan: 0)
          .get();

      double commissionSum = 0;
      for (var doc in snapshot.docs) {
        commissionSum += (doc['commission'] as num).toDouble();
      }

      setState(() {
        totalCommission = commissionSum;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching payments: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
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
      for (String bookingId in selectedBookings) {
        await _firestore.collection('payoutRequests').add({
          'bookingId': bookingId,
          'adminId': _auth.currentUser?.uid,
          'requestDate': FieldValue.serverTimestamp(),
          'status': 'pending',
          'amount': await _getBookingCommission(bookingId),
        });

        await _firestore.collection('bookings').doc(bookingId).update({
          'payoutRequested': true,
        });
      }

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
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Payment Commissions',
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              // color: Colors.white,
              ),
        ),
        elevation: 0,
        //centerTitle: true,
        backgroundColor: Colors.lightBlue,
        // iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Total Commission Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  )
                : Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightBlue[400]!,
                            Colors.lightBlue[300]!
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Available Commission',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '₹${totalCommission.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You can request payout for COD bookings',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          // Payment List Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              border: const Border(
                top: BorderSide(color: Colors.lightBlue, width: 1),
                bottom: BorderSide(color: Colors.lightBlue, width: 1),
              ),
            ),
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Row(
                      children: List.generate(
                        5,
                        (index) => Expanded(
                          child: Container(
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Select',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Service Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Commission',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Payment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Payment List
          Expanded(
            child: isLoading
                ? ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? Colors.grey.shade50
                                : Colors.white,
                            border: const Border(
                              bottom:
                                  BorderSide(color: Colors.grey, width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: List.generate(
                              5,
                              (i) => Expanded(
                                flex: i == 1 ? 2 : 1,
                                child: Container(
                                  height: 16,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('bookings')
                        .where('commission', isGreaterThan: 0)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                          ),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment,
                                size: 48,
                                color: Colors.blueGrey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No payments found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Commission will appear here after bookings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: snapshot.data!.docs.length,
                              separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.blueGrey.shade100),
                              itemBuilder: (context, index) {
                                var doc = snapshot.data!.docs[index];
                                var data = doc.data() as Map<String, dynamic>;
                                bool isSelected =
                                    selectedBookings.contains(doc.id);
                                bool isCOD = (data['paymentMethod'] as String?)
                                        ?.toUpperCase() ==
                                    'COD';

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  color: index.isOdd
                                      ? Colors.lightBlue[50]
                                      : Colors.white,
                                  child: Row(
                                    children: [
                                      // Selection Checkbox (only for COD)
                                      Expanded(
                                        flex: 1,
                                        child: isCOD
                                            ? Checkbox(
                                                value: isSelected,
                                                onChanged: (value) {
                                                  _toggleBookingSelection(
                                                      doc.id);
                                                },
                                                activeColor: Colors.lightBlue,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              )
                                            : const SizedBox(),
                                      ),

                                      // Date Column
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatDate(data['bookingDate']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                      ),

                                      // Amount Column
                                      Expanded(
                                        child: Text(
                                          '₹${(data['finalAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                      ),

                                      // Commission Column
                                      Expanded(
                                        child: Text(
                                          '₹${(data['commission'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),

                                      // Payment Method Column
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getPaymentMethodColor(
                                                data['paymentMethod']
                                                    as String?),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            (data['paymentMethod'] ?? 'Unknown')
                                                .toString()
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Request Payout Footer Button
                          if (selectedBookings.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, -3),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _requestPayout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.request_page,
                                          size: 20, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'REQUEST PAYOUT',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          selectedBookings.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    }
    if (date is String) {
      return date.length > 10 ? date.substring(0, 10) : date;
    }
    return 'N/A';
  }

  Color _getPaymentMethodColor(String? method) {
    switch (method?.toUpperCase()) {
      case 'COD':
        return Colors.deepOrange;
      case 'UPI':
        return Colors.teal;
      case 'CREDIT CARD':
        return Colors.indigo;
      case 'DEBIT CARD':
        return Colors.blue;
      case 'NET BANKING':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}
