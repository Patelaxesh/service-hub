import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSupplierDetailsScreen extends StatelessWidget {
  final String supplierName;
  final String email;
  final String contactNumber;
  final String country;
  final String state;
  final String city;
  final List<dynamic> services;

  const AdminSupplierDetailsScreen({
    super.key,
    required this.supplierName,
    required this.email,
    required this.contactNumber,
    required this.country,
    required this.state,
    required this.city,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    // Safely build the location string to avoid dangling commas on empty data strings
    final locationText = [
      city,
      state,
    ].where((e) => e.trim().isNotEmpty).join(", ");

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Supplier Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Frame
                    _buildProfileSection(),
                    const SizedBox(height: 28),

                    // Quick Actions (Prioritizes Call first, then Email)
                    _buildQuickActions(),
                    const SizedBox(height: 28),

                    // Contact Section
                    const Text(
                      "Contact Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Redesigned Tappable Info Cards with trailing Chevrons instead of raw text strings
                    _buildTappableInfoCard(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: email,
                      onTap: () => _sendEmail(email),
                    ),
                    const SizedBox(height: 14),

                    _buildTappableInfoCard(
                      icon: Icons.phone_outlined,
                      label: "Phone",
                      value: contactNumber,
                      onTap: () => _makeCall(contactNumber),
                    ),
                    const SizedBox(height: 14),

                    _buildTappableInfoCard(
                      icon: Icons.location_on_outlined,
                      label: "Location",
                      value: locationText.isNotEmpty
                          ? locationText
                          : "No location specified",
                      onTap: () {
                        // Extension hook for maps routing
                      },
                    ),
                    const SizedBox(height: 28),

                    // Shortened and Cleaned Services Section
                    const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildServicesSection(),

                    // Added extra bottom padding to accommodate modern gesture tracking areas safely
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final avatarLetter =
        supplierName.isNotEmpty ? supplierName[0].toUpperCase() : "?";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            avatarLetter,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplierName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Supplier",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _customActionButton(
            label: "Call",
            icon: Icons.call_outlined,
            backgroundColor: Colors.blue[600]!,
            textColor: Colors.white,
            onPressed: () => _makeCall(contactNumber),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _customActionButton(
            label: "Email",
            icon: Icons.email_outlined,
            backgroundColor: Colors.white,
            textColor: Colors.blue[600]!,
            borderSide: BorderSide(color: Colors.blue[100]!, width: 1.5),
            onPressed: () => _sendEmail(email),
          ),
        ),
      ],
    );
  }

  Widget _customActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    BorderSide? borderSide,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: textColor),
        label: Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildTappableInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.grey[500], size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Replaced explicit action string text with a minimal custom chevron icon
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    if (services.isEmpty || services.first == "No services listed") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "No services available", // Cleaned natural text syntax variant
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      );
    }

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: services.map((service) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.build_outlined,
                // Scan-friendly structural icon inside the chip matching requirements
                size: 14,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 6),
              Text(
                service.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=ServicesHub Admin Inquiry&body=Hello,'),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    }
  }
}
