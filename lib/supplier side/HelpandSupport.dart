import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier Support Section
            Text(
              'Supplier Support',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.green),
                      title: Text('Email: support@servicehub.com'),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text('Phone: +91 8849590527'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // FAQs Section
            Text(
              'Frequently Asked Questions (FAQs)',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ExpansionTile(
                      leading: Icon(Icons.help, color: Colors.green),
                      title: Text('How to list my services?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Go to "Add Service" in your dashboard, fill in the required details, and submit for approval.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.help, color: Colors.green),
                      title: Text('How to manage bookings?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Check your "Bookings" section to view, accept, or decline customer requests.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.help, color: Colors.green),
                      title: Text('How to withdraw my earnings?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Go to "Earnings", link your bank account, and request a withdrawal. Payments are processed within 3-5 business days.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.help, color: Colors.green),
                      title: Text('How to update my profile details?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Navigate to "Profile" and edit your details such as business name, contact info, and services offered.'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
