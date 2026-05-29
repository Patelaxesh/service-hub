import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String?
      _filterType; // 'reply', 'approval', 'rejection', 'payout', 'booking', or null for all

  Stream<List<Map<String, dynamic>>> _fetchAllNotifications() async* {
    try {
      final supplierReplies =
          _firestore.collection('Supplier Issues Replies').snapshots();
      final services = _firestore
          .collection('services')
          .where('status', whereIn: ['Rejected', 'Approved']).snapshots();
      final payoutRequests =
          _firestore.collection('payoutRequests').snapshots();
      final bookings = _firestore.collection('bookings').snapshots();

      await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
        if (!mounted) break;

        final List<Map<String, dynamic>> notifications = [];

        await Future.wait([
          _processSupplierReplies(supplierReplies, notifications),
          _processServices(services, notifications),
          _processPayoutRequests(payoutRequests, notifications),
          _processBookings(bookings, notifications),
        ]);

        // Apply filter if selected
        final filteredNotifications = _filterType != null
            ? notifications.where((n) => n['type'] == _filterType).toList()
            : notifications;

        // Sort by timestamp (newest first)
        filteredNotifications.sort((a, b) => (b['timestamp'] as Timestamp)
            .compareTo(a['timestamp'] as Timestamp));

        yield filteredNotifications;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      yield [];
    }
  }

  Future<void> _processSupplierReplies(
    Stream<QuerySnapshot> stream,
    List<Map<String, dynamic>> notifications,
  ) async {
    final snapshot = await stream.first;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      notifications.add({
        ...data,
        'id': doc.id,
        'source': 'Supplier Issues Replies',
        'timestamp': data['timestamp'] ?? Timestamp.now(),
        'type': 'reply',
      });
    }
  }

  Future<void> _processServices(
    Stream<QuerySnapshot> stream,
    List<Map<String, dynamic>> notifications,
  ) async {
    final snapshot = await stream.first;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      notifications.add({
        ...data,
        'id': doc.id,
        'source': 'Services',
        'timestamp': data['timestamp'] ?? Timestamp.now(),
        'type': data['status'] == 'Rejected' ? 'rejection' : 'approval',
        'serviceName': data['serviceName'] ?? 'Unknown Service',
      });
    }
  }

  Future<void> _processPayoutRequests(
    Stream<QuerySnapshot> stream,
    List<Map<String, dynamic>> notifications,
  ) async {
    final snapshot = await stream.first;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      notifications.add({
        ...data,
        'id': doc.id,
        'source': 'Payout Requests',
        'timestamp': data['timestamp'] ?? Timestamp.now(),
        'type': 'payout',
      });
    }
  }

  Future<void> _processBookings(
    Stream<QuerySnapshot> stream,
    List<Map<String, dynamic>> notifications,
  ) async {
    final snapshot = await stream.first;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      notifications.add({
        ...data,
        'id': doc.id,
        'source': 'Bookings',
        'timestamp': data['timestamp'] ?? Timestamp.now(),
        'type': 'booking',
        'serviceName': data['serviceName'] ?? 'Unknown Service',
        'address': data['address'] ?? 'No address provided',
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  Widget _getNotificationIcon(String type) {
    const iconSize = 24.0;
    final iconData = switch (type) {
      'approval' => Icons.check_circle,
      'rejection' => Icons.cancel,
      'payout' => Icons.currency_rupee,
      'booking' => Icons.calendar_today,
      _ => Icons.message,
    };

    final color = switch (type) {
      'approval' => Colors.green,
      'rejection' => Colors.red,
      'payout' => Colors.purple,
      'booking' => Colors.orange,
      _ => Colors.blue,
    };

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color, size: iconSize),
    );
  }

  String _getNotificationTitle(Map<String, dynamic> data) {
    return switch (data['source']) {
      'Supplier Issues Replies' =>
        data['replyText']?.toString() ?? "No message available",
      'Services' => data['serviceName']?.toString() ?? "No Service Name",
      'Payout Requests' =>
        "Payout Request: ₹${(data['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
      'Bookings' => "New Booking: ${data['serviceName']} at ${data['address']}",
      _ => "New Notification",
    };
  }

  String _getNotificationCategory(Map<String, dynamic> data) {
    return switch (data['source']) {
      'Supplier Issues Replies' => data['category']?.toString() ?? "General",
      'Services' =>
        data['status'] == 'Approved' ? "Service Approved" : "Service Rejected",
      'Payout Requests' => "Payout Request",
      'Bookings' => "New Booking",
      _ => "Notification",
    };
  }

  Widget _buildNotificationItem(
      BuildContext context, Map<String, dynamic> data, int index) {
    final category = _getNotificationCategory(data);
    final title = _getNotificationTitle(data);
    final date = _formatTimestamp(data['timestamp'] as Timestamp);

    return FadeInUp(
      duration: Duration(milliseconds: 300 + (index * 50)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNotificationTap(data),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getNotificationIcon(data['type'] as String),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (data['isUnread'] == true)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'payout':
        // Navigate to payout details
        break;
      case 'approval':
      case 'rejection':
        // Navigate to service details
        break;
      case 'reply':
        // Navigate to conversation
        break;
      case 'booking':
        // Navigate to booking details
        break;
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _applyFilter(String? type) {
    setState(() {
      _filterType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fetchAllNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.redAccent));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      "Failed to load notifications",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    TextButton(
                      onPressed: _refreshNotifications,
                      child: Text("Try Again"),
                    ),
                  ],
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_on, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      _filterType != null
                          ? "No ${_getFilterName(_filterType!)} notifications"
                          : "No notifications yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: notifications.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= notifications.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildNotificationItem(
                    context, notifications[index], index);
              },
            );
          },
        ),
      ),
    );
  }

  String _getFilterName(String type) {
    return switch (type) {
      'reply' => 'message',
      'approval' => 'approval',
      'rejection' => 'rejection',
      'payout' => 'payout',
      'booking' => 'booking',
      _ => '',
    };
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Filter Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              ListTile(
                leading: Icon(Icons.clear_all, color: Colors.grey),
                title: Text("All Notifications"),
                onTap: () {
                  _applyFilter(null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.blue),
                title: Text("Messages"),
                onTap: () {
                  _applyFilter('reply');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text("Approvals"),
                onTap: () {
                  _applyFilter('approval');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text("Rejections"),
                onTap: () {
                  _applyFilter('rejection');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.currency_rupee, color: Colors.purple),
                title: Text("Payouts"),
                onTap: () {
                  _applyFilter('payout');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.orange),
                title: Text("Bookings"),
                onTap: () {
                  _applyFilter('booking');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
