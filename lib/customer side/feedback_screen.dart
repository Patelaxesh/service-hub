import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_history_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final String serviceName;
  final String serviceProvider;

  const FeedbackScreen({
    super.key,
    required this.serviceName,
    required this.serviceProvider,
  });

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Validate input
    if (_feedbackController.text.isEmpty) {
      _showErrorSnackbar("Please write your feedback");
      return;
    }

    if (_rating == 0) {
      _showErrorSnackbar("Please select a rating");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create feedback document
      await _firestore.collection('feedback').add({
        'serviceName': widget.serviceName,
        'serviceProvider': widget.serviceProvider,
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackbar("Thank you for your feedback!");

      // Navigate back to order history
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderHistoryScreen(),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackbar("Failed to submit feedback: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info
            _buildServiceInfo(),
            const SizedBox(height: 24.0),

            // Feedback Input
            _buildFeedbackInput(),
            const SizedBox(height: 24.0),

            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: 32.0),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your feedback helps us improve",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          widget.serviceName,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          "Provided by: ${widget.serviceProvider}",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Feedback",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _feedbackController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: "What did you like or how can we improve?",
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          maxLines: 5,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How would you rate this service?",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12.0),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 40.0,
                  color: Colors.amber,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
        ),
        if (_rating > 0) ...[
          const SizedBox(height: 8.0),
          Center(
            child: Text(
              _rating == 1
                  ? "Poor"
                  : _rating == 2
                  ? "Fair"
                  : _rating == 3
                  ? "Good"
                  : _rating == 4
                  ? "Very Good"
                  : "Excellent",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : const Text(
          "Submit Feedback",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}