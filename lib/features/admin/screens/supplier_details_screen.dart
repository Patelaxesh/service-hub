import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final String supplierName;
  final String email;
  final String contactNumber;
  final String country;
  final String state;
  final String city;

  const SupplierDetailsScreen({
    super.key,
    required this.supplierName,
    required this.email,
    required this.contactNumber,
    required this.country,
    required this.state,
    required this.city,
    required services,
  });

  @override
  Widget build(BuildContext context) {
    final fullAddress = "$city, $state, $country";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Details"),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        //centerTitle: true,
        //iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24.0),

            // Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.email_outlined, "Email", email),
                    const Divider(height: 24, thickness: 0.5),
                    _buildDetailRow(
                        Icons.phone_outlined, "Phone", contactNumber),
                    const Divider(height: 24, thickness: 0.5),
                    _buildDetailRow(
                        Icons.location_on_outlined, "Address", fullAddress),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text("Send Email"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _sendEmail(email),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call_outlined),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _makeCall(contactNumber),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade100,
              border: Border.all(
                color: Colors.blue.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                supplierName.isNotEmpty ? supplierName[0].toUpperCase() : "?",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Supplier Name
          Text(
            supplierName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Supplier Type or other info could go here
          Text(
            "Verified Supplier",
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade800, size: 20),
        ),
        const SizedBox(width: 16),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Inquiry&body=Hello,'),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $emailUri");
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $phoneUri");
    }
  }
}
