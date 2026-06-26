
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

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

// Consistent Premium Design System Specs
static const Color primaryColor = Color(0xFFE53935); // Rich Premium Red
static const Color accentColor = Color(0xFFFFF3F3); // Warm Rose Container Tone
static const Color cardBgColor = Colors.white;
static const Color textDark = Color(0xFF1A1A1A);
static const Color textMuted = Color(0xFF757575);

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

if (mounted) {
setState(() {
services = snapshot.docs.map((doc) {
final data = doc.data() as Map<String, dynamic>;
return Service(
id: doc.id,
name: data['serviceName'] ?? 'Unnamed Service',
description: data['description'] ?? '',
category: data['category'] ?? 'General',
price: (data['pricing'] is num) ? (data['pricing'] as num).toDouble() : double.tryParse(data['pricing']?.toString() ?? '') ?? 0.0,
supplierName: data['supplierName'] ?? '',
supplierEmail: data['supplierEmail'] ?? '',
supplierContact: data['supplierContact'] ?? '',
businessName: data['businessName'] ?? '',
status: _parseStatus(data['status']),
);
}).toList();
isLoading = false;
});
}
} catch (e) {
_showSnackbar("Failed to load services.", primaryColor);
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

ServiceStatus _parseStatus(String? status) {
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
return services.where((service) => service.status == ServiceStatus.Approved).toList();
}

void _showSnackbar(String message, Color backgroundColor) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
backgroundColor: backgroundColor,
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
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
_showSnackbar("Service deleted successfully!", Colors.green[700]!);
} catch (e) {
_showSnackbar("Failed to delete service.", primaryColor);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFFAFAFA),
appBar: AppBar(
title: const Text(
"Service Management",
style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: 0.5),
),
centerTitle: true,
backgroundColor: primaryColor,
elevation: 0,
systemOverlayStyle: SystemUiOverlayStyle.light,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
onPressed: () => Navigator.of(context).pop(),
),
actions: [
IconButton(
icon: const Icon(Icons.add_rounded, size: 26, color: Colors.white),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const AddServiceScreen(supplierId: ''),
),
).then((_) => _fetchServices());
},
),
],
bottom: PreferredSize(
preferredSize: const Size.fromHeight(48),
child: Container(
color: primaryColor,
child: TabBar(
controller: _tabController,
labelColor: Colors.white,
unselectedLabelColor: Colors.white.withOpacity(0.65),
indicatorColor: Colors.white,
indicatorWeight: 3.5,
indicatorSize: TabBarIndicatorSize.tab,
labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.3),
unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
tabs: const [
Tab(text: 'Active'),
Tab(text: 'Pending'),
Tab(text: 'Approved'),
Tab(text: 'Rejected'),
],
),
),
),
),
body: isLoading
? _buildShimmerList()
    : Padding(
padding: const EdgeInsets.all(24.0),
child: TabBarView(
controller: _tabController,
children: [
_buildServiceList(getActiveServices()),
_buildServiceList(getFilteredServices(ServiceStatus.Pending)),
_buildServiceList(getFilteredServices(ServiceStatus.Approved)),
_buildServiceList(getFilteredServices(ServiceStatus.Rejected)),
],
),
),
);
}

Widget _buildInfoCard({required Widget child}) {
return Container(
width: double.infinity,
margin: const EdgeInsets.only(bottom: 14),
padding: const EdgeInsets.all(18.0),
decoration: BoxDecoration(
color: cardBgColor,
borderRadius: BorderRadius.circular(18.0),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.025),
blurRadius: 12,
offset: const Offset(0, 4),
),
],
),
child: child,
);
}

Widget _buildShimmerList() {
return Shimmer.fromColors(
baseColor: const Color(0xFFE0E0E0),
highlightColor: const Color(0xFFF5F5F5),
child: ListView.builder(
padding: const EdgeInsets.all(24.0),
itemCount: 3,
itemBuilder: (context, index) {
return _buildInfoCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(width: 150, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
Container(width: 75, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
],
),
const SizedBox(height: 14),
Container(width: 110, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
const SizedBox(height: 8),
Container(width: 130, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
const SizedBox(height: 14),
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
],
)
],
),
);
},
),
);
}

