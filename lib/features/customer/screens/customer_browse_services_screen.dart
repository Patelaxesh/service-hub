import 'package:flutter/material.dart';

import 'customer_suppliers_list_screen.dart';

class CustomerBrowseServicesScreen extends StatefulWidget {
  final String selectedCategory;

  const CustomerBrowseServicesScreen(
      {super.key, required this.selectedCategory});

  @override
  State<CustomerBrowseServicesScreen> createState() =>
      _CustomerBrowseServicesScreenState();
}

class _CustomerBrowseServicesScreenState
    extends State<CustomerBrowseServicesScreen> {
  List<String> allServices = [];
  List<String> filteredServices = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allServices = getServicesByCategory(widget.selectedCategory);
    filteredServices = List.from(allServices);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterServices(String query) {
    setState(() {
      filteredServices = allServices
          .where(
              (service) => service.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<String> getServicesByCategory(String category) {
    Map<String, List<String>> services = {
      'Home Services': [
        'Deep Cleaning',
        'Plumbing Services',
        'Electrical Repairs',
        'Appliance Repair',
        'Pest Control',
        'Moving and Relocation Assistance',
        'Home Renovation',
        'Lawn Care and Landscaping',
        'HVAC Installation and Maintenance',
        'Window Cleaning and Pressure Washing',
        'Painting and Wallpapering',
        'Pool Cleaning and Maintenance',
        'Home Security System Installation',
        'Flooring Installation and Repair',
        'Roof Repairs and Installation',
        'Gutter Cleaning',
        'Smart Home Setup',
        'Handyman Services',
        'Garage Organization and Cleanup',
        'Home Insulation and Weatherproofing',
        'Fence Installation and Repair'
      ],
      'Cleaning Services': [
        'Residential Cleaning',
        'Commercial Cleaning',
        'Carpet Cleaning',
        'Window Cleaning',
        'Deep Cleaning',
        'Post-Construction Cleaning',
        'Move-In/Move-Out Cleaning',
        'Pressure Washing',
        'Disinfection Services',
        'Green Cleaning'
      ],
      'Health & Beauty Services': [
        'Hair Styling and Coloring Services',
        'Skincare and Makeup Services',
        'Massage Therapy',
        'Nail Care and Extensions',
        'Personal Fitness Training',
        'Yoga and Meditation Classes',
        'Teeth Whitening',
        'Mobile Spa Services',
        'Dermatology Consultations',
        'Cosmetic Surgery Consultations'
      ],
      'Event Services': [
        'Catering and Food Services',
        'Photography and Videography Services',
        'Live Band and DJ Arrangements',
        'Themed Party Planning',
        'Invitation Design and Printing',
        'Sound and Lighting Services',
        'Stage Setup and Decoration',
        'Corporate Event Management',
        'Event Hosting and Coordination'
      ],
      'Delivery Services': [
        'Food Delivery',
        'Groceries Delivery',
        'Package and Parcel Delivery',
        'Medication Delivery',
        'Flower and Gift Delivery',
        'Document Courier Services',
        'Same-Day Delivery',
        'Bulk Item Delivery',
        'Furniture Delivery and Assembly',
        'Alcohol Delivery'
      ],
      'Educational Services': [
        'Tutoring (Math, Science, Languages, etc.)',
        'Online Courses and Workshops',
        'Test Preparation (SAT, GRE, GMAT, etc.)',
        'Language Classes',
        'Music Lessons',
        'Art and Craft Classes',
        'Coding and Programming Classes',
        'Career Counseling',
        'Special Education Services',
        'Adult Education and Skill Development'
      ],
      'Automotive Services': [
        'Car Repair and Maintenance',
        'Car Wash and Detailing',
        'Tire Replacement and Repair',
        'Oil Change Services',
        'Brake Repair and Replacement',
        'Windshield Repair and Replacement',
        'Car Towing Services',
        'Vehicle Inspection Services',
        'Car Rental Services',
        'Electric Vehicle Charging Installation'
      ],
      'Childcare Services': [
        'Babysitting',
        'Daycare Services',
        'Nanny Services',
        'After-School Programs',
        'Childproofing Services',
        'Child Counseling',
        'Special Needs Childcare',
        'Summer Camps',
        'Tutoring for Kids',
        'Child Transportation Services'
      ],
      'Pet Services': [
        'Pet Grooming',
        'Pet Sitting and Boarding',
        'Dog Walking',
        'Veterinary Services',
        'Pet Training',
        'Pet Adoption Services',
        'Pet Photography',
        'Pet Supplies Delivery',
        'Pet Waste Removal',
        'Pet Health Insurance Consultation'
      ],
      'Travel Services': [
        'Travel Planning and Booking',
        'Visa and Passport Assistance',
        'Tour Guide Services',
        'Airport Transfers',
        'Car Rental Services',
        'Travel Insurance',
        'Cruise Booking',
        'Adventure Travel Planning',
        'Corporate Travel Management',
        'Luggage Delivery Services'
      ],
      'Legal Services': [
        'Family Law Services',
        'Real Estate Legal Services',
        'Corporate Law Services',
        'Immigration Law Services',
        'Criminal Defense Services',
        'Estate Planning and Wills',
        'Intellectual Property Services',
        'Bankruptcy and Debt Relief',
        'Employment Law Services',
        'Notary Services'
      ],
      'Financial Services': [
        'Tax Preparation and Filing',
        'Loan and Mortgage Services',
        'Investment Advisory Services',
        'Insurance Services',
        'Retirement Planning',
        'Wealth Management',
        'Credit Repair Services',
        'Financial Planning',
        'Bookkeeping Services',
        'Forex Trading Services'
      ],
      'Technology Services': [
        'Tech Support and Maintenance',
        'Software Development',
        'Mobile App Development',
        'Cybersecurity Services',
        'Cloud Computing Solutions',
        'AI and Machine Learning Solutions',
        'Blockchain Development',
        'Data Analytics Services',
        'IT Consulting',
        'Network Setup and Management'
      ],
      'Real Estate Services': [
        'Property Buying and Selling',
        'Rental Management',
        'Property Valuation',
        'Real Estate Consulting',
        'Home Inspection Services',
        'Mortgage Services',
        'Commercial Real Estate Services',
        'Property Development',
        'Real Estate Photography',
        'Leasing Services'
      ],
      'Creative Services': [
        'Graphic Design',
        'Content Creation',
        'Video Production',
        'Branding and Logo Design',
        'Social Media Content Creation',
        'Photography Services',
        'Copywriting',
        'Animation Services',
        'UI/UX Design',
        'Creative Consulting'
      ],
      'Repair and Maintenance Services': [
        'Appliance Repair',
        'Plumbing Repairs',
        'Electrical Repairs',
        'Furniture Repair',
        'Electronics Repair',
        'HVAC Maintenance',
        'Roof Repairs',
        'Car Repair and Maintenance',
        'Computer and Laptop Repair',
        'Home Renovation Services'
      ],
      'Medical Services': [
        'Telemedicine',
        'Home Healthcare',
        'Diagnostic Services',
        'Physiotherapy',
        'Mental Health Counseling',
        'Dental Services',
        'Pharmacy Services',
        'Emergency Medical Services',
        'Specialist Consultations',
        'Medical Equipment Rental'
      ],
      'Logistics and Transportation': [
        'Freight Services',
        'Moving and Relocation',
        'Warehouse Services',
        'Fleet Management',
        'Last-Mile Delivery',
        'Supply Chain Management',
        'Courier Services',
        'International Shipping',
        'Cold Chain Logistics',
        'Customs Clearance Services'
      ],
      'Environmental Services': [
        'Waste Management',
        'Recycling Services',
        'Solar Panel Installation',
        'Water Purification',
        'Eco-Friendly Consulting',
        'Energy Efficiency Audits',
        'Green Building Certification',
        'Environmental Impact Assessments',
        'Air Quality Testing',
        'Sustainable Landscaping'
      ],
      'Entertainment Services': [
        'Event DJs',
        'Live Performances',
        'Game Rentals',
        'Photo Booth Rentals',
        'Comedy Shows',
        'Themed Entertainment',
        'Virtual Reality Experiences',
        'Karaoke Services',
        'Party Entertainment',
        'Corporate Entertainment'
      ],
      'Security Services': [
        'Home Security Systems',
        'Surveillance Services',
        'Bodyguard Services',
        'Cybersecurity Consulting',
        'Alarm System Installation',
        'Event Security',
        'Corporate Security',
        'Background Check Services',
        'Security Training',
        'Access Control Systems'
      ],
      'Agricultural Services': [
        'Farm Equipment Rental',
        'Crop Consulting',
        'Irrigation Services',
        'Livestock Care',
        'Organic Farming Support',
        'Soil Testing',
        'Pest and Disease Management',
        'Agricultural Marketing',
        'Farm Management Software',
        'Greenhouse Setup and Maintenance'
      ],
      'Non-Profit and Social Services': [
        'Volunteer Services',
        'Fundraising Assistance',
        'Community Outreach',
        'Disaster Relief',
        'Charity Events',
        'Social Work Services',
        'Youth Programs',
        'Elderly Care Services',
        'Food Banks and Distribution',
        'Housing Assistance'
      ],
      'Miscellaneous Services': [
        'Personal Shopping',
        'Errand Running',
        'Gift Wrapping',
        'Mystery Shopping',
        'Custom Services',
        'Pet Sitting',
        'House Sitting',
        'Personal Assistant Services',
        'Event Staffing',
        'Concierge Services'
      ],
    };

    // Return the list of services for the given category
    return services[category] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCategory),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Search Services",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterServices('');
                        },
                      )
                    : null,
              ),
              onChanged: filterServices,
            ),
            const SizedBox(height: 16.0),
            filteredServices.isEmpty
                ? const Center(
                    child: Text(
                      "No services available",
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: const Icon(
                              Icons.design_services,
                              size: 40.0,
                              color: Colors.greenAccent,
                            ),
                            title: Text(filteredServices[index]),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      CustomerSuppliersListScreen(
                                    serviceName: filteredServices[index],
                                    categoryName: widget
                                        .selectedCategory, // Pass the actual category instead of empty string
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
