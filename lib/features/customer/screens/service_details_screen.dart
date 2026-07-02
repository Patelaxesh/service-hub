import 'package:flutter/material.dart';
import 'package:serviceshub/features/customer/screens/customer_cart_screen.dart';
import 'package:serviceshub/features/customer/screens/customer_payment_screen.dart';


class CustomerServiceDetailsScreen extends StatelessWidget {
  final String serviceName;
  final String serviceDescription;
  final double price;
  final String supplierName;
  final String supplierContact;
  final String supplierPhone;

  // Constructor to accept data for the service
  const CustomerServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.serviceDescription,
    required this.price,
    required this.supplierName,
    required this.supplierContact,
    required this.supplierPhone,
    required String categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
        backgroundColor: Colors.greenAccent,
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Name
            Text(
              serviceName,
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, thickness: 1.0),
            // Service Description
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      serviceDescription,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Price
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    //const Icon(Icons.currency_rupee, color: Colors.green),
                    const SizedBox(width: 8.0),
                    Text(
                      "Price: ₹${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Supplier Details
            const Text(
              "Supplier Details",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8.0),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSupplierDetailRow(Icons.person, supplierName),
                    const SizedBox(height: 8.0),
                    _buildSupplierDetailRow(Icons.email, supplierContact),
                    const SizedBox(height: 8.0),
                    _buildSupplierDetailRow(Icons.phone, supplierPhone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // "Add to Cart" Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Create a new item to add to the cart
                  final newItem = {
                    'name': serviceName,
                    'description': serviceDescription,
                    'price': price,
                  };

                  // Navigate to Cart Screen and pass the new item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerCartScreen(
                        initialCartItems: [newItem],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                label: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // "Book Now" Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Payment Screen with service details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerPaymentScreen(
                        serviceName: serviceName,
                        totalAmount:
                            price, // Pass the service price as total amount
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.book_online, color: Colors.black),
                label: const Text(
                  "Book Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build supplier detail rows with icons
  Widget _buildSupplierDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}
