import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class SupplierProfileScreen extends StatefulWidget {
  final String uid;

  const SupplierProfileScreen({super.key, required this.uid});

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState(); // Fixed: Exposing private types in public APIs
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  bool _isLoading = true;

  // Supplier details
  String? _firstName, _middleName, _lastName, _gender, _mobileNumber, _password;
  String? _country, _state, _city, _dob, _email;

  // Consistent Premium Design Brand Specs
  static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
  static const Color accentColor = Color(0xFFFFF3F3); // Warm Rose Container Tone
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF757575);

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

      if (!mounted) return;

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
              ? (supplierDoc["dob"] as Timestamp)
              .toDate()
              .toString()
              .split(' ')[0]
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
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch supplier profile"),
          backgroundColor: primaryColor,
        ),
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

      if (!mounted) return; // Fixed: Guarded BuildContext usage across async gaps
      _fetchSupplierProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return; // Fixed: Guarded BuildContext usage across async gaps
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile"),
          backgroundColor: primaryColor,
        ),
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

    _showStyledDialog(
      title: "Edit Full Name",
      icon: Icons.person_rounded,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogTextField(
              controller: firstNameController, label: "First Name"),
          const SizedBox(height: 14),
          _buildDialogTextField(
              controller: middleNameController,
              label: "Middle Name (Optional)"),
          const SizedBox(height: 14),
          _buildDialogTextField(
              controller: lastNameController, label: "Last Name"),
        ],
      ),
      onSave: () {
        _updateSupplierProfile({
          "firstName": firstNameController.text.trim(),
          "middleName": middleNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
        });
      },
    );
  }

  void _editField(String title, String field, String currentValue,
      {bool isPassword = false}) {
    TextEditingController controller =
    TextEditingController(text: currentValue);

    _showStyledDialog(
      title: "Edit $title",
      icon: isPassword ? Icons.lock_rounded : Icons.edit_note_rounded,
      content: _buildDialogTextField(
        controller: controller,
        label: title,
        obscureText: isPassword,
        keyboardType:
        field == "mobileNumber" ? TextInputType.phone : TextInputType.text,
      ),
      onSave: () {
        _updateSupplierProfile({field: controller.text.trim()});
      },
    );
  }

  void _editLocationField() {
    TextEditingController countryController =
    TextEditingController(text: _country);
    TextEditingController stateController = TextEditingController(text: _state);
    TextEditingController cityController = TextEditingController(text: _city);

    _showStyledDialog(
      title: "Edit Location Details",
      icon: Icons.location_on_rounded,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogTextField(
              controller: countryController, label: "Country"),
          const SizedBox(height: 14),
          _buildDialogTextField(
              controller: stateController, label: "State / Province"),
          const SizedBox(height: 14),
          _buildDialogTextField(controller: cityController, label: "City"),
        ],
      ),
      onSave: () {
        _updateSupplierProfile({
          "country": countryController.text.trim(),
          "state": stateController.text.trim(),
          "city": cityController.text.trim(),
        });
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: primaryColor),
            SizedBox(width: 12),
            Text("Sign Out",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: textDark)),
          ],
        ),
        content: const Text(
          "Are you sure you want to exit your dashboard and secure this session?",
          style: TextStyle(fontSize: 15, color: textMuted, height: 1.4),
        ),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementation code block logic hooks go here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text("Logout",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _showStyledDialog(
      {required String title,
        required IconData icon,
        required Widget content,
        required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: Row(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: textDark)),
          ],
        ),
        content: SingleChildScrollView(child: content),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text("Save Changes",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: textDark, fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: textMuted, fontWeight: FontWeight.w500),
        floatingLabelStyle:
        const TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName =
    "${_firstName ?? ""} ${_middleName ?? ""} ${_lastName ?? ""}".trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Profile",
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _isLoading
          ? _buildShimmerProfile()
          : SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Modern Profile Banner Backdrop
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2), // Fixed: Removed withOpacity precision loss implementation
                    child: Text(
                      (_firstName != null && _firstName!.isNotEmpty)
                          ? _firstName![0].toUpperCase()
                          : "S",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isNotEmpty
                              ? fullName
                              : "Supplier Partner",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email ?? "Loading profile settings...",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85), // Fixed: Replaced withOpacity definitions
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profile Sections Title Block
            const Padding(
              padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
              child: Text(
                "Account Metadata",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: 0.5),
              ),
            ),

            // Core Cards Framework Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildProfileCard(
                    icon: Icons.person_outline_rounded,
                    title: "Name",
                    value:
                    fullName.isNotEmpty ? fullName : "Not specified",
                    onTap: _editName,
                  ),
                  _buildProfileCard(
                    icon: Icons.wc_rounded,
                    title: "Gender",
                    value: _gender ?? "Not specified",
                    onTap: () =>
                        _editField("Gender", "gender", _gender ?? ""),
                  ),
                  _buildProfileCard(
                    icon: Icons.phone_android_rounded,
                    title: "Mobile Number",
                    value: _mobileNumber ?? "Not specified",
                    onTap: () => _editField("Mobile Number",
                        "mobileNumber", _mobileNumber ?? ""),
                  ),
                  _buildProfileCard(
                    icon: Icons.lock_outline_rounded,
                    title: "Password Security",
                    value: "••••••••",
                    onTap: () => _editField(
                        "Password", "password", _password ?? "",
                        isPassword: true),
                  ),
                  _buildProfileCard(
                    icon: Icons.map_rounded,
                    title: "Location Context",
                    value:
                    "${_city ?? ""}, ${_state ?? ""}, ${_country ?? ""}"
                        .replaceAll(RegExp(r'^,\s*|,\s*$'), ''),
                    onTap: _editLocationField,
                  ),
                  _buildProfileCard(
                    icon: Icons.cake_rounded,
                    title: "Date of Birth",
                    value: _dob ?? "Not specified",
                    onTap: () =>
                        _editField("Date of Birth", "dob", _dob ?? ""),
                  ),
                  _buildProfileCard(
                    icon: Icons.alternate_email_rounded,
                    title: "Email Address",
                    value: _email ?? "Not specified",
                    onTap: () =>
                        _editField("Email", "email", _email ?? ""),
                  ),
                ],
              ),
            ),

            // Core Action Logs Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text("Sign Out",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // Fixed: Replaced withOpacity definitions
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.0),
          highlightColor: primaryColor.withValues(alpha: 0.03), // Fixed: Replaced withOpacity definitions
          splashColor: primaryColor.withValues(alpha: 0.06), // Fixed: Replaced withOpacity definitions
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textMuted,
                            letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: textDark),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFCCCCCC), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProfile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
            ),
            const SizedBox(height: 32),
            Column(
              children: List.generate(7, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}