import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class RatingsAndReviewsScreen extends StatelessWidget {
  RatingsAndReviewsScreen({super.key});

  // Map of star ratings to their descriptions
  final Map<int, String> ratingDescriptions = {
    5: "Outstanding",
    4: "Excellent",
    3: "Good",
    2: "Fair",
    1: "Poor",
  };

  // Reference to the feedback collection in Firestore
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('feedback');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ratings and Reviews"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ratings Overview Section
            const Text(
              "Ratings Overview",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // StreamBuilder for ratings overview
            StreamBuilder<QuerySnapshot>(
              stream: feedbackCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading reviews');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerRatingsOverview();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No ratings yet');
                }

                return _buildRatingsOverview(snapshot.data!.docs);
              },
            ),
            const SizedBox(height: 24.0),

            // Customer Feedback Section
            const Text(
              "Customer Feedback",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Feedback List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: feedbackCollection.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error loading feedback');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerFeedbackList();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No feedback yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      return _buildFeedbackCard(doc);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsOverview(List<QueryDocumentSnapshot> feedbacks) {
    // Calculate star distribution
    Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var doc in feedbacks) {
      int rating = doc['rating'] ?? 0;
      if (rating >= 1 && rating <= 5) {
        starCounts[rating] = starCounts[rating]! + 1;
      }
    }

    int totalRatings = starCounts.values.reduce((a, b) => a + b);
    double averageRating = (starCounts.entries
        .map((entry) => entry.key * entry.value)
        .reduce((a, b) => a + b)) /
        totalRatings;

    return Column(
      children: [
        Row(
          children: [
            // Average Rating Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Average Rating",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Star icons
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.yellow[700],
                          size: 28.0,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  "$totalRatings ratings",
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            // Total Reviews
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Total Reviews",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$totalRatings",
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24.0),

        // Star Distribution
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: starCounts.entries.map((entry) {
            int stars = entry.key;
            int count = entry.value;
            double percentage = count / totalRatings;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    "$stars stars",
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Stack(
                      children: [
                        // Background bar
                        Container(
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        // Filled bar
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    "$count",
                    style: const TextStyle(
                        fontSize: 14.0, color: Colors.black54),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(QueryDocumentSnapshot doc) {
    final feedback = doc['feedbackText'] ?? '';
    final serviceProvider = doc['serviceProvider'] ?? 'Anonymous';
    final rating = doc['rating'] ?? 0;
    final serviceName = doc['serviceName'] ?? 'Service';
    final createdAt = doc['createdAt'] as Timestamp?;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name and Rating with Description
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceProvider,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      "$rating.0 ⭐ (${ratingDescriptions[rating]!})",
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Service: $serviceName",
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt.toDate()),
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Feedback Text
            Text(
              feedback,
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildShimmerRatingsOverview() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Container(
                            width: 28,
                            height: 28,
                            color: Colors.white,
                            margin: const EdgeInsets.only(right: 4),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerFeedbackList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120,
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}