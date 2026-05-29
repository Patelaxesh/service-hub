import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class SupplierProfileScreen extends StatefulWidget {
  final String uid;
  const SupplierProfileScreen({super.key, required this.uid});

  @override
  _SupplierProfileScreenState createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  bool _isLoading = true;

  // Supplier details
  String? _firstName, _middleName, _lastName, _gender, _mobileNumber, _password;
  String? _country, _state, _city, _dob, _email;

  @override
  void initState() {
    super.initState();
    _fetchSupplierProfile();
  }

  Future<void> _fetchSupplierProfile() async {
    try {
      DocumentSnapshot supplierDoc = await FirebaseFirestore.instance
          .collection("Suppliers")
          .doc(widget.uid)
          .get();

      if (supplierDoc.exists) {
        setState(() {
          _firstName = supplierDoc["firstName"] ?? "";
          _middleName = supplierDoc["middleName"] ?? "";
          _lastName = supplierDoc["lastName"] ?? "";
          _gender = supplierDoc["gender"] ?? "Not specified";
          _mobileNumber = supplierDoc["mobileNumber"] ?? "Not specified";
          _password = supplierDoc["password"] ?? "Not specified";
          _country = supplierDoc["country"] ?? "Not specified";
          _state = supplierDoc["state"] ?? "Not specified";
          _city = supplierDoc["city"] ?? "Not specified";
          _dob = supplierDoc["dob"] is Timestamp
              ? (supplierDoc["dob"] as Timestamp).toDate().toString()
              : supplierDoc["dob"]?.toString() ?? "Not specified";
          _email = supplierDoc["email"] ?? "Not specified";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Supplier profile not found"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print("Error fetching supplier profile: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch supplier profile")),
      );
    }
  }

  Future<void> _updateSupplierProfile(Map<String, dynamic> updates) async {
    if (widget.uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("Suppliers")
          .doc(widget.uid)
          .update(updates);
      _fetchSupplierProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  void _editName() {
    TextEditingController firstNameController =
        TextEditingController(text: _firstName);
    TextEditingController middleNameController =
        TextEditingController(text: _middleName);
    TextEditingController lastNameController =
        TextEditingController(text: _lastName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text("Edit Name", style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: middleNameController,
              decoration: InputDecoration(
                labelText: "Middle Name (Optional)",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              _updateSupplierProfile({
                "firstName": firstNameController.text,
                "middleName": middleNameController.text,
                "lastName": lastNameController.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text("Save",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editField(String title, String field, String currentValue,
      {bool isPassword = false, bool isLocation = false}) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    if (isLocation) {
      _editLocationField(title, field, currentValue);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title", style: TextStyle(color: Colors.redAccent)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $title",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          obscureText: isPassword,
          keyboardType: field == "mobileNumber"
              ? TextInputType.phone
              : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              _updateSupplierProfile({field: controller.text});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text("Save",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editLocationField(String title, String field, String currentValue) {
    TextEditingController countryController =
        TextEditingController(text: _country);
    TextEditingController stateController = TextEditingController(text: _state);
    TextEditingController cityController = TextEditingController(text: _city);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Location",
            style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stateController,
              decoration: InputDecoration(
                labelText: "State/Province",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              _updateSupplierProfile({
                "country": countryController.text,
                "state": stateController.text,
                "city": cityController.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text("Save",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout functionality here
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text("Logout",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Manage Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? _buildShimmerProfile()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Supplier Profile",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _buildProfileCard(
                        icon: Icons.person,
                        title: "Name",
                        value:
                            "${_firstName ?? ""} ${_middleName ?? ""} ${_lastName ?? ""}"
                                .trim(),
                        onTap: _editName,
                      ),
                      _buildProfileCard(
                        icon: Icons.wc,
                        title: "Gender",
                        value: _gender ?? "Not specified",
                        onTap: () =>
                            _editField("Gender", "gender", _gender ?? ""),
                      ),
                      _buildProfileCard(
                        icon: Icons.phone,
                        title: "Mobile Number",
                        value: _mobileNumber ?? "Not specified",
                        onTap: () => _editField("Mobile Number", "mobileNumber",
                            _mobileNumber ?? ""),
                      ),
                      _buildProfileCard(
                        icon: Icons.lock,
                        title: "Password",
                        value: "******",
                        onTap: () => _editField(
                            "Password", "password", _password ?? "",
                            isPassword: true),
                      ),
                      _buildProfileCard(
                        icon: Icons.location_on,
                        title: "Country",
                        value: _country ?? "Not specified",
                        onTap: () => _editField(
                            "Location", "country", _country ?? "",
                            isLocation: true),
                      ),
                      _buildProfileCard(
                        icon: Icons.location_city,
                        title: "State/Province",
                        value: _state ?? "Not specified",
                        onTap: () => _editField(
                            "Location", "state", _state ?? "",
                            isLocation: true),
                      ),
                      _buildProfileCard(
                        icon: Icons.place,
                        title: "City",
                        value: _city ?? "Not specified",
                        onTap: () => _editField("Location", "city", _city ?? "",
                            isLocation: true),
                      ),
                      _buildProfileCard(
                        icon: Icons.cake,
                        title: "Date of Birth",
                        value: _dob ?? "Not specified",
                        onTap: () =>
                            _editField("Date of Birth", "dob", _dob ?? ""),
                      ),
                      _buildProfileCard(
                        icon: Icons.email,
                        title: "Email",
                        value: _email ?? "Not specified",
                        onTap: () => _editField("Email", "email", _email ?? ""),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.redAccent, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProfile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: List.generate(9, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
