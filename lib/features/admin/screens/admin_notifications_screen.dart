import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const AdminNotificationsScreen(),
    );
  }
}

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
// 0 = Issues, 1 = Feedback
  int _selectedTab = 0;

// Filters: 'All', 'Supplier', 'Customer'
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Custom Dashboard-Style Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

// Segmented Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSegmentedTab(
                          title: "Issues",
                          isActive: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildSegmentedTab(
                          title: "Feedback",
                          isActive: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

// Horizontal Filter Chips (All, Supplier, Customer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                children: ['All', 'Supplier', 'Customer'].map((filter) {
                  final bool isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.15),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.blue.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

// Main Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _IssuesTab(filter: _selectedFilter),
                  _FeedbackTab(filter: _selectedFilter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTab(
      {required String title,
      required bool isActive,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ISSUES TAB
// ==========================================
class _IssuesTab extends StatelessWidget {
  final String filter;

  const _IssuesTab({required this.filter});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: StreamBuilder(
        stream: CombineLatestStream.combine2(
          firestoreService.getSupplierIssues(),
          firestoreService.getCustomerIssues(),
          (supplierSnapshot, customerSnapshot) =>
              [supplierSnapshot, customerSnapshot],
        ),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          List<QueryDocumentSnapshot> allIssues = [];
          allIssues.addAll(snapshot.data![0].docs);
          allIssues.addAll(snapshot.data![1].docs);

// Apply Client-side filtering
          if (filter == 'Supplier') {
            allIssues = allIssues
                .where((doc) => doc.reference.parent.id == 'Supplier Issues')
                .toList();
          } else if (filter == 'Customer') {
            allIssues = allIssues
                .where((doc) => doc.reference.parent.id == 'Customer Issues')
                .toList();
          }

          if (allIssues.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: allIssues.length,
            itemBuilder: (context, index) {
              final issue = allIssues[index];
              return IssueCard(
                issue: issue,
                onReply: () => _showReplyBottomSheet(
                    context, issue.id, issue.reference.parent.id),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// FEEDBACK TAB
// ==========================================
class _FeedbackTab extends StatelessWidget {
  final String filter;

  const _FeedbackTab({required this.filter});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: StreamBuilder(
        stream: CombineLatestStream.combine2(
          firestoreService.getCustomerFeedback(),
          firestoreService.getSupplierFeedback(),
          (customerFeedbackSnapshot, supplierFeedbackSnapshot) =>
              [customerFeedbackSnapshot, supplierFeedbackSnapshot],
        ),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          List<QueryDocumentSnapshot> allFeedback = [];
          allFeedback.addAll(snapshot.data![0].docs);
          allFeedback.addAll(snapshot.data![1].docs);

          if (filter == 'Supplier') {
            allFeedback = allFeedback
                .where((doc) => doc.reference.parent.id == 'supplier_feedback')
                .toList();
          } else if (filter == 'Customer') {
            allFeedback = allFeedback
                .where((doc) => doc.reference.parent.id == 'customer_feedback')
                .toList();
          }

          if (allFeedback.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: allFeedback.length,
            itemBuilder: (context, index) {
              return FeedbackCard(feedback: allFeedback[index]);
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// CUSTOM MODERN ISSUE CARD
// ==========================================
class IssueCard extends StatefulWidget {
  final QueryDocumentSnapshot issue;
  final VoidCallback onReply;

  const IssueCard({required this.issue, required this.onReply, super.key});

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.issue.data() as Map<String, dynamic>?;
    final bool hasReply =
        data != null && data.containsKey('hasReply') ? data['hasReply'] : false;
    final bool isSupplier =
        widget.issue.reference.parent.id == 'Supplier Issues';

    final String issueType = data?['issueType'] ?? "Unknown Issue";
    final String description =
        data?['description'] ?? "No description available";
    final String timeText = "Yesterday";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Row 1: User Type Chip & Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSupplier
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSupplier ? "Supplier" : "Customer",
                  style: TextStyle(
                    color: isSupplier
                        ? Colors.blue.shade700
                        : Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasReply
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasReply ? "Replied" : "Pending",
                  style: TextStyle(
                    color: hasReply
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

// Row 2: Title & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  issueType,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
              ),
              Text(
                timeText,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

// Row 3: Description Layout (Max 2 lines + Dynamic Read More)
          Text(
            description,
            maxLines: _isExpanded ? null : 2,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 14, height: 1.4),
          ),

          if (description.length > 80)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _isExpanded ? "Read Less" : "Read More",
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),

// Row 4: Action Button Line
          if (!hasReply) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 38,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: widget.onReply,
                  child: const Text("Reply",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM MODERN FEEDBACK CARD
// ==========================================
class FeedbackCard extends StatelessWidget {
  final QueryDocumentSnapshot feedback;

  const FeedbackCard({required this.feedback, super.key});

  @override
  Widget build(BuildContext context) {
    final data = feedback.data() as Map<String, dynamic>?;
    final bool isSupplier = feedback.reference.parent.id == 'supplier_feedback';
    final String feedbackText = data?['feedback'] ?? "No feedback available";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSupplier
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSupplier ? "Supplier" : "Customer",
                  style: TextStyle(
                    color: isSupplier
                        ? Colors.blue.shade700
                        : Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text("Feedback",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.amber)),
                ],
              )
            ],
          ),
          const SizedBox(height: 14),
          Text(
            feedbackText,
            style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REFACTOR: LOWER DIALOG TO BOTTOM SHEET
// ==========================================
void _showReplyBottomSheet(
    BuildContext context, String issueId, String category) {
  final TextEditingController replyController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Reply to Issue",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: replyController,
              autofocus: true,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your response...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (replyController.text.trim().isNotEmpty) {
                        FirestoreService().storeReply(
                            issueId, category, replyController.text.trim());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Reply sent successfully!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text("Send",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// ==========================================
// STATE & SHIMMER PLACEHOLDERS
// ==========================================
Widget _buildShimmerLoading() {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    itemCount: 3,
    itemBuilder: (context, index) => Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedOpacity(
        opacity: 0.6,
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 16),
              Container(width: 180, height: 22, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.grey.shade200),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none_rounded,
            size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 14),
        const Text(
          "No Notifications Yet",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          "Everything looks clean and handled!",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget _buildErrorState() {
  return Center(
    child: Text(
      "Something went wrong. Try again later.",
      style: TextStyle(
          color: Colors.red.shade400,
          fontSize: 15,
          fontWeight: FontWeight.w500),
    ),
  );
}

// ==========================================
// BACKEND FIRESTORE SERVICES
// ==========================================
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getSupplierIssues() =>
      _firestore.collection('Supplier Issues').snapshots();

  Stream<QuerySnapshot> getCustomerIssues() =>
      _firestore.collection('Customer Issues').snapshots();

  Stream<QuerySnapshot> getCustomerFeedback() =>
      _firestore.collection('customer_feedback').snapshots();

  Stream<QuerySnapshot> getSupplierFeedback() =>
      _firestore.collection('supplier_feedback').snapshots();

  Future<void> storeReply(
      String issueId, String category, String replyText) async {
    if (replyText.isNotEmpty) {
      await _firestore
          .collection(category)
          .doc(issueId)
          .update({'hasReply': true});

      String replyCollection = category == "Supplier Issues"
          ? "Supplier Issues Replies"
          : "Customer Issues Replies";

      await _firestore.collection(replyCollection).add({
        'issueId': issueId,
        'category': category,
        'replyText': replyText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
