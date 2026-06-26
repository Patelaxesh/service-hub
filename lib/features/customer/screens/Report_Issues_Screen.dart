import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerReportIssuesScreen extends StatefulWidget {
  const CustomerReportIssuesScreen({super.key});

  @override
  State<CustomerReportIssuesScreen> createState() =>
      _CustomerReportIssuesScreenState();
}

class _CustomerReportIssuesScreenState
    extends State<CustomerReportIssuesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedIssueType;

  final List<String> _issueTypes = [
    "Service Quality Issues",
    "Payment & Refund Issues",
    "Fraud & Security Concerns",
    "App Performance Issues",
    "Customer Support Issues",
    "Pricing & Billing Issues",
    "Order & Delivery Issues",
    "Review & Feedback Issues",
    "UI/UX & Accessibility Problems",
    "Other Issues",
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Close the keyboard
    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('Customer Issues').add({
        'issueType': _selectedIssueType,
        'description': _descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
      _formKey.currentState!.reset();
      setState(() => _selectedIssueType = null);
    } catch (e, stackTrace) {
      _showErrorSnackbar("Something went wrong. Please try again.");
      debugPrint("Error submitting issue report: $e\n$stackTrace");
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
                child: const Text("Cancel",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                child: const Text("Submit",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
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
            child: const Text("OK"),
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
        backgroundColor: Colors.greenAccent,
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
                    "Report an Issue",
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
                    value: _selectedIssueType,
                    items: _issueTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: "Issue Type",
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.report_problem, color: Colors.green),
                    ),
                    validator: (value) =>
                        value == null ? "Please select an issue type" : null,
                    onChanged: (value) =>
                        setState(() => _selectedIssueType = value),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Provide details of the issue...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description, color: Colors.green),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Description is required" : null,
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                  color: Colors.black),
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