Widget _buildServiceList(List<Service> items) {
if (items.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.all(16),
decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
child: const Icon(Icons.layers_clear_rounded, size: 38, color: primaryColor),
),
const SizedBox(height: 16),
const Text(
"No services available configuration.",
style: TextStyle(fontSize: 15, color: textMuted, fontWeight: FontWeight.w600),
),
],
),
);
}

return RefreshIndicator(
color: primaryColor,
onRefresh: _fetchServices,
child: ListView.builder(
physics: const BouncingScrollPhysics(),
itemCount: items.length,
itemBuilder: (context, index) {
final service = items[index];

final statusColor = service.status == ServiceStatus.Pending
? Colors.amber[800]!
    : service.status == ServiceStatus.Approved
? Colors.green[700]!
    : primaryColor;

final statusBg = service.status == ServiceStatus.Pending
? const Color(0xFFFFF8E1)
    : service.status == ServiceStatus.Approved
? const Color(0xFFE8F5E9)
    : accentColor;

return _buildInfoCard(
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
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Text(
service.name,
style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: textDark),
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
child: Text(
service.status.name,
style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
),
),
],
),
const SizedBox(height: 12),
_buildRowInfo(Icons.category_outlined, "Category: ${service.category}"),
const SizedBox(height: 5),
_buildRowInfo(Icons.business_rounded, "Business: ${service.businessName}"),
const SizedBox(height: 5),
_buildRowInfo(Icons.currency_rupee_rounded, "Price: ₹${service.price.toStringAsFixed(2)}", isPrice: true),
const SizedBox(height: 8),
const Divider(height: 1, color: Color(0xFFF5F5F5)),
const SizedBox(height: 4),
Align(
alignment: Alignment.centerRight,
child: IconButton(
icon: const Icon(Icons.delete_outline_rounded, size: 22),
color: primaryColor,
visualDensity: VisualDensity.compact,
onPressed: () => _showDeleteConfirmationDialog(service.id),
),
),
],
),
),
);
},
),
);
}

Widget _buildRowInfo(IconData icon, String text, {bool isPrice = false}) {
return Row(
children: [
Icon(icon, size: 15, color: textMuted),
const SizedBox(width: 8),
Text(
text,
style: TextStyle(
fontSize: 13.5,
fontWeight: isPrice ? FontWeight.w800 : FontWeight.w500,
color: isPrice ? Colors.green[700] : textDark,
),
),
],
);
}

void _showDeleteConfirmationDialog(String serviceId) {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: cardBgColor,
surfaceTintColor: Colors.transparent,
title: const Text("Delete Service", style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
content: const Text("Are you sure you want to permanently delete this service profile layout?"),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w700, color: textMuted)),
),
ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: primaryColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
onPressed: () async {
Navigator.pop(context);
await _deleteService(serviceId);
},
child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
),
],
),
);
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
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
late Future<List<String>> _categoriesFuture;
bool _isLoading = false;

@override
void initState() {
super.initState();
// Fetch once here to prevent continuous calling inside FutureBuilder build workflow
_categoriesFuture = _fetchCategories();
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
if (!_formKey.currentState!.validate()) return;
_showConfirmationDialog();
}

Future<void> _uploadService() async {
setState(() => _isLoading = true);
try {
await FirebaseFirestore.instance.collection('services').add({
'serviceName': _serviceNameController.text.trim(),
'category': _selectedCategory,
'description': _descriptionController.text.trim(),
'pricing': double.parse(_pricingController.text.trim()),
'supplierName': _supplierNameController.text.trim(),
'supplierEmail': _supplierEmailController.text.trim(),
'supplierContact': _supplierContactController.text.trim(),
'businessName': _businessNameController.text.trim(),
'status': 'Pending',
'timestamp': FieldValue.serverTimestamp(),
});

if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text("Service added successfully layout!", style: TextStyle(fontWeight: FontWeight.w600)),
backgroundColor: Colors.green[700],
behavior: SnackBarBehavior.floating,
),
);
Navigator.pop(context);
}
} catch (e) {
_showErrorDialog("Failed to save service schema. Please verify configurations.");
} finally {
if (mounted) setState(() => _isLoading = false);
}
}

void _showConfirmationDialog() {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: _ServiceManagementScreenState.cardBgColor,
surfaceTintColor: Colors.transparent,
title: const Text("Confirm Service Entry", style: TextStyle(fontWeight: FontWeight.w800, color: _ServiceManagementScreenState.textDark)),
content: const Text("Are you sure you want to deploy this service profile data live?"),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w700, color: _ServiceManagementScreenState.textMuted)),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: _ServiceManagementScreenState.primaryColor,
elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
onPressed: () {
Navigator.pop(context);
_uploadService();
},
child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
),
],
),
);
}

