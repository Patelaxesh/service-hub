import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Aggregated data model containing calculated metrics for the screen
class ReportData {
  final double totalCommission;
  final int totalCustomers;
  final int totalSuppliers;
  final int totalServices;
  final int pendingApprovals;

  ReportData({
    required this.totalCommission,
    required this.totalCustomers,
    required this.totalSuppliers,
    required this.totalServices,
    required this.pendingApprovals,
  });

  bool get isEmpty =>
      totalCommission == 0.0 &&
      totalCustomers == 0 &&
      totalSuppliers == 0 &&
      totalServices == 0 &&
      pendingApprovals == 0;
}

class AdminReportsAnalyticsScreen extends StatefulWidget {
  const AdminReportsAnalyticsScreen({super.key});

  @override
  State<AdminReportsAnalyticsScreen> createState() =>
      _AdminReportsAnalyticsScreenState();
}

class _AdminReportsAnalyticsScreenState
    extends State<AdminReportsAnalyticsScreen> {
  StreamController<ReportData>? _reportStreamController;
  StreamSubscription? _bookingsSubscription;

  @override
  void initState() {
    super.initState();
    _initReportStream();
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    _reportStreamController?.close();
    super.dispose();
  }

  /// Listens to real-time updates and aggregates counts cleanly using native Flutter/Dart features
  void _initReportStream() {
    _reportStreamController = StreamController<ReportData>.broadcast();
    final fs = FirebaseFirestore.instance;

    // Listen to the primary real-time collection (bookings) and fetch the rest concurrently
    _bookingsSubscription = fs.collection('bookings').snapshots().listen(
      (bookingSnap) async {
        try {
          // Fetch secondary metrics in parallel
          final results = await Future.wait([
            fs.collection('customers').get(),
            fs.collection('Suppliers').get(),
            fs.collection('services').get(),
          ]);

          final customerSnap = results[0];
          final supplierSnap = results[1];
          final serviceSnap = results[2];

          // Calculate total commission from bookings
          double commissionSum = 0.0;
          for (var doc in bookingSnap.docs) {
            final data = doc.data();
            if (data.containsKey('commission') && data['commission'] != null) {
              final val = data['commission'];
              if (val is num) commissionSum += val.toDouble();
            }
          }

          // Calculate pending services status
          int pendingCount = 0;
          for (var doc in serviceSnap.docs) {
            final data = doc.data();
            if (data.containsKey('status') && data['status'] == 'Pending') {
              pendingCount++;
            }
          }

          if (!_reportStreamController!.isClosed) {
            _reportStreamController!.add(
              ReportData(
                totalCommission: commissionSum,
                totalCustomers: customerSnap.size,
                totalSuppliers: supplierSnap.size,
                totalServices: serviceSnap.size,
                // Correctly querying the services collection now!
                pendingApprovals: pendingCount,
              ),
            );
          }
        } catch (e) {
          if (!_reportStreamController!.isClosed) {
            _reportStreamController!.addError(e);
          }
        }
      },
      onError: (error) {
        if (!_reportStreamController!.isClosed) {
          _reportStreamController!.addError(error);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft modern background
      body: SafeArea(
        child: StreamBuilder<ReportData>(
          stream: _reportStreamController?.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final data = snapshot.data;
            if (data == null || data.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Triggers an interface redraw to re-fire stream listeners
                setState(() {
                  _bookingsSubscription?.cancel();
                  _initReportStream();
                });
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Premium Typography replaces old AppBar
                  const Text(
                    "Reports & Analytics",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Business Overview",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // Value-focused color-coded metric blocks
                  _MetricCard(
                    value: "₹${data.totalCommission.toStringAsFixed(2)}",
                    label: "Total Commission",
                    icon: Icons.currency_rupee_rounded,
                    accentColor: Colors.green,
                  ),
                  _MetricCard(
                    value: "${data.totalCustomers}",
                    label: "Customers",
                    icon: Icons.people_alt_rounded,
                    accentColor: Colors.blue,
                  ),
                  _MetricCard(
                    value: "${data.totalSuppliers}",
                    label: "Suppliers",
                    icon: Icons.storefront_rounded,
                    accentColor: Colors.orange,
                  ),
                  _MetricCard(
                    value: "${data.totalServices}",
                    label: "Services",
                    icon: Icons.design_services_rounded,
                    accentColor: Colors.purple,
                  ),
                  _MetricCard(
                    value: "${data.pendingApprovals}",
                    label: "Pending Approvals",
                    icon: Icons.pending_actions_rounded,
                    accentColor: Colors.amber,
                  ),

                  const SizedBox(height: 16),
                  // Live status indicator
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          "Live Data • Updated just now",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Container(width: 200, height: 28, color: Colors.grey[300]),
        const SizedBox(height: 6),
        Container(width: 120, height: 16, color: Colors.grey[200]),
        const SizedBox(height: 24),
        ...List.generate(
            5,
            (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Unable to load reports.",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _bookingsSubscription?.cancel();
                  _initReportStream();
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry Now"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No business data available.",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String value;
  final String label;
  final IconData icon;
  final MaterialColor accentColor;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.98),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: () {},
        // Ready for future drill-down extension navigation
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 125, // Clean, compact scannable height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Crisp icon box wrapper (Container 56x56, Icon 26)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 26,
                    color: widget.accentColor.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
