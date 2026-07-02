import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupplierAddServiceScreen extends StatefulWidget {
  final String supplierId;
  final Map<String, dynamic>? supplierData;

  const SupplierAddServiceScreen({
    super.key,
    required this.supplierId,
    this.supplierData,
  });

  @override
  State<SupplierAddServiceScreen> createState() =>
      _SupplierAddServiceScreenState();
}

class _SupplierAddServiceScreenState extends State<SupplierAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pricingController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();

  String? _selectedCategory;
  late Future<List<String>> _categoriesFuture;
  bool _isUploading = false;

  // Consistent Premium Design System Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red

  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    // Safely assign categories future once to prevent rebuilding on keyboard pop up
    _categoriesFuture = _fetchCategories();

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
      _showErrorDialog("Failed to initialize system application categories.");
      return [];
    }
  }

  Future<void> _saveService() async {
    if (_formKey.currentState?.validate() ?? false) {
      _showConfirmationDialog();
    }
  }

  Future<void> _uploadService() async {
    setState(() => _isUploading = true);
    try {
      await FirebaseFirestore.instance
          .collection('Suppliers')
          .doc(widget.supplierId)
          .collection('addservices')
          .add({
        'serviceName': _serviceNameController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'pricing': double.parse(_pricingController.text.trim()),
        'supplierName': _supplierNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _contactController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Service registered successfully!",
                style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog("Failed to commit service profile schema to storage.");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBgColor,
        surfaceTintColor: Colors.transparent,
        title: const Text("Error Encountered",
            style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBgColor,
        surfaceTintColor: Colors.transparent,
        title: const Text("Confirm Service Entry",
            style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
        content: const Text(
            "Are you sure you want to deploy this service profile data live?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _uploadService();
            },
            child: const Text("Confirm",
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Add Service",
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
          : FutureBuilder<List<String>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor)));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                      child: Text("Failed to load category dependencies.",
                          style: TextStyle(
                              color: textMuted, fontWeight: FontWeight.w500)));
                }

                final categories = snapshot.data!;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Information Section
                        const Text(
                          "Service Details",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumField(
                          label: "Service Name",
                          controller: _serviceNameController,
                          hint: "e.g., Wedding Photography",
                          icon: Icons.work_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildCategoryDropdown(categories),
                        const SizedBox(height: 14),
                        _buildPremiumField(
                          label: "Description",
                          controller: _descriptionController,
                          hint:
                              "Describe your service parameters in full detail...",
                          maxLines: 4,
                          icon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildPremiumField(
                          label: "Pricing",
                          controller: _pricingController,
                          hint: "0.00",
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          icon: Icons.currency_rupee_rounded,
                          prefixText: "₹ ",
                        ),

                        // Supplier Information Section
                        const SizedBox(height: 28),
                        const Text(
                          "Supplier Details",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumField(
                          label: "Your Full Name",
                          controller: _supplierNameController,
                          hint: "e.g., Rahul Sharma",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildPremiumField(
                          label: "Business Name",
                          controller: _businessNameController,
                          hint: "e.g., Sharma Studio Designs",
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildPremiumField(
                          label: "Email",
                          controller: _emailController,
                          hint: "e.g., rahul@example.com",
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildPremiumField(
                          label: "Contact Number",
                          controller: _contactController,
                          hint: "e.g., 9876543210",
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_android_rounded,
                        ),

                        // Submit Button
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "SAVE SERVICE DATA",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5),
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

  Widget _buildPremiumField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
          fontSize: 14.5, color: textDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted, fontSize: 13.5),
        labelStyle: const TextStyle(
            color: textMuted, fontWeight: FontWeight.w600, fontSize: 14),
        prefixIcon:
            icon != null ? Icon(icon, size: 20, color: textMuted) : null,
        prefixText: prefixText,
        prefixStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: textDark),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter $label.";
        }
        if (label == "Pricing") {
          final price = double.tryParse(value.trim());
          if (price == null || price < 0) {
            return "Please enter a valid positive number.";
          }
        }
        if (label == "Email" && !value.contains('@')) {
          return "Please enter a valid email address.";
        }
        if (label == "Contact Number" && value.trim().length < 10) {
          return "Please enter a valid contact number (at least 10 digits).";
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(List<String> categories) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w500)),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      dropdownColor: Colors.white,
      style: const TextStyle(color: textDark),
      decoration: InputDecoration(
        labelText: "Category",
        labelStyle: const TextStyle(
            color: textMuted, fontWeight: FontWeight.w600, fontSize: 14),
        prefixIcon:
            const Icon(Icons.category_outlined, size: 20, color: textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor)),
      ),
      validator: (value) {
        if (value == null) {
          return "Please select a category.";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _pricingController.dispose();
    _supplierNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }
}