void _showErrorDialog(String message) {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: _ServiceManagementScreenState.cardBgColor,
surfaceTintColor: Colors.transparent,
title: const Text("System Failure", style: TextStyle(fontWeight: FontWeight.w800, color: _ServiceManagementScreenState.textDark)),
content: Text(message),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text("OK", style: TextStyle(fontWeight: FontWeight.w700, color: _ServiceManagementScreenState.primaryColor)),
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
"Add New Service",
style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: 0.5),
),
centerTitle: true,
backgroundColor: _ServiceManagementScreenState.primaryColor,
elevation: 0,
systemOverlayStyle: SystemUiOverlayStyle.light,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
onPressed: () => Navigator.of(context).pop(),
),
),
body: _isLoading
? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_ServiceManagementScreenState.primaryColor)))
    : FutureBuilder<List<String>>(
future: _categoriesFuture,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_ServiceManagementScreenState.primaryColor)));
}
if (snapshot.hasError || !snapshot.hasData) {
return const Center(child: Text("Failed to load category dependencies.", style: TextStyle(color: _ServiceManagementScreenState.textMuted, fontWeight: FontWeight.w500)));
}

final categories = snapshot.data!;

return SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
"Service Information",
style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ServiceManagementScreenState.primaryColor, letterSpacing: 0.5),
),
const SizedBox(height: 16),
_buildTextField("Service Name", _serviceNameController, "e.g., Wedding Photography", icon: Icons.work_outline_rounded),
const SizedBox(height: 14),
_buildCategoryDropdown(categories),
const SizedBox(height: 14),
_buildTextField("Description", _descriptionController, "Enter service description specifications...", maxLines: 3, icon: Icons.description_outlined),
const SizedBox(height: 14),
_buildTextField("Price", _pricingController, "0.00", keyboardType: const TextInputType.numberWithOptions(decimal: true), icon: Icons.currency_rupee_rounded, prefixText: "₹ "),
const SizedBox(height: 28),
const Text(
"Supplier Information",
style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ServiceManagementScreenState.primaryColor, letterSpacing: 0.5),
),
const SizedBox(height: 16),
_buildTextField("Supplier Name", _supplierNameController, "Full Vendor Identity", icon: Icons.person_outline_rounded),
const SizedBox(height: 14),
_buildTextField("Business Name", _businessNameController, "Registered commercial brand", icon: Icons.business_outlined),
const SizedBox(height: 14),
_buildTextField("Supplier Email", _supplierEmailController, "contact@vendor.com", keyboardType: TextInputType.emailAddress, icon: Icons.email_outlined),
const SizedBox(height: 14),
_buildTextField("Supplier Contact", _supplierContactController, "Mobile communication entry", keyboardType: TextInputType.phone, icon: Icons.phone_android_rounded),
const SizedBox(height: 30),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: _saveService,
style: ElevatedButton.styleFrom(
backgroundColor: _ServiceManagementScreenState.primaryColor,
elevation: 0,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
child: const Text(
"SAVE SERVICE DATA",
style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
),
),
),
],
),
),
);
},
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
style: const TextStyle(fontSize: 14.5, color: _ServiceManagementScreenState.textDark, fontWeight: FontWeight.w500),
decoration: InputDecoration(
labelText: label,
hintText: hint,
hintStyle: const TextStyle(color: _ServiceManagementScreenState.textMuted, fontSize: 13.5),
labelStyle: const TextStyle(color: _ServiceManagementScreenState.textMuted, fontWeight: FontWeight.w600, fontSize: 14),
prefixIcon: icon != null ? Icon(icon, size: 20, color: _ServiceManagementScreenState.textMuted) : null,
prefixText: prefixText,
prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: _ServiceManagementScreenState.textDark),
filled: true,
fillColor: Colors.white,
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ServiceManagementScreenState.primaryColor, width: 1.5)),
errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ServiceManagementScreenState.primaryColor)),
focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ServiceManagementScreenState.primaryColor, width: 1.5)),
),
validator: (value) {
if (value == null || value.trim().isEmpty) return "Please enter $label";
if (label == "Price" && (double.tryParse(value) == null || double.parse(value) < 0)) return "Please specify positive numeric value";
if (label == "Supplier Email" && !value.contains('@')) return "Invalid email parameters";
if (label == "Supplier Contact" && value.trim().length < 10) return "Provide operational contact structure";
return null;
},
);
}

