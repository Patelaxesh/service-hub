import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart'; // Added for SystemNavigator

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isLoading = true;

  // Admin details
  String? _adminName, _adminEmail, _adminPassword, _adminContact, _adminAddress;
  String _adminDocId = "";

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  // Fetch Admin Profile from Firestore
  Future<void> _fetchAdminProfile() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Admin Profile")
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot adminDoc = snapshot.docs.first;
        setState(() {
          _adminName = adminDoc["Name"];
          _adminEmail = adminDoc["Email"];
          _adminPassword = adminDoc["Password"];
          _adminContact = adminDoc["Contact"];
          _adminAddress = adminDoc["Address"];
          _adminDocId = adminDoc.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching admin profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update Firestore Admin Profile field
  Future<void> _updateAdminProfile(String field, String newValue) async {
    if (_adminDocId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("Admin Profile")
          .doc(_adminDocId)
          .update({field: newValue});
      _fetchAdminProfile();
    } catch (e) {
      print("Error updating $field: $e");
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
            border: OutlineInputBorder(),
          ),
          obscureText: isPassword,
          keyboardType:
              field == "Contact" ? TextInputType.phone : TextInputType.text,
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
              _updateAdminProfile(field, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: const Text("Save",
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
          backgroundColor: Colors.lightBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Admin Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _isLoading
                ? _buildShimmerEffect()
                : Column(
                    children: [
                      InfoTile(
                          title: "Name",
                          value: _adminName ?? '',
                          icon: Icons.person,
                          onTap: () =>
                              _editField("Name", "Name", _adminName ?? '')),
                      InfoTile(
                          title: "Email",
                          value: _adminEmail ?? '',
                          icon: Icons.email,
                          onTap: () =>
                              _editField("Email", "Email", _adminEmail ?? '')),
                      InfoTile(
                          title: "Password",
                          value: "******",
                          icon: Icons.lock,
                          onTap: () => _editField(
                              "Password", "Password", _adminPassword ?? '',
                              isPassword: false)),
                      InfoTile(
                          title: "Contact",
                          value: _adminContact ?? '',
                          icon: Icons.phone,
                          onTap: () => _editField(
                              "Contact", "Contact", _adminContact ?? '')),
                      InfoTile(
                          title: "Address",
                          value: _adminAddress ?? '',
                          icon: Icons.location_on,
                          onTap: () => _editField(
                              "Address", "Address", _adminAddress ?? '')),
                    ],
                  ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: Row(
                children: [
                  Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.blue),
                  const SizedBox(width: 10),
                  const Text("Dark Mode"),
                ],
              ),
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to logout?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            SystemNavigator.pop(); // This closes the app
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue),
                          child: const Text("Logout",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32)),
                child: const Text("Logout",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer effect widget
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              subtitle: Container(
                width: double.infinity,
                height: 14,
                color: Colors.white,
              ),
              trailing: Container(
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable widget for displaying admin details
class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const InfoTile(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.edit, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
