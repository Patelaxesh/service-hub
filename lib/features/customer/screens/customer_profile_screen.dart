import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String uid;
  const CustomerProfileScreen({super.key, required this.uid});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState(); // Fixed: Public State type
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _isLoading = true;

  // Customer details
  String? _fullName, _gender, _mobileNumber, _password, _location, _dob, _email;

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfile();
  }

  // Fetch Customer Profile from Firestore using uid
  Future<void> _fetchCustomerProfile() async {
    try {
      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection("customers")
          .doc(widget.uid)
          .get();

      // Fixed: Checked for async gap validation before referencing context or calling setState
      if (!mounted) return;

      if (customerDoc.exists) {
        setState(() {
          _fullName =
              "${customerDoc["firstName"] ?? ""} ${customerDoc["middleName"] ?? ""} ${customerDoc["lastName"] ?? ""}"
                  .trim();
          _gender = customerDoc["gender"] ?? "Not specified";
          _mobileNumber = customerDoc["mobileNumber"] ?? "Not specified";
          _password = customerDoc["password"] ?? "Not specified";
          _location =
              "${customerDoc["country"] ?? ""}, ${customerDoc["state"] ?? ""}, ${customerDoc["city"] ?? ""}"
                  .trim();
          _dob = customerDoc["dob"] ?? "Not specified";
          _email = customerDoc["email"] ?? "Not specified";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer profile not found"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Fixed: Replaced print with debugPrint
      debugPrint("Error fetching customer profile: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch customer profile")),
      );
    }
  }

  // Update Firestore Customer Profile field
  Future<void> _updateCustomerProfile(String field, String newValue) async {
    if (widget.uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("customers")
          .doc(widget.uid)
          .update({field: newValue});

      // Fixed: Checked for async gap validation before referencing context
      if (!mounted) return;

      _fetchCustomerProfile(); // Refresh data after update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$field updated successfully")),
      );
    } catch (e) {
      // Fixed: Replaced print with debugPrint
      debugPrint("Error updating $field: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update $field")),
      );
    }
  }

  // Dialog to edit a field
  void _editField(String title, String field, String currentValue,
      {bool isPassword = false}) {
    TextEditingController controller =
    TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $title",
            border: const OutlineInputBorder(),
          ),
          obscureText: isPassword,
          keyboardType: field == "MobileNumber"
              ? TextInputType.phone
              : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose(); // Best practice: Clean up controller
              Navigator.pop(context);
            },
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              _updateCustomerProfile(field, controller.text);
              controller.dispose(); // Best practice: Clean up controller
              Navigator.pop(context);
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            child: const Text("Save",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // Logout function
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout functionality here
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            child: const Text("Logout",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Profile"),
        backgroundColor: Colors.greenAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                InfoTile(
                  title: "Full Name",
                  value: _fullName ?? "Not specified",
                  icon: Icons.person,
                  onTap: () => _editField(
                      "Full Name", "FirstName", _fullName ?? ""),
                ),
                InfoTile(
                  title: "Gender",
                  value: _gender ?? "Not specified",
                  icon: Icons.wc,
                  onTap: () =>
                      _editField("Gender", "Gender", _gender ?? ""),
                ),
                InfoTile(
                  title: "Mobile Number",
                  value: _mobileNumber ?? "Not specified",
                  icon: Icons.phone,
                  onTap: () => _editField("Mobile Number", "MobileNumber",
                      _mobileNumber ?? ""),
                ),
                InfoTile(
                  title: "Password",
                  value: "******",
                  icon: Icons.lock,
                  onTap: () => _editField(
                      "Password", "Password", _password ?? "",
                      isPassword: false),
                ),
                InfoTile(
                  title: "Location",
                  value: _location ?? "Not specified",
                  icon: Icons.location_on,
                  onTap: () =>
                      _editField("Location", "Country", _location ?? ""),
                ),
                InfoTile(
                  title: "Date of Birth",
                  value: _dob ?? "Not specified",
                  icon: Icons.cake,
                  onTap: () =>
                      _editField("Date of Birth", "DOB", _dob ?? ""),
                ),
                InfoTile(
                  title: "Email",
                  value: _email ?? "Not specified",
                  icon: Icons.email,
                  onTap: () => _editField("Email", "Email", _email ?? ""),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for displaying customer details
class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const InfoTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.edit, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}