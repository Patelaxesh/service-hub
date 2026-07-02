import 'package:flutter/material.dart';

class CustomerAboutUsScreen extends StatelessWidget {
  const CustomerAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Service Hub'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.business_center, size: 60, color: Colors.green),
                  SizedBox(height: 10),
                  Text(
                    'Welcome to Service Hub',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Connecting People, Services, and Opportunities for a Seamless Experience',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'What is Service Hub?',
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
                child: Text(
                  'Service Hub is a platform that bridges the gap between service providers and customers globally. Whether you are looking for services or offering them, Service Hub makes the process easy, fast, and reliable.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Our Mission & Vision',
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
                child: Text(
                  'Our mission is to simplify service access and create a seamless connection between providers and customers. We envision a world where services are just a tap away, fostering growth and accessibility for all.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Key Features',
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
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Easy Booking of Services'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Verified Service Providers'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Fast and Reliable Connections'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'App Version & Developer Info',
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
                      leading: Icon(Icons.info, color: Colors.green),
                      title: Text('Version: 1.0.0'),
                    ),
                    ListTile(
                      leading: Icon(Icons.developer_mode, color: Colors.green),
                      title: Text('Developed by Axesh Patel'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
