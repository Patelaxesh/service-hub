import 'package:flutter/material.dart';

class CustomerHelpSupportPage extends StatelessWidget {
  const CustomerHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Section
            Text(
              'Contact Support',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
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
                      title: Text('How to book a service?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'You can browse available services, select a provider, and confirm your booking through the app.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.help, color: Colors.green),
                      title: Text('How to become a service provider?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Register as a provider, submit required details, and get verified to start offering services.'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.help, color: Colors.green),
                      title: Text('How to report an issue?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Go to the "Report Issue" section and submit the problem with relevant details.'),
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
