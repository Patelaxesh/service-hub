import 'package:flutter/material.dart';
import 'package:serviceshub/features/customer/screens/service_details_screen.dart';

// Supplier Model
class Supplier {
  final String name, contact, phone, description;
  final double price, rating;

  Supplier({
    required this.name,
    required this.contact,
    required this.phone,
    required this.price,
    required this.description,
    required this.rating,
  });
}

class SuppliersListScreen extends StatelessWidget {
  final String serviceName;
  final String categoryName;

  const SuppliersListScreen({
    super.key,
    required this.serviceName,
    required this.categoryName,
  });

  // Get suppliers based on category
  List<Supplier> getSuppliersForService() {
    switch (categoryName) {
      case 'Home Services':
        return [
          Supplier(
              name: 'HomeCare Solutions',
              contact: 'homecare@gmail.com',
              phone: '+91 91234 56789',
              price: 1999.0,
              description: 'Complete home maintenance and repair services.',
              rating: 4.7),
          Supplier(
              name: 'FixIt Professionals',
              contact: 'fixit@gmail.com',
              phone: '+91 98765 12340',
              price: 1499.0,
              description: 'Skilled technicians for all home needs.',
              rating: 4.4),
          Supplier(
              name: 'Urban Home Services',
              contact: 'urbanhomes@gmail.com',
              phone: '+91 87654 32109',
              price: 1799.0,
              description: 'Reliable home services with quick response.',
              rating: 4.6),
        ];

      case 'Cleaning Services':
        return [
          Supplier(
              name: 'Raut Cleaners',
              contact: 'rautcleaners@gmail.com',
              phone: '+91 98765 43210',
              price: 1299.0,
              description: 'Top-notch cleaning services for homes and offices.',
              rating: 4.5),
          Supplier(
              name: 'Verma Home Services',
              contact: 'vermahome@gmail.com',
              phone: '+91 87654 32109',
              price: 1599.0,
              description: 'Expert home cleaning with eco-friendly products.',
              rating: 4.8),
          Supplier(
              name: 'Patel Fresh Services',
              contact: 'patelfresh@gmail.com',
              phone: '+91 76543 21098',
              price: 1000.0,
              description: 'Affordable and reliable cleaning services.',
              rating: 4.2),
        ];

      case 'Health & Beauty Services':
        return [
          Supplier(
              name: 'Glamour Spa',
              contact: 'glamourspa@gmail.com',
              phone: '+91 99887 76655',
              price: 2499.0,
              description: 'Luxury spa and beauty treatments.',
              rating: 4.9),
          Supplier(
              name: 'Wellness Center',
              contact: 'wellness@gmail.com',
              phone: '+91 87654 98765',
              price: 1799.0,
              description: 'Holistic health and beauty services.',
              rating: 4.6),
          Supplier(
              name: 'Beauty Bliss',
              contact: 'beautybliss@gmail.com',
              phone: '+91 98765 43210',
              price: 1999.0,
              description: 'Professional beauty and wellness treatments.',
              rating: 4.7),
        ];

      case 'Event Services':
        return [
          Supplier(
              name: 'Event Masters',
              contact: 'eventmasters@gmail.com',
              phone: '+91 98765 43210',
              price: 50000.0,
              description: 'Complete event planning and management.',
              rating: 4.8),
          Supplier(
              name: 'Celebration Planners',
              contact: 'celebration@gmail.com',
              phone: '+91 87654 32109',
              price: 35000.0,
              description: 'Making your special occasions memorable.',
              rating: 4.5),
        ];

      case 'Delivery Services':
        return [
          Supplier(
              name: 'QuickDrop',
              contact: 'quickdrop@gmail.com',
              phone: '+91 91234 56789',
              price: 99.0,
              description: 'Fast and reliable delivery services.',
              rating: 4.3),
          Supplier(
              name: 'Speedy Couriers',
              contact: 'speedy@gmail.com',
              phone: '+91 98765 12340',
              price: 79.0,
              description: 'Same-day delivery across the city.',
              rating: 4.1),
        ];

      case 'Educational Services':
        return [
          Supplier(
              name: 'EduCare Tutors',
              contact: 'educare@gmail.com',
              phone: '+91 98765 43210',
              price: 499.0,
              description: 'Professional tutoring for all subjects.',
              rating: 4.6),
          Supplier(
              name: 'Bright Minds Academy',
              contact: 'brightminds@gmail.com',
              phone: '+91 87654 32109',
              price: 599.0,
              description: 'Quality education services for all ages.',
              rating: 4.8),
        ];

      case 'Automotive Services':
        return [
          Supplier(
              name: 'AutoCare Solutions',
              contact: 'autocare@gmail.com',
              phone: '+91 98765 43210',
              price: 999.0,
              description: 'Complete automotive repair and maintenance.',
              rating: 4.5),
          Supplier(
              name: 'QuickFix Mechanics',
              contact: 'quickfix@gmail.com',
              phone: '+91 87654 32109',
              price: 799.0,
              description: 'Fast and reliable car repair services.',
              rating: 4.3),
        ];

      case 'Childcare Services':
        return [
          Supplier(
              name: 'Little Angels Care',
              contact: 'littleangels@gmail.com',
              phone: '+91 98765 43210',
              price: 1299.0,
              description: 'Professional childcare with loving environment.',
              rating: 4.7),
          Supplier(
              name: 'Happy Kids Center',
              contact: 'happykids@gmail.com',
              phone: '+91 87654 32109',
              price: 1099.0,
              description: 'Safe and fun childcare services.',
              rating: 4.5),
        ];

      case 'Pet Services':
        return [
          Supplier(
              name: 'Paws & Claws',
              contact: 'pawsclaws@gmail.com',
              phone: '+91 98765 43210',
              price: 899.0,
              description: 'Complete pet care including grooming and boarding.',
              rating: 4.8),
          Supplier(
              name: 'Pet Paradise',
              contact: 'petparadise@gmail.com',
              phone: '+91 87654 32109',
              price: 699.0,
              description: 'Quality services for your furry friends.',
              rating: 4.6),
        ];

      case 'Travel Services':
        return [
          Supplier(
              name: 'TravelEase',
              contact: 'travelease@gmail.com',
              phone: '+91 98765 43210',
              price: 0.0,
              description: 'Customized travel packages and bookings.',
              rating: 4.7),
          Supplier(
              name: 'Wanderlust Tours',
              contact: 'wanderlust@gmail.com',
              phone: '+91 87654 32109',
              price: 0.0,
              description: 'Adventure and leisure travel planning.',
              rating: 4.9),
        ];

      case 'Legal Services':
        return [
          Supplier(
              name: 'LegalEase Consultants',
              contact: 'legalease@gmail.com',
              phone: '+91 98765 43210',
              price: 2999.0,
              description: 'Comprehensive legal advice and services.',
              rating: 4.8),
          Supplier(
              name: 'Justice Partners',
              contact: 'justicepartners@gmail.com',
              phone: '+91 87654 32109',
              price: 2499.0,
              description: 'Expert legal representation and consultation.',
              rating: 4.6),
        ];

      case 'Financial Services':
        return [
          Supplier(
              name: 'MoneyMatters Advisors',
              contact: 'moneymatters@gmail.com',
              phone: '+91 98765 43210',
              price: 0.0,
              description: 'Financial planning and investment advice.',
              rating: 4.7),
          Supplier(
              name: 'WealthBuild Consultants',
              contact: 'wealthbuild@gmail.com',
              phone: '+91 87654 32109',
              price: 0.0,
              description: 'Tax planning and wealth management services.',
              rating: 4.5),
        ];

      case 'Technology Services':
        return [
          Supplier(
              name: 'TechGenius Solutions',
              contact: 'techgenius@gmail.com',
              phone: '+91 98765 43210',
              price: 1999.0,
              description: 'IT support and technology consulting.',
              rating: 4.8),
          Supplier(
              name: 'DigitalEdge Services',
              contact: 'digitaledge@gmail.com',
              phone: '+91 87654 32109',
              price: 1499.0,
              description: 'Web development and digital solutions.',
              rating: 4.6),
        ];

      case 'Real Estate Services':
        return [
          Supplier(
              name: 'Prime Properties',
              contact: 'primeproperties@gmail.com',
              phone: '+91 98765 43210',
              price: 0.0,
              description: 'Property buying, selling and rental services.',
              rating: 4.7),
          Supplier(
              name: 'HomeFinders Associates',
              contact: 'homefinders@gmail.com',
              phone: '+91 87654 32109',
              price: 0.0,
              description: 'Real estate consultation and brokerage.',
              rating: 4.5),
        ];

      case 'Creative Services':
        return [
          Supplier(
              name: 'CreativeMinds Studio',
              contact: 'creativeminds@gmail.com',
              phone: '+91 98765 43210',
              price: 2999.0,
              description: 'Graphic design and creative solutions.',
              rating: 4.8),
          Supplier(
              name: 'Artisan Works',
              contact: 'artisanworks@gmail.com',
              phone: '+91 87654 32109',
              price: 2499.0,
              description: 'Photography, videography and creative services.',
              rating: 4.6),
        ];

      case 'Repair and Maintenance Services':
        return [
          Supplier(
              name: 'FixAll Repairs',
              contact: 'fixall@gmail.com',
              phone: '+91 98765 43210',
              price: 999.0,
              description: 'Appliance and equipment repair services.',
              rating: 4.5),
          Supplier(
              name: 'Maintenance Pros',
              contact: 'maintenancepros@gmail.com',
              phone: '+91 87654 32109',
              price: 799.0,
              description: 'Professional maintenance for home and office.',
              rating: 4.3),
        ];

      case 'Medical Services':
        return [
          Supplier(
              name: 'MediCare Providers',
              contact: 'medicare@gmail.com',
              phone: '+91 98765 43210',
              price: 0.0,
              description: 'Healthcare services and medical consultation.',
              rating: 4.9),
          Supplier(
              name: 'HealthFirst Clinics',
              contact: 'healthfirst@gmail.com',
              phone: '+91 87654 32109',
              price: 0.0,
              description: 'Comprehensive medical care services.',
              rating: 4.7),
        ];

      case 'Logistics and Transportation':
        return [
          Supplier(
              name: 'Swift Logistics',
              contact: 'swiftlogistics@gmail.com',
              phone: '+91 98765 43210',
              price: 1499.0,
              description: 'Freight and cargo transportation services.',
              rating: 4.6),
          Supplier(
              name: 'City Movers',
              contact: 'citymovers@gmail.com',
              phone: '+91 87654 32109',
              price: 1299.0,
              description: 'Reliable local and long-distance moving.',
              rating: 4.4),
        ];

      case 'Environmental Services':
        return [
          Supplier(
              name: 'GreenEarth Solutions',
              contact: 'greenearth@gmail.com',
              phone: '+91 98765 43210',
              price: 1999.0,
              description: 'Eco-friendly waste management services.',
              rating: 4.7),
          Supplier(
              name: 'EcoCare Services',
              contact: 'ecocare@gmail.com',
              phone: '+91 87654 32109',
              price: 1799.0,
              description: 'Environmental consulting and services.',
              rating: 4.5),
        ];

      case 'Entertainment Services':
        return [
          Supplier(
              name: 'Star Performers',
              contact: 'starperformers@gmail.com',
              phone: '+91 98765 43210',
              price: 4999.0,
              description: 'Entertainment for events and parties.',
              rating: 4.8),
          Supplier(
              name: 'FunTimes Events',
              contact: 'funtimes@gmail.com',
              phone: '+91 87654 32109',
              price: 3999.0,
              description: 'DJs, performers and event entertainment.',
              rating: 4.6),
        ];

      case 'Security Services':
        return [
          Supplier(
              name: 'SafeGuard Security',
              contact: 'safeguard@gmail.com',
              phone: '+91 98765 43210',
              price: 2999.0,
              description: 'Professional security personnel and systems.',
              rating: 4.7),
          Supplier(
              name: 'Vigilant Protection',
              contact: 'vigilant@gmail.com',
              phone: '+91 87654 32109',
              price: 2499.0,
              description: '24/7 security services for homes and businesses.',
              rating: 4.5),
        ];

      case 'Agricultural Services':
        return [
          Supplier(
              name: 'AgriCare Solutions',
              contact: 'agricare@gmail.com',
              phone: '+91 98765 43210',
              price: 1999.0,
              description: 'Farm equipment and agricultural services.',
              rating: 4.6),
          Supplier(
              name: 'GreenFields Services',
              contact: 'greenfields@gmail.com',
              phone: '+91 87654 32109',
              price: 1799.0,
              description: 'Crop care and farming consultation.',
              rating: 4.4),
        ];

      case 'Non-Profit and Social Services':
        return [
          Supplier(
              name: 'Community Helpers',
              contact: 'community@gmail.com',
              phone: '+91 98765 43210',
              price: 0.0,
              description: 'Social services and community support.',
              rating: 4.9),
          Supplier(
              name: 'Hope Foundation',
              contact: 'hope@gmail.com',
              phone: '+91 87654 32109',
              price: 0.0,
              description: 'Non-profit social welfare services.',
              rating: 4.8),
        ];

      case 'Miscellaneous Services':
        return [
          Supplier(
              name: 'All-In-One Services',
              contact: 'allinone@gmail.com',
              phone: '+91 98765 43210',
              price: 999.0,
              description: 'Various services for all your needs.',
              rating: 4.5),
          Supplier(
              name: 'HandyHelpers',
              contact: 'handyhelpers@gmail.com',
              phone: '+91 87654 32109',
              price: 799.0,
              description: 'Odd jobs and miscellaneous tasks.',
              rating: 4.3),
        ];

      default:
        return [
          Supplier(
              name: 'General Service Provider',
              contact: 'service@example.com',
              phone: '+91 00000 00000',
              price: 999.0,
              description: 'Professional service for your needs.',
              rating: 4.0),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = getSuppliersForService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Suppliers for $serviceName"),
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return _buildSupplierCard(context, supplier);
        },
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: const Icon(
          Icons.store,
          color: Colors.greenAccent,
          size: 40.0,
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 18.0),
                const SizedBox(width: 4.0),
                Text("${supplier.rating} / 5",
                    style: const TextStyle(fontSize: 14.0)),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              supplier.price > 0
                  ? "Price starting at ₹${supplier.price}"
                  : "Contact for pricing",
              style:
                  const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsScreen(
                serviceName: serviceName,
                serviceDescription: supplier.description,
                price: supplier.price,
                supplierName: supplier.name,
                supplierContact: supplier.contact,
                supplierPhone: supplier.phone,
                categoryName: categoryName,
              ),
            ),
          );
        },
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_details_screen.dart';

