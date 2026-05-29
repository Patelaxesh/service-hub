import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; // For combining streams

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NotificationsScreen(),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Notification"),
          backgroundColor: Colors.lightBlue, // Set solid light blue color
          elevation: 4,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Issues'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IssuesTab(), // Issues content
            _FeedbackTab(), // Feedback content
          ],
        ),
      ),
    );
  }
}

// Issues Tab
class _IssuesTab extends StatelessWidget {
  const _IssuesTab();

  @override
  Widget build(BuildContext context) {
    return _buildCombinedIssueList();
  }
}

// Feedback Tab
class _FeedbackTab extends StatelessWidget {
  const _FeedbackTab();

  @override
  Widget build(BuildContext context) {
    return _buildFeedbackList();
  }
}

// Firestore Service
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getSupplierIssues() {
    return _firestore.collection('Supplier Issues').snapshots();
  }

  Stream<QuerySnapshot> getCustomerIssues() {
    return _firestore.collection('Customer Issues').snapshots();
  }

  Stream<QuerySnapshot> getCustomerFeedback() {
    return _firestore.collection('customer_feedback').snapshots();
  }

  Stream<QuerySnapshot> getSupplierFeedback() {
    return _firestore.collection('supplier_feedback').snapshots();
  }

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

// Reusable Issue Card Widget
class IssueCard extends StatelessWidget {
  final QueryDocumentSnapshot issue;
  final VoidCallback onReply;

  const IssueCard({required this.issue, required this.onReply, super.key});

  @override
  Widget build(BuildContext context) {
    bool hasReply = issue.data().toString().contains('hasReply')
        ? issue['hasReply']
        : false;
    IconData icon = issue.reference.parent.id == 'Supplier Issues'
        ? Icons.store
        : Icons.person;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 4.0,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue.withOpacity(0.2),
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        title: Text(
          issue['issueType'] ?? "Unknown Issue",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          issue['description'] ?? "No description available",
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        trailing: hasReply
            ? null
            : IconButton(
                icon: const Icon(Icons.reply, color: Colors.green),
                onPressed: onReply,
              ),
      ),
    );
  }
}

// Reusable Feedback Card Widget
class FeedbackCard extends StatelessWidget {
  final QueryDocumentSnapshot feedback;

  const FeedbackCard({required this.feedback, super.key});

  @override
  Widget build(BuildContext context) {
    IconData icon = feedback.reference.parent.id == 'supplier_feedback'
        ? Icons.store
        : Icons.person;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 4.0,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue.withOpacity(0.2),
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        title: Text(
          feedback['feedback'] ?? "No feedback available",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// Combined Issues List with Pull-to-Refresh
Widget _buildCombinedIssueList() {
  final FirestoreService firestoreService = FirestoreService();

  return RefreshIndicator(
    onRefresh: () async {
      // Implement refresh logic if needed
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
          return _buildLoadingShimmer();
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Something went wrong. Try again later.",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Retry logic
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        List<QueryDocumentSnapshot> allIssues = [];
        allIssues.addAll(snapshot.data![0].docs);
        allIssues.addAll(snapshot.data![1].docs);

        if (allIssues.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: allIssues.length,
          itemBuilder: (context, index) {
            var issue = allIssues[index];
            return IssueCard(
              issue: issue,
              onReply: () {
                _showReplyDialog(context, issue.id, issue.reference.parent.id);
              },
            );
          },
        );
      },
    ),
  );
}

// Feedback List
Widget _buildFeedbackList() {
  final FirestoreService firestoreService = FirestoreService();

  return StreamBuilder(
    stream: CombineLatestStream.combine2(
      firestoreService.getCustomerFeedback(),
      firestoreService.getSupplierFeedback(),
      (customerFeedbackSnapshot, supplierFeedbackSnapshot) =>
          [customerFeedbackSnapshot, supplierFeedbackSnapshot],
    ),
    builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingShimmer();
      }
      if (snapshot.hasError) {
        return Center(
          child: Text(
            "Something went wrong. Try again later.",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      }

      List<QueryDocumentSnapshot> allFeedback = [];
      allFeedback.addAll(snapshot.data![0].docs);
      allFeedback.addAll(snapshot.data![1].docs);

      if (allFeedback.isEmpty) {
        return const Center(
          child: Text(
            "No Feedback Found",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: allFeedback.length,
        itemBuilder: (context, index) {
          var feedback = allFeedback[index];
          return FeedbackCard(feedback: feedback);
        },
      );
    },
  );
}

// Loading Shimmer Effect
Widget _buildLoadingShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(10),
    itemCount: 5,
    itemBuilder: (context, index) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        elevation: 4.0,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
          ),
          title: Container(
            width: double.infinity,
            height: 16,
            color: Colors.grey.shade300,
          ),
          subtitle: Container(
            width: double.infinity,
            height: 14,
            color: Colors.grey.shade300,
          ),
        ),
      );
    },
  );
}

// Empty State Widget
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/no_issues.png', width: 150, height: 150),
        const SizedBox(height: 10),
        const Text(
          "No Issues Found",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    ),
  );
}

// Reply Dialog
void _showReplyDialog(BuildContext context, String issueId, String category) {
  TextEditingController replyController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Reply to Issue"),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: "Enter your reply...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              FirestoreService()
                  .storeReply(issueId, category, replyController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Reply sent successfully!",
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              );
            },
            label: const Text(
              "Send",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
          ),
        ],
      );
    },
  );
}
