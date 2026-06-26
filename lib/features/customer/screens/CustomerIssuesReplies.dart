import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class CustomerIssuesRepliesScreen extends StatefulWidget {
  @override
  _CustomerIssuesRepliesScreenState createState() =>
      _CustomerIssuesRepliesScreenState();
}

class _CustomerIssuesRepliesScreenState
    extends State<CustomerIssuesRepliesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  // Memoized function to prevent unnecessary rebuilds
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            "Loading Notifications...",
            style: TextStyle(color: Colors.greenAccent, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            "Failed to load notifications",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, color: Colors.greenAccent, size: 48),
          SizedBox(height: 16),
          Text(
            "No Notifications Yet",
            style: TextStyle(color: Colors.greenAccent, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            "Replies and completed services will appear here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, int index) {
    final bool isReply = data['type'] == 'reply';
    final Color primaryColor = isReply ? Colors.teal : Colors.blue;
    final IconData icon =
        isReply ? Icons.admin_panel_settings : Icons.check_circle_outline;
    final String title =
        isReply ? data['category'] ?? "General Inquiry" : "Service Completed";
    final String content = isReply
        ? data['replyText'] ?? "No reply content available"
        : "${data['serviceName'] ?? 'Service'} completed by ${data['serviceProvider'] ?? 'service provider'}";
    final String statusText = isReply ? "Admin Response" : "Completed";

    return FadeInUp(
      duration: Duration(milliseconds: 300 + (index * 50)),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: primaryColor, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[200]),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    _formatTimestamp(data['timestamp']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  Icon(
                    isReply ? Icons.verified : Icons.done_all,
                    size: 16,
                    color: primaryColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 12, color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.teal),
            SizedBox(width: 12),
            Text("Notifications"),
          ],
        ),
        backgroundColor: Colors.greenAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Customer Issues Replies').snapshots(),
        builder: (context, repliesSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('bookings')
                .where('status', isEqualTo: 'completed')
                .snapshots(),
            builder: (context, bookingsSnapshot) {
              // Handle loading state
              if (repliesSnapshot.connectionState == ConnectionState.waiting ||
                  bookingsSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }

              // Handle errors
              if (repliesSnapshot.hasError) {
                return _buildErrorWidget(repliesSnapshot.error.toString());
              }
              if (bookingsSnapshot.hasError) {
                return _buildErrorWidget(bookingsSnapshot.error.toString());
              }

              // Process data
              final List<Map<String, dynamic>> allNotifications = [
                ...repliesSnapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {...data, 'type': 'reply'};
                    }) ??
                    [],
                ...bookingsSnapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {...data, 'type': 'booking'};
                    }) ??
                    [],
              ];

              // Sort by timestamp
              allNotifications.sort((a, b) {
                final aTime = a['timestamp'] ?? Timestamp.now();
                final bTime = b['timestamp'] ?? Timestamp.now();
                return bTime.compareTo(aTime);
              });

              // Handle empty state
              if (allNotifications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 1));
                },
                child: ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: allNotifications.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(
                        allNotifications[index], index);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