class Supplier {
  final String id;
  final String name;
  final String email;
  final String contact;
  final double price;
  final String description;
  final double rating;

  Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.price,
    required this.description,
    required this.rating,
  });

  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: data['supplierName'] ?? '',
      email: data['supplierEmail'] ?? '',
      contact: data['supplierContact'] ?? '',
      price: (data['pricing'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      rating: 4.5,
    );
  }
}

class SuppliersListScreen extends StatefulWidget {
  final String serviceName;
  final String categoryName;

  const SuppliersListScreen({
    super.key,
    required this.serviceName,
    required this.categoryName,
  });

  @override
  State<SuppliersListScreen> createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _suppliersStream;

  @override
  void initState() {
    super.initState();
    _suppliersStream = _firestore
        .collection('services')
        .where('serviceName', isEqualTo: widget.serviceName)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.categoryName),
            Text(
              widget.serviceName,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Suppliers for ${widget.serviceName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _suppliersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No suppliers found for ${widget.serviceName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final supplier = Supplier.fromFirestore(snapshot.data!.docs[index]);
                    return _buildSupplierCard(context, supplier);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: const Icon(
          Icons.store,
          color: Colors.greenAccent,
          size: 40.0,
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 18.0),
                const SizedBox(width: 4.0),
                Text("${supplier.rating} / 5",
                    style: const TextStyle(fontSize: 14.0)),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              "Price: ₹${supplier.price}",
              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
            Text(
              "Service: ${widget.serviceName}",
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsScreen(
                serviceName: widget.serviceName,
                serviceDescription: supplier.description,
                price: supplier.price,
                supplierName: supplier.name,
                supplierContact: supplier.contact,
                supplierPhone: supplier.email,
                categoryName: widget.categoryName,
              ),
            ),
          );
        },
      ),
    );
  }
}
 */
