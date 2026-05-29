import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class OrderRequestScreen extends StatefulWidget {
  @override
  _OrderRequestScreenState createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> pendingBookings = [];
  List<Map<String, dynamic>> completedBookings = [];
  bool isLoading = true;

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

      setState(() {
        pendingBookings = [];
        completedBookings = [];

        snapshot.docs.asMap().entries.forEach((entry) {
          final index = entry.key;
          final doc = entry.value;
          final booking = doc.data()..['id'] = doc.id;
          booking['customerName'] = indianNames[index % indianNames.length];

          if (booking['status'] == 'completed') {
            completedBookings.add(booking);
          } else {
            pendingBookings.add(booking);
          }
        });
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: $e')),
      );
    }
  }

  Future<void> completeBooking(Map<String, dynamic> booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as Completed?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('Are you sure you want to mark this booking as completed?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          ),
        );

        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(booking['id'])
            .update({'status': 'completed'});

        await fetchBookings();

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking marked as completed!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating booking: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Requests'),
        backgroundColor: Colors.redAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              // bottom: Radius.circular(16),
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.black,
          //indicatorWeight: 3,
          // indicatorSize: TabBarIndicatorSize.label,
          // indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoading
              ? buildShimmerList()
              : buildOrderList(pendingBookings, true),
          isLoading
              ? buildShimmerList()
              : buildOrderList(completedBookings, false),
        ],
      ),
    );
  }

  Widget buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildOrderList(List<Map<String, dynamic>> bookings, bool isPending) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.hourglass_empty : Icons.check_circle_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              isPending ? 'No pending bookings' : 'No completed bookings',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchBookings,
      color: Colors.redAccent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            shadowColor: Colors.redAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking['serviceName'] ?? 'N/A',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                        ),
                      ),
                      if (!isPending)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buildInfoRow(Icons.person, booking['customerName'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  buildInfoRow(
                      Icons.calendar_today, booking['bookingDate'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  buildInfoRow(Icons.location_on, booking['address'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  buildInfoRow(
                      Icons.payment, booking['paymentMethod'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  buildInfoRow(
                    Icons.currency_rupee,
                    '${booking['finalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                    isAmount: true,
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => completeBooking(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        ),
                        child: Text(
                          "Complete",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String text, {bool isAmount = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(width: 8),
        Expanded(
          child: isAmount
              ? Text(
                  '₹$text',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(fontSize: 14),
                ),
        ),
      ],
    );
  }
}
