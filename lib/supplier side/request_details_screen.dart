import 'package:flutter/material.dart';

class RequestDetailsScreen extends StatelessWidget {
  final String customerName;
  final String serviceName;
  final String dateTime;
  final String paymentStatus;

  const RequestDetailsScreen({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.dateTime,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Information",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildDetailRow("Name", customerName, Icons.person, context),
            const Divider(thickness: 1.0),
            const SizedBox(height: 16.0),
            const Text(
              "Service Details",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildDetailRow(
                "Service", serviceName, Icons.miscellaneous_services, context),
            const Divider(thickness: 1.0),
            const SizedBox(height: 16.0),
            const Text(
              "Date and Time",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildDetailRow("Date", dateTime, Icons.calendar_today, context),
            const Divider(thickness: 1.0),
            const SizedBox(height: 16.0),
            const Text(
              "Payment Status",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildDetailRow(
              "Status",
              paymentStatus,
              Icons.payment,
              context,
              isPayment: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, BuildContext context,
      {bool isPayment = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.redAccent,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
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
              style: TextStyle(
                fontSize: 16.0,
                color: isPayment
                    ? (value == "Paid" ? Colors.green : Colors.red)
                    : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
