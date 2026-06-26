import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceName;
  final String category;
  final String description;
  final double price;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormatted =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(price);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Details"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                serviceName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),

            // Category chip
            Chip(
              label: Text(
                category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              backgroundColor: theme.primaryColor,
              side: BorderSide.none,
            ),

            const SizedBox(height: 24),

            // Price card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 28,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      priceFormatted,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Description section
            Text(
              "Description",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 24),

            // Additional details section
            Text(
              "Service Details",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              context,
              icon: Icons.miscellaneous_services,
              title: "Service Type",
              value: serviceName,
            ),

            const SizedBox(height: 12),

            _buildDetailCard(
              context,
              icon: Icons.category,
              title: "Category",
              value: category,
            ),

            // Action button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking action
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example of navigating to the ServiceDetailsScreen
void navigateToServiceDetails(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ServiceDetailsScreen(
        serviceName: 'Plumbing Service',
        category: 'Home Repair',
        description:
            'Reliable and fast plumbing service with 24/7 availability. Our certified plumbers can handle everything from leaky faucets to complete pipe replacements. We guarantee quality workmanship and use only premium materials.',
        price: 1999.99,
      ),
    ),
  );
}
