import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Ultra light layout background
      appBar: AppBar(
        title: const Text(
          "Ratings & Reviews",
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Ratings Overview"),

            // StreamBuilder for ratings overview
            StreamBuilder<QuerySnapshot>(
              stream: feedbackCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Error loading reviews',
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerRatingsOverview();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildInfoCard(
                    child: const Center(
                      child: Text('No ratings yet available.',
                          style: TextStyle(
                              color: textMuted, fontWeight: FontWeight.w600)),
                    ),
                  );
                }

                return _buildRatingsOverview(snapshot.data!.docs);
              },
            ),
            const SizedBox(height: 12),

            _buildSectionTitle("Customer Feedback"),

            // Feedback List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: feedbackCollection
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading feedback',
                            style: TextStyle(color: primaryColor)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerFeedbackList();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No feedback posted yet.',
                          style: TextStyle(
                              color: textMuted, fontWeight: FontWeight.w600)),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
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
    Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var doc in feedbacks) {
      int rating = doc['rating'] ?? 0;
      if (rating >= 1 && rating <= 5) {
        starCounts[rating] = starCounts[rating]! + 1;
      }
    }

    int totalRatings = starCounts.values.reduce((a, b) => a + b);
    double averageRating = totalRatings == 0
        ? 0.0
        : (starCounts.entries
                .map((entry) => entry.key * entry.value)
                .reduce((a, b) => a + b)) /
            totalRatings;

    return _buildInfoCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Average Rating",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 34.0,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFFB300),
                            // Premium Amber/Gold Star
                            size: 22.0,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$totalRatings ratings",
                    style: const TextStyle(
                        fontSize: 12.5,
                        color: textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Total Reviews",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$totalRatings",
                    style: const TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.w800,
                        color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 16.0),

          // Star Distribution List
          Column(
            children: starCounts.entries.map((entry) {
              int stars = entry.key;
              int count = entry.value;
              double percentage =
                  totalRatings == 0 ? 0.0 : count / totalRatings;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        "$stars ★",
                        style: const TextStyle(
                            fontSize: 13.0,
                            color: textDark,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 6.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300),
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    SizedBox(
                      width: 24,
                      child: Text(
                        "$count",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontSize: 13.0,
                            color: textMuted,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(QueryDocumentSnapshot doc) {
    final feedback = doc['feedbackText'] ?? '';
    final serviceProvider = doc['serviceProvider'] ?? 'Anonymous User';
    final rating = doc['rating'] ?? 0;
    final serviceName = doc['serviceName'] ?? 'General Service';
    final createdAt = doc['createdAt'] as Timestamp?;
    final desc = ratingDescriptions[rating] ?? "Rated";

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceProvider,
                style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: textDark),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$rating.0 ★ $desc",
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: primaryColor,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Service: $serviceName",
                style: const TextStyle(
                    fontSize: 13.0,
                    color: textMuted,
                    fontWeight: FontWeight.w600),
              ),
              if (createdAt != null)
                Text(
                  _formatDate(createdAt.toDate()),
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: textMuted,
                      fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: const TextStyle(
                fontSize: 14.0,
                color: textDark,
                height: 1.4,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 14.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShimmerRatingsOverview() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: _buildInfoCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 140,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 20,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerFeedbackList() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
