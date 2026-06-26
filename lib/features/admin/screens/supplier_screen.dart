import 'package:flutter/material.dart';
import 'package:serviceshub/features/admin/screens/supplier_login_screen.dart';


class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to the SupplierLoginScreen immediately after this screen is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SupplierLoginScreen()),
      );
    });

    // Display a placeholder UI while navigating to the SupplierLoginScreen.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
