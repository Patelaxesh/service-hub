import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddServiceScreen extends StatefulWidget {
  final String supplierId;
  final Map<String, dynamic>? supplierData; // Add supplierData parameter

  const AddServiceScreen({
    super.key,
    required this.supplierId,
    this.supplierData, // Make it optional
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pricingController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  String? _selectedCategory;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill supplier details if available
    if (widget.supplierData != null) {
      _supplierNameController.text = widget.supplierData!['name'] ?? '';
      _emailController.text = widget.supplierData!['email'] ?? '';
      _contactController.text = widget.supplierData!['contact'] ?? '';
      _businessNameController.text = widget.supplierData!['businessName'] ?? '';
    }
  }

  Future<List<String>> _fetchCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => doc['name'].toString()).toList();
    } catch (e) {
      _showErrorDialog("Failed to load categories.");
      return [];
    }
  }

  Future<void> _saveService() async {
    if (_formKey.currentState?.validate() ?? false) {
      _showConfirmationDialog();
    }
  }

  Future<void> _uploadService() async {
    try {
      await FirebaseFirestore.instance
          .collection('Suppliers')
          .doc(widget.supplierId)
          .collection('addservices')
          .add({
        // Service details
        'serviceName': _serviceNameController.text,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'pricing': double.parse(_pricingController.text),

        // Supplier details
        'supplierName': _supplierNameController.text,
        'email': _emailController.text,
        'contact': _contactController.text,
        'businessName': _businessNameController.text,

        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Service added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog("Failed to save service. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text(
          "Are you sure you want to save this service?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.pop(context);
              _uploadService();
            },
            child: const Text(
              "Yes",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter $label.";
            }
            if (label == "Pricing") {
              final price = double.tryParse(value);
              if (price == null || price < 0) {
                return "Please enter a valid positive number.";
              }
            }
            if (label == "Email" && !value.contains('@')) {
              return "Please enter a valid email address.";
            }
            if (label == "Contact" && value.length < 10) {
              return "Please enter a valid contact number (at least 10 digits).";
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Service"),
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load categories."));
          }

          final categories = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Information Section
                  const Text(
                    "Service Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Service Name",
                    _serviceNameController,
                    "e.g., Wedding Photography",
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Category",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Select category",
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Please select a category.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Description",
                    _descriptionController,
                    "Describe your service in detail",
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Pricing (\$)",
                    _pricingController,
                    "e.g., 299.99",
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),

                  // Supplier Information Section
                  const SizedBox(height: 24),
                  const Text(
                    "Supplier Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Your Full Name",
                    _supplierNameController,
                    "e.g., John Smith",
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Business Name",
                    _businessNameController,
                    "e.g., Smith Photography",
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Email",
                    _emailController,
                    "e.g., john@example.com",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    "Contact Number",
                    _contactController,
                    "e.g., 0412345678",
                    keyboardType: TextInputType.phone,
                  ),

                  // Submit Button
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "SAVE SERVICE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
