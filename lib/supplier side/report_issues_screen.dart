import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportIssuesScreen extends StatefulWidget {
  const ReportIssuesScreen({super.key});

  @override
  State<ReportIssuesScreen> createState() => _ReportIssuesScreenState();
}

class _ReportIssuesScreenState extends State<ReportIssuesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? selectedIssueType;

  final List<String> issueTypes = [
    "Order & Booking Issues",
    "Payment & Earnings Issues",
    "Fraud & Security Issues",
    "Service Issues",
    "Pricing & Commission Issues",
    "Technical Problems",
    "Customer Communication Issues",
    "Registration & Verification Issues",
    "Review & Rating Issues",
    "UI/UX & Accessibility Issues",
    "Other Issues",
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('Supplier Issues').add({
        'issueType': selectedIssueType,
        'description': descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
      _formKey.currentState!.reset();
      setState(() => selectedIssueType = null);
    } catch (e) {
      _showErrorSnackbar("Something went wrong. Please try again.");
      debugPrint("Error submitting issue report: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text("Confirm Submission"),
            content: const Text("Are you sure you want to submit this report?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text("Success"),
          ],
        ),
        content: const Text("Your issue has been reported successfully."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Issue"),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "File a Complaint or Report an Issue",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select the issue type and provide details below:",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown for Issue Type
                  DropdownButtonFormField<String>(
                    value: selectedIssueType,
                    items: issueTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: "Issue Type",
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.report_problem,
                          color: Colors.redAccent),
                    ),
                    validator: (value) =>
                        value == null ? "Please select an issue type" : null,
                    onChanged: (value) =>
                        setState(() => selectedIssueType = value),
                  ),
                  const SizedBox(height: 16),

                  // Description Field with Validation
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    maxLength: 500, // Character limit
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Provide details of the issue...",
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description,
                          color: Colors.redAccent),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Description is required" : null,
                  ),
                  const SizedBox(height: 16),

                  // Submit Button with Loading State
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(width: 10),
                                Text("Submitting...",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            )
                          : const Text(
                              "Submit Report",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
