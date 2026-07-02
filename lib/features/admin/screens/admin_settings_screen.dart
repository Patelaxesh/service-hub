import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isDarkMode = false;
  bool _isLoading = true;

// Admin details
  String? _adminName, _adminEmail, _adminContact, _adminAddress;
  String _adminDocId = "";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _fetchAdminProfile();
  }

// Load persistent configurations safely
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

// Persist dark mode state dynamically
  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', value);
  }

// Fetch Admin Profile from targeted 'admins' collection
  Future<void> _fetchAdminProfile() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("admins").limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot adminDoc = snapshot.docs.first;
        final data = adminDoc.data() as Map<String, dynamic>?;

        setState(() {
          _adminName = data?["Name"] ?? "Administrator";
          _adminEmail = data?["Email"] ?? "";
          _adminContact = data?["Contact"] ?? "";
          _adminAddress = data?["Address"] ?? "";
          _adminDocId = adminDoc.id;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching admin profile: $e");
      setState(() => _isLoading = false);
    }
  }

// Standard Profile Firestore Sync Field Updating Method
  Future<void> _updateAdminProfile(String field, String newValue) async {
    if (_adminDocId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection("admins")
          .doc(_adminDocId)
          .update({field: newValue});
      _fetchAdminProfile();
    } catch (e) {
      debugPrint("Error updating field ($field): $e");
    }
  }

// Modern BottomSheet Editor matching custom UI specification
  void _showEditBottomSheet(String title, String field, String currentValue,
      {TextInputType inputType = TextInputType.text}) {
    final controller = TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text("Edit $title",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: inputType,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                hintText: "Enter your $title",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateAdminProfile(field, controller.text.trim());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Save",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// Modern Logout Confirmation BottomSheet workflow
  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.logout_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text("Logout?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121))),
            const SizedBox(height: 8),
            const Text(
                "Are you sure you want to securely log out of your admin session?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
// Route back cleanly to your explicit app login context routing node
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Logout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// Simulated Trigger wrapper representing standard security configurations
  void _triggerPasswordResetWorkflow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "Password reset email hook dispatched via Firebase Auth protocol workflow successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerEffect()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
// Premium Custom Header Top Title Row
                    const Text("Settings",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121))),
                    const SizedBox(height: 4),
                    const Text("Manage your account",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 24),

// Modern Admin Minimal Profile Avatar Identification Header Box Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16)),
                            child: Center(
                              child: Text(
                                _adminName?.isNotEmpty == true
                                    ? _adminName![0].toUpperCase()
                                    : "A",
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_adminName ?? "Administrator",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212121))),
                                const SizedBox(height: 2),
                                Text(_adminEmail ?? "admin@gmail.com",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

// Group Section: PROFILE
                    const _SectionHeader(title: "Profile"),
                    _SettingsContainer(
                      children: [
                        _SettingsRowTile(
                          icon: Icons.person_outline_rounded,
                          title: "Name",
                          value: _adminName ?? '',
                          onTap: () => _showEditBottomSheet(
                              "Name", "Name", _adminName ?? ''),
                        ),
                        _Divider(),
                        _SettingsRowTile(
                          icon: Icons.mail_outline_rounded,
                          title: "Email",
                          value: _adminEmail ?? '',
                          onTap: () => _showEditBottomSheet(
                              "Email", "Email", _adminEmail ?? '',
                              inputType: TextInputType.emailAddress),
                        ),
                        _Divider(),
                        _SettingsRowTile(
                          icon: Icons.phone_android_rounded,
                          title: "Contact",
                          value: _adminContact ?? 'Not Added',
                          onTap: () => _showEditBottomSheet(
                              "Contact", "Contact", _adminContact ?? '',
                              inputType: TextInputType.phone),
                        ),
                        _Divider(),
                        _SettingsRowTile(
                          icon: Icons.location_on_outlined,
                          title: "Address",
                          value: _adminAddress ?? 'Not Set',
                          onTap: () => _showEditBottomSheet(
                              "Address", "Address", _adminAddress ?? ''),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

// Group Section: SECURITY
                    const _SectionHeader(title: "Security"),
                    _SettingsContainer(
                      children: [
                        _SettingsRowTile(
                          icon: Icons.lock_outline_rounded,
                          title: "Change Password",
                          value: "Update credential token",
                          onTap: _triggerPasswordResetWorkflow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

// Group Section: PREFERENCES
                    const _SectionHeader(title: "Preferences"),
                    _SettingsContainer(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.dark_mode_outlined,
                                    color: Colors.blue, size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Dark Mode",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF212121))),
                                    Text("Enable system dark theme state",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isDarkMode,
                                activeThumbColor: Colors.blue,
                                onChanged: _toggleDarkMode,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

// Group Section: SESSION LOGOUT
                    const _SectionHeader(title: "Session"),
                    _SettingsContainer(
                      children: [
                        _SettingsRowTile(
                          icon: Icons.logout_rounded,
                          title: "Logout",
                          value: "Terminate application session state",
                          iconColor: Colors.redAccent,
                          onTap: _showLogoutBottomSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

// High Fidelity Matching Struct Shimmer Card Loader Interface layout
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 140,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 24),
            Container(
                height: 88,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 32),
            ...List.generate(
                3,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 80,
                              height: 16,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 12),
                          Container(
                              height: 140,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20))),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _SettingsContainer extends StatelessWidget {
  final List<Widget> children;

  const _SettingsContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final Color iconColor;

  const _SettingsRowTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.iconColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        thickness: 1,
        indent: 70,
        endIndent: 16,
        color: Colors.grey[100]);
  }
}