Widget _buildCategoryDropdown(List<String> categories) {
return DropdownButtonFormField<String>(
value: _selectedCategory,
items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)))).toList(),
onChanged: (value) => setState(() => _selectedCategory = value),
dropdownColor: Colors.white,
style: const TextStyle(color: _ServiceManagementScreenState.textDark),
decoration: InputDecoration(
labelText: "Category Selection",
labelStyle: const TextStyle(color: _ServiceManagementScreenState.textMuted, fontWeight: FontWeight.w600, fontSize: 14),
prefixIcon: const Icon(Icons.category_outlined, size: 20, color: _ServiceManagementScreenState.textMuted),
filled: true,
fillColor: Colors.white,
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ServiceManagementScreenState.primaryColor, width: 1.5)),
),
validator: (value) => value == null ? "Please attach category blueprint" : null,
);
}

@override
void dispose() {
_serviceNameController.dispose();
_descriptionController.dispose();
_pricingController.dispose();
_supplierNameController.dispose();
_supplierEmailController.dispose();
_supplierContactController.dispose();
_businessNameController.dispose();
super.dispose();
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
? Colors.amber[800]!
    : status == ServiceStatus.Approved
? Colors.green[700]!
    : _ServiceManagementScreenState.primaryColor;

final statusBg = status == ServiceStatus.Pending
? const Color(0xFFFFF8E1)
    : status == ServiceStatus.Approved
? const Color(0xFFE8F5E9)
    : _ServiceManagementScreenState.accentColor;

return Scaffold(
backgroundColor: const Color(0xFFFAFAFA),
appBar: AppBar(
title: const Text(
"Service Details",
style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: 0.5),
),
centerTitle: true,
backgroundColor: _ServiceManagementScreenState.primaryColor,
elevation: 0,
systemOverlayStyle: SystemUiOverlayStyle.light,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
onPressed: () => Navigator.of(context).pop(),
),
),
body: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(20.0),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18.0),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 12, offset: const Offset(0, 4))],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
serviceName,
style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ServiceManagementScreenState.textDark),
),
const SizedBox(height: 14),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
child: Text(
status.name,
style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11.5),
),
),
Text(
"₹${price.toStringAsFixed(2)}",
style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.green[700]),
),
],
),
],
),
),
const SizedBox(height: 24),
_buildDetailSection(
title: "Service Information",
icon: Icons.work_outline_rounded,
children: [
_buildDetailItem("Category Mapping", category, Icons.category_outlined),
_buildDetailItem("Description Details", description, Icons.description_outlined),
],
),
const SizedBox(height: 24),
_buildDetailSection(
title: "Supplier Credentials",
icon: Icons.assignment_ind_outlined,
children: [
_buildDetailItem("Vendor Representative", supplierName, Icons.person_outline_rounded),
_buildDetailItem("Corporate Identity", businessName, Icons.business_outlined),
_buildDetailItem("Electronic Mail", supplierEmail, Icons.email_outlined),
_buildDetailItem("Communication Line", supplierContact, Icons.phone_android_rounded),
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
Padding(
padding: const EdgeInsets.only(left: 4.0),
child: Row(
children: [
Icon(icon, color: _ServiceManagementScreenState.primaryColor, size: 18),
const SizedBox(width: 8),
Text(
title,
style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ServiceManagementScreenState.primaryColor, letterSpacing: 0.5),
),
],
),
),
const SizedBox(height: 12),
Container(
width: double.infinity,
padding: const EdgeInsets.all(20.0),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18.0),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 12, offset: const Offset(0, 4))],
),
child: Column(children: children),
),
],
);
}

Widget _buildDetailItem(String label, String value, IconData icon) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(icon, size: 18, color: _ServiceManagementScreenState.textMuted),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(fontSize: 12.5, color: _ServiceManagementScreenState.textMuted, fontWeight: FontWeight.w700),
),
const SizedBox(height: 4),
Text(
value.isNotEmpty ? value : 'Not Documented',
style: const TextStyle(fontSize: 14.5, color: _ServiceManagementScreenState.textDark, fontWeight: FontWeight.w500, height: 1.3),
),
],
),
),
],
),
);
}
}

