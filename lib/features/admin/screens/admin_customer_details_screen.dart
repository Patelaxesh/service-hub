import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminCustomerDetailsScreen extends StatelessWidget {
  final String customerName;
  final String email;
  final String contactNumber;
  final String address;

  const AdminCustomerDetailsScreen({
    super.key,
    required this.customerName,
    required this.email,
    required this.contactNumber,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Unified background canvas
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header Bar (Replaces default AppBar)
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
                    "Customer Details",
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

                    // Contact Section Title
                    const Text(
                      "Contact Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tappable Info Cards with trailing Chevrons instead of raw text strings
                    _buildTappableInfoCard(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: email.isNotEmpty ? email : "No email provided",
                      onTap: () => _sendEmail(email),
                    ),
                    const SizedBox(height: 14),

                    _buildTappableInfoCard(
                      icon: Icons.phone_outlined,
                      label: "Phone",
                      value: contactNumber.isNotEmpty
                          ? contactNumber
                          : "No contact number",
                      onTap: () => _makeCall(contactNumber),
                    ),
                    const SizedBox(height: 14),

                    _buildTappableInfoCard(
                      icon: Icons.location_on_outlined,
                      label: "Location",
                      value: address.isNotEmpty
                          ? address
                          : "No location specified",
                      onTap: () {
                        // Optional extension hook for maps routing
                      },
                    ),

                    // Spacing for modern gesture tracking areas safely
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
        customerName.isNotEmpty ? customerName[0].toUpperCase() : "?";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 72x72 Rounded Rectangle Avatar (Radius 20)
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
                customerName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              // Premium role identity chip text matching design language
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Customer",
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
              color: Color(0x04000000), // Exact requested premium target shadow
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

  void _sendEmail(String targetEmail) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: targetEmail,
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
