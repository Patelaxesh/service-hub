import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard functionality

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceName;
  final String category;
  final String supplierName;
  final String supplierContact;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.category,
    required this.supplierName,
    required this.supplierContact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Details"),
        backgroundColor: Colors.lightBlue,
        // The back button is automatically included in the app bar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Service Details",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(
              "Service Name",
              serviceName,
              Icons.miscellaneous_services,
              context,
            ),
            const Divider(thickness: 1.0),
            _buildDetailRow(
              "Category",
              category,
              Icons.category,
              context,
            ),
            const Divider(thickness: 1.0),
            const SizedBox(height: 16.0),
            const Text(
              "Supplier Details",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(
              "Name",
              supplierName,
              Icons.person,
              context,
            ),
            const Divider(thickness: 1.0),
            _buildDetailRow(
              "Contact",
              supplierContact,
              Icons.phone,
              context,
              isContact: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, BuildContext context,
      {bool isContact = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.lightBlue, // Set the icon color to light blue
            size: 24.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : "Not available",
              style: const TextStyle(fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (isContact && value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, size: 20.0),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Contact copied to clipboard"),
                    backgroundColor:
                        Colors.green, // Green background for SnackBar
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
