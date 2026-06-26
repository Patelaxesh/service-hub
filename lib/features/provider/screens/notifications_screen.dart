import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String?
      _filterType; // 'reply', 'approval', 'rejection', 'payout', 'booking', or null for all

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

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

  Future<void> _processSupplierReplies(Stream<QuerySnapshot> stream,
      List<Map<String, dynamic>> notifications) async {
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

  Future<void> _processServices(Stream<QuerySnapshot> stream,
      List<Map<String, dynamic>> notifications) async {
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

  Future<void> _processPayoutRequests(Stream<QuerySnapshot> stream,
      List<Map<String, dynamic>> notifications) async {
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

  Future<void> _processBookings(Stream<QuerySnapshot> stream,
      List<Map<String, dynamic>> notifications) async {
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
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  // Returns "Today", "Yesterday", or "dd MMM yyyy" group string
  String _getDateBucket(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return "Today";
    } else if (checkDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Widget _getNotificationIcon(String type) {
    final iconData = switch (type) {
      'approval' => Icons.check_circle_outline_rounded,
      'rejection' => Icons.highlight_off_rounded,
      'payout' => Icons.account_balance_wallet_outlined,
      'booking' => Icons.calendar_today_rounded,
      _ => Icons.mail_outline_rounded,
    };

    final color = switch (type) {
      'approval' => Colors.green,
      'rejection' => primaryColor,
      'payout' => Colors.blue,
      'booking' => Colors.orange,
      _ => Colors.indigo,
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 22),
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
      'Supplier Issues Replies' =>
        data['category']?.toString() ?? "General Feedback",
      'Services' =>
        data['status'] == 'Approved' ? "Service Approved" : "Service Rejected",
      'Payout Requests' => "Payout Request Status",
      'Bookings' => "Booking Request Recieved",
      _ => "Notification",
    };
  }

  Widget _buildNotificationItem(
      BuildContext context, Map<String, dynamic> data, int index) {
    final category = _getNotificationCategory(data);
    final title = _getNotificationTitle(data);
    final timeStr = _formatTimestamp(data['timestamp'] as Timestamp);

    return FadeInUp(
      duration: Duration(milliseconds: 250 + (index * 40)),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getNotificationIcon(data['type'] as String),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (data['isUnread'] == true) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _applyFilter(String? type) {
    setState(() {
      _filterType = type;
    });
  }

  Future<void> _refreshNotifications() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Notifications",
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
            icon: const Icon(Icons.filter_list_rounded, size: 22),
            onPressed: () => _showFilterOptions(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _refreshNotifications,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fetchAllNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: primaryColor));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: primaryColor, size: 44),
                    const SizedBox(height: 14),
                    const Text("Failed to load notifications",
                        style: TextStyle(
                            fontSize: 15,
                            color: textDark,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _refreshNotifications,
                      child: const Text("Try Again",
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700)),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                          color: accentColor, shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_off_outlined,
                          size: 40, color: primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _filterType != null
                          ? "No matching updates found"
                          : "No updates yet",
                      style: const TextStyle(
                          fontSize: 15,
                          color: textMuted,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            // Grouping lists sequentially into Date Buckets
            final Map<String, List<Map<String, dynamic>>> groupedNotifications =
                {};
            for (var item in notifications) {
              final bucketName = _getDateBucket(item['timestamp'] as Timestamp);
              groupedNotifications.putIfAbsent(bucketName, () => []).add(item);
            }

            final List<String> dateBuckets = groupedNotifications.keys.toList();

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              itemCount: dateBuckets.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= dateBuckets.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                        child: CircularProgressIndicator(color: primaryColor)),
                  );
                }

                final bucketTitle = dateBuckets[index];
                final bucketItems = groupedNotifications[bucketTitle]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 4.0, bottom: 12.0, top: 8.0),
                      child: Text(
                        bucketTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...bucketItems.asMap().entries.map((entry) {
                      return _buildNotificationItem(
                          context, entry.value, entry.key);
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBgColor,
      //surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Filter Updates",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textDark)),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFEEEEEE)),
                _buildFilterTile(null, "All Notifications",
                    Icons.clear_all_rounded, Colors.grey),
                _buildFilterTile('reply', "Messages & Support",
                    Icons.chat_bubble_outline_rounded, Colors.indigo),
                _buildFilterTile('approval', "Approvals",
                    Icons.check_circle_outline_rounded, Colors.green),
                _buildFilterTile('rejection', "Rejections",
                    Icons.highlight_off_rounded, primaryColor),
                _buildFilterTile('payout', "Payout Activity",
                    Icons.account_balance_wallet_outlined, Colors.blue),
                _buildFilterTile('booking', "Bookings",
                    Icons.calendar_today_rounded, Colors.orange),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTile(
      String? type, String label, IconData icon, Color itemColor) {
    final isSelected = _filterType == type;
    return ListTile(
      dense: true,
      leading:
          Icon(icon, color: isSelected ? primaryColor : itemColor, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? primaryColor : textDark,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: primaryColor, size: 18)
          : null,
      onTap: () {
        _applyFilter(type);
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Global alternative extension initialization for custom accent references
extension on Colors {
  static const Color blueRadius = Color(0xFF1E88E5);
}
