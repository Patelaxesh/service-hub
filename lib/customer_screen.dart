import 'package:flutter/material.dart';
import 'customer_login_screen.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerLoginScreen(
      uid: '',
    ); // Directly showing login screen
  }
}
