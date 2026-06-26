import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor =
      Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

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

      if (mounted) _showSuccessDialog();
      _formKey.currentState!.reset();
      setState(() => selectedIssueType = null);
    } catch (e) {
      _showErrorSnackbar("Something went wrong. Please try again.");
      debugPrint("Error submitting issue report: $e");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cardBgColor,
            surfaceTintColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              "Confirm Submission",
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
            ),
            content: const Text(
              "Are you sure you want to submit this report?",
              style: TextStyle(color: textMuted, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
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
        backgroundColor: cardBgColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text(
              "Success",
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
            ),
          ],
        ),
        content: const Text(
          "Your issue has been reported successfully.",
          style: TextStyle(color: textMuted, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Report Issue",
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("File a Complaint"),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 24.0),
                  child: Text(
                    "Select the issue type and provide details below:",
                    style: TextStyle(
                        fontSize: 14.5,
                        color: textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                ),

                // Dropdown Wrap Card
                _buildInfoCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedIssueType,
                    dropdownColor: cardBgColor,
                    style: const TextStyle(
                        fontSize: 14.5,
                        color: textDark,
                        fontWeight: FontWeight.w600),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: textMuted),
                    items: issueTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: "Issue Type",
                      labelStyle: TextStyle(
                          color: textMuted, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.report_problem_outlined,
                          color: primaryColor, size: 22),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    validator: (value) =>
                        value == null ? "Please select an issue type" : null,
                    onChanged: (value) =>
                        setState(() => selectedIssueType = value),
                  ),
                ),

                // Description Wrap Card
                _buildInfoCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    style: const TextStyle(
                        fontSize: 14.5,
                        color: textDark,
                        fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(
                          color: textMuted, fontWeight: FontWeight.w500),
                      hintText: "Provide clear details of the issue...",
                      hintStyle: TextStyle(color: textMuted, fontSize: 13.5),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.description_outlined,
                          color: primaryColor, size: 22),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      counterStyle: TextStyle(
                          color: textMuted, fontWeight: FontWeight.bold),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Description is required" : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Submit Report",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textDark,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required Widget child,
      EdgeInsets padding = const EdgeInsets.all(16.0)}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: padding,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
