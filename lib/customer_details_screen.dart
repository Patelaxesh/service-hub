import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerName;
  final String email;
  final String contactNumber;
  final String address;

  const CustomerDetailsScreen({
    super.key,
    required this.customerName,
    required this.email,
    required this.contactNumber,
    required this.address,
  });

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Details"),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        // centerTitle: true,
        // iconTheme: const IconThemeData(color: Colors.white),
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
                        Icons.location_on_outlined, "Address", address),
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
                    onPressed: _sendEmail,
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
                    onPressed: () {
                      final Uri phoneUri = Uri(
                        scheme: 'tel',
                        path: contactNumber,
                      );
                      launchUrl(phoneUri);
                    },
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
                customerName.isNotEmpty ? customerName[0].toUpperCase() : "?",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Customer Name
          Text(
            customerName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
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
}
