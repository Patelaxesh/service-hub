import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'service_details_screen.dart';

class ApproveServicesScreen extends StatefulWidget {
  const ApproveServicesScreen({super.key});

  @override
  _ApproveServicesScreenState createState() => _ApproveServicesScreenState();
}

class _ApproveServicesScreenState extends State<ApproveServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final servicesSnapshot =
        await FirebaseFirestore.instance.collection('services').get();
    List<Map<String, dynamic>> services = [];

    for (var serviceDoc in servicesSnapshot.docs) {
      var serviceData = serviceDoc.data();

      services.add({
        'serviceId': serviceDoc.id,
        'serviceName': serviceData['serviceName'] ?? 'N/A',
        'category': serviceData['category'] ?? 'N/A',
        'supplierName': serviceData['supplierName'] ?? 'N/A',
        'supplierContact': serviceData['supplierContact'] ?? 'N/A',
        'supplierId': serviceData['supplierId'] ?? 'N/A',
        'status': serviceData['status'] ?? 'Pending',
      });
    }

    return services;
  }

  List<Map<String, dynamic>> filterServices(
      List<Map<String, dynamic>> services, String status) {
    return services.where((service) => service['status'] == status).toList();
  }

  Future<void> approveService(
      BuildContext context, Map<String, dynamic> service) async {
    await FirebaseFirestore.instance
        .collection('services')
        .doc(service['serviceId'])
        .update({
      'status': 'Approved',
      'approvedAt': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service Approved!'),
      ),
    );

    setState(() {
      service['status'] = 'Approved';
    });
  }

  Future<void> rejectService(
      BuildContext context, Map<String, dynamic> service) async {
    await FirebaseFirestore.instance
        .collection('services')
        .doc(service['serviceId'])
        .update({
      'status': 'Rejected',
      'rejectedAt': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service Rejected!'),
      ),
    );

    setState(() {
      service['status'] = 'Rejected';
    });
  }

  void _navigateToDetailScreen(
      BuildContext context, Map<String, dynamic> service) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: ServiceDetailsScreen(
                serviceName: service['serviceName'],
                category: service['category'],
                supplierName: service['supplierName'],
                supplierContact: service['supplierContact'],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Services"),
        backgroundColor: Colors.lightBlue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingShimmer();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No services to approve.'));
            } else {
              var services = snapshot.data!;
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildServiceList(filterServices(services, 'Pending')),
                  _buildServiceList(filterServices(services, 'Approved')),
                  _buildServiceList(filterServices(services, 'Rejected')),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceList(List<Map<String, dynamic>> services) {
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        var service = services[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () => _navigateToDetailScreen(context, service),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['serviceName'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Category: ${service['category']}",
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Supplier: ${service['supplierName']}",
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Contact: ${service['supplierContact']}",
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  if (service['status'] == 'Approved')
                    Text(
                      "Approved",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (service['status'] == 'Rejected')
                    Text(
                      "Rejected",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await approveService(context, service);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            "Approve",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            await rejectService(context, service);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
