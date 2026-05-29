import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceStatus { Pending, Approved, Rejected }

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  _ServiceManagementScreenState createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Service> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('services')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        services = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Service(
            id: doc.id,
            name: data['serviceName'],
            description: data['description'],
            category: data['category'],
            price: data['pricing'],
            supplierName: data['supplierName'] ?? '',
            supplierEmail: data['supplierEmail'] ?? '',
            supplierContact: data['supplierContact'] ?? '',
            businessName: data['businessName'] ?? '',
            status: _parseStatus(data['status']),
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      _showSnackbar("Failed to load services.", Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  ServiceStatus _parseStatus(String status) {
    switch (status) {
      case 'Pending':
        return ServiceStatus.Pending;
      case 'Approved':
        return ServiceStatus.Approved;
      case 'Rejected':
        return ServiceStatus.Rejected;
      default:
        return ServiceStatus.Pending;
    }
  }

  List<Service> getFilteredServices(ServiceStatus status) {
    return services.where((service) => service.status == status).toList();
  }

  List<Service> getActiveServices() {
    return services
        .where((service) => service.status == ServiceStatus.Approved)
        .toList();
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();
      setState(() {
        services.removeWhere((service) => service.id == serviceId);
      });
      _showSnackbar("Service deleted successfully!", Colors.green);
    } catch (e) {
      _showSnackbar("Failed to delete service.", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Management"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddServiceScreen(
                    supplierId: '', // Pass supplierId if needed
                  ),
                ),
              ).then((_) => _fetchServices()); // Refresh services after adding
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildServiceList(getActiveServices()),
                  _buildServiceList(getFilteredServices(ServiceStatus.Pending)),
                  _buildServiceList(
                      getFilteredServices(ServiceStatus.Approved)),
                  _buildServiceList(
                      getFilteredServices(ServiceStatus.Rejected)),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceList(List<Service> services) {
    return services.isEmpty
        ? const Center(child: Text("No services available."))
        : ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailsScreen(
                          serviceName: service.name,
                          category: service.category,
                          description: service.description,
                          price: service.price,
                          supplierName: service.supplierName,
                          supplierEmail: service.supplierEmail,
                          supplierContact: service.supplierContact,
                          businessName: service.businessName,
                          status: service.status,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Category: ${service.category}",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Business: ${service.businessName}",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Price: \₹${service.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Status: ${service.status.name}",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: service.status == ServiceStatus.Pending
                                ? Colors.orange
                                : service.status == ServiceStatus.Approved
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(service.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  void _showDeleteConfirmationDialog(String serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Service"),
        content: const Text(
          "Are you sure you want to delete this service?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text(
              "Cancel",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await _deleteService(serviceId); // Delete the service
            },
            child: const Text(
              "Delete",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String supplierName;
  final String supplierEmail;
  final String supplierContact;
  final String businessName;
  ServiceStatus status;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.supplierName,
    required this.supplierEmail,
    required this.supplierContact,
    required this.businessName,
    required this.status,
  });
}

class AddServiceScreen extends StatefulWidget {
  final String supplierId;

  const AddServiceScreen({super.key, required this.supplierId});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pricingController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _supplierEmailController = TextEditingController();
  final _supplierContactController = TextEditingController();
  final _businessNameController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();
      setState(() {
        _categories =
            snapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      _showErrorDialog("Failed to load categories.");
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('services').add({
        'serviceName': _serviceNameController.text,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'pricing': double.parse(_pricingController.text),
        'supplierName': _supplierNameController.text,
        'supplierEmail': _supplierEmailController.text,
        'supplierContact': _supplierContactController.text,
        'businessName': _businessNameController.text,
        'status': 'Pending',
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
    } finally {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Service"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Service Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Service Name",
                      _serviceNameController,
                      "Enter service name",
                      icon: Icons.work,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      "Description",
                      _descriptionController,
                      "Enter service description",
                      maxLines: 3,
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      "Price",
                      _pricingController,
                      "Enter service price",
                      keyboardType: TextInputType.number,
                      icon: Icons.currency_rupee,
                      prefixText: "₹ ",
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Supplier Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Supplier Name",
                      _supplierNameController,
                      "Enter supplier name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      "Business Name",
                      _businessNameController,
                      "Enter business name",
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      "Supplier Email",
                      _supplierEmailController,
                      "Enter supplier email",
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      "Supplier Contact",
                      _supplierContactController,
                      "Enter supplier contact",
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "SAVE SERVICE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        if (label == "Price") {
          final price = double.tryParse(value);
          if (price == null || price < 0) {
            return "Please enter a valid price";
          }
        }
        if (label == "Supplier Email" && !value.contains('@')) {
          return "Please enter a valid email";
        }
        if (label == "Supplier Contact" && value.length < 10) {
          return "Please enter a valid contact number";
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories
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
      decoration: InputDecoration(
        labelText: "Category",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.category),
      ),
      validator: (value) {
        if (value == null) {
          return "Please select a category";
        }
        return null;
      },
    );
  }
}

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceName;
  final String category;
  final String description;
  final double price;
  final String supplierName;
  final String supplierEmail;
  final String supplierContact;
  final String businessName;
  final ServiceStatus status;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.price,
    required this.supplierName,
    required this.supplierEmail,
    required this.supplierContact,
    required this.businessName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status == ServiceStatus.Pending
        ? Colors.orange
        : status == ServiceStatus.Approved
            ? Colors.green
            : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Details"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.name,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "₹${price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Service Information Section
            _buildDetailSection(
              title: "Service Information",
              icon: Icons.work,
              children: [
                _buildDetailItem("Category", category, Icons.category),
                _buildDetailItem("Description", description, Icons.description),
              ],
            ),
            const SizedBox(height: 20),

            // Supplier Information Section
            _buildDetailSection(
              title: "Supplier Information",
              icon: Icons.person,
              children: [
                _buildDetailItem(
                    "Supplier Name", supplierName, Icons.person_outline),
                _buildDetailItem("Business Name", businessName, Icons.business),
                _buildDetailItem("Email", supplierEmail, Icons.email),
                _buildDetailItem("Contact", supplierContact, Icons.phone),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
