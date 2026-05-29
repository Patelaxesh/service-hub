import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Updated styling constants with larger sizes
const _cardTitleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
const _cardValueStyle =
    TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87);
const _loadingStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const _errorStyle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red);

class SummaryCardData {
  final String title;
  final dynamic value;
  final IconData icon;

  SummaryCardData(
      {required this.title, required this.value, required this.icon});
}

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  Future<int> _getCollectionCount(String collectionName,
      {String? whereField, dynamic whereValue}) async {
    try {
      Query query = FirebaseFirestore.instance.collection(collectionName);
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      final querySnapshot = await query.get();
      return querySnapshot.size;
    } catch (e) {
      debugPrint("Error fetching $collectionName count: $e");
      return 0;
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('bookings').get();

      double totalCommission = 0.0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('commission') && data['commission'] != null) {
          final commissionValue = data['commission'];
          if (commissionValue is num) {
            totalCommission += commissionValue.toDouble();
          }
        }
      }
      return totalCommission;
    } catch (e) {
      debugPrint("Error in getTotalRevenue: $e");
      return 0.0;
    }
  }

  Future<int> getTotalSuppliersCount() => _getCollectionCount('Suppliers');
  Future<int> getTotalCustomersCount() => _getCollectionCount('customers');
  Future<int> getTotalServicesCount() => _getCollectionCount('categories');
  Future<int> getPendingApprovalsCount() => _getCollectionCount('services',
      whereField: 'status', whereValue: 'Pending');

  Widget _buildFutureValue(Future<int> future) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...", style: _loadingStyle);
        } else if (snapshot.hasError) {
          return const Text("Error", style: _errorStyle);
        } else {
          return Text(
            snapshot.data?.toString() ?? "0",
            style: _cardValueStyle,
          );
        }
      },
    );
  }

  Widget _buildFutureRevenue(Future<double> future) {
    return FutureBuilder<double>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...", style: _loadingStyle);
        } else if (snapshot.hasError) {
          return const Text("Error", style: _errorStyle);
        } else {
          return Text(
            "₹${snapshot.data?.toStringAsFixed(2) ?? "0.00"}",
            style: _cardValueStyle,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Report"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Business Overview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                      constraints.maxWidth / (isLargeScreen ? 2 : 1) - 16;
                  return GridView.builder(
                    itemCount: 5,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLargeScreen ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isLargeScreen ? 1.5 : 1.8,
                    ),
                    itemBuilder: (context, index) => _buildSummaryCard(
                      _getCardData(index),
                      isLargeScreen: isLargeScreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SummaryCardData _getCardData(int index) {
    switch (index) {
      case 0:
        return SummaryCardData(
          title: "Total Revenue",
          value: _buildFutureRevenue(getTotalRevenue()),
          icon: Icons.currency_rupee,
        );
      case 1:
        return SummaryCardData(
          title: "Total Customers",
          value: _buildFutureValue(getTotalCustomersCount()),
          icon: Icons.people,
        );
      case 2:
        return SummaryCardData(
          title: "Total Suppliers",
          value: _buildFutureValue(getTotalSuppliersCount()),
          icon: Icons.store,
        );
      case 3:
        return SummaryCardData(
          title: "Total Services",
          value: _buildFutureValue(getTotalServicesCount()),
          icon: Icons.design_services,
        );
      case 4:
        return SummaryCardData(
          title: "Pending Approvals",
          value: _buildFutureValue(getPendingApprovalsCount()),
          icon: Icons.pending,
        );
      default:
        return SummaryCardData(
          title: "Unknown",
          value: "0",
          icon: Icons.error,
        );
    }
  }

  Widget _buildSummaryCard(SummaryCardData data,
      {required bool isLargeScreen}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Larger icon container with background
            Container(
              width: isLargeScreen ? 80 : 70,
              height: isLargeScreen ? 80 : 70,
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  data.icon,
                  size: isLargeScreen ? 40 : 36,
                  color: Colors.lightBlue,
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Text content with larger fonts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: _cardTitleStyle.copyWith(
                      fontSize: isLargeScreen ? 20 : 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (data.value is String)
                    Text(
                      data.value,
                      style: _cardValueStyle.copyWith(
                        fontSize: isLargeScreen ? 36 : 32,
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: data.value,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
