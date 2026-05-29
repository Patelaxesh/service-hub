import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String uid; // Use uid instead of documentId
  const ProfileScreen({super.key, required this.uid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true; // Add loading state

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
          .doc(widget.uid) // Use widget.uid
          .get();

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
          _isLoading = false; // Data fetched, stop loading
        });
      } else {
        setState(() {
          _isLoading = false; // Document doesn't exist, stop loading
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Customer profile not found"),
            backgroundColor:
                Colors.redAccent, // Set the background color to red accent
          ),
        );
      }
    } catch (e) {
      print("Error fetching customer profile: $e");
      setState(() {
        _isLoading = false; // Error occurred, stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch customer profile")),
      );
    }
  }

  // Update Firestore Customer Profile field
  Future<void> _updateCustomerProfile(String field, String newValue) async {
    if (widget.uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("customers")
          .doc(widget.uid) // Use widget.uid
          .update({field: newValue});
      _fetchCustomerProfile(); // Refresh data after update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$field updated successfully")),
      );
    } catch (e) {
      print("Error updating $field: $e");
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
            border: OutlineInputBorder(),
          ),
          obscureText: isPassword,
          keyboardType: field == "MobileNumber"
              ? TextInputType.phone
              : TextInputType.text,
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
              _updateCustomerProfile(field, controller.text);
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
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
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

/*
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  // Static Customer details
  String _fullName = "John Doe";
  String _email = "johndoe@example.com";
  String _mobileNumber = "+1234567890";
  String _gender = "Male";
  String _dob = "1990-01-01";
  String _location = "USA, California, Los Angeles";
  String _password = "password123";

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
          keyboardType: field == "MobileNumber"
              ? TextInputType.phone
              : TextInputType.text,
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
              setState(() {
                if (field == "Full Name") _fullName = controller.text;
                if (field == "Email") _email = controller.text;
                if (field == "Mobile Number") _mobileNumber = controller.text;
                if (field == "Gender") _gender = controller.text;
                if (field == "Date of Birth") _dob = controller.text;
                if (field == "Location") _location = controller.text;
                if (field == "Password") _password = controller.text;
              });
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Manage Profile"),
          backgroundColor: Colors.greenAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Customer Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              children: [
                InfoTile(
                    title: "Full Name",
                    value: _fullName,
                    icon: Icons.person,
                    onTap: () =>
                        _editField("Full Name", "Full Name", _fullName)),
                InfoTile(
                    title: "Email",
                    value: _email,
                    icon: Icons.email,
                    onTap: () => _editField("Email", "Email", _email)),
                InfoTile(
                    title: "Mobile Number",
                    value: _mobileNumber,
                    icon: Icons.phone,
                    onTap: () => _editField(
                        "Mobile Number", "Mobile Number", _mobileNumber)),
                InfoTile(
                    title: "Gender",
                    value: _gender,
                    icon: Icons.wc,
                    onTap: () => _editField("Gender", "Gender", _gender)),
                InfoTile(
                    title: "Date of Birth",
                    value: _dob,
                    icon: Icons.cake,
                    onTap: () =>
                        _editField("Date of Birth", "Date of Birth", _dob)),
                InfoTile(
                    title: "Location",
                    value: _location,
                    icon: Icons.location_on,
                    onTap: () => _editField("Location", "Location", _location)),
                InfoTile(
                    title: "Password",
                    value: "******",
                    icon: Icons.lock,
                    onTap: () => _editField("Password", "Password", _password,
                        isPassword: false)),
              ],
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: Row(
                children: [
                  Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.black),
                  SizedBox(width: 10),
                  Text("Dark Mode"),
                ],
              ),
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
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
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.edit, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
*/
