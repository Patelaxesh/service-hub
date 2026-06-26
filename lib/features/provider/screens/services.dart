import 'package:flutter/material.dart';
import 'package:serviceshub/features/provider/screens/service_details_screen.dart';


// Define a Service class to hold the service details
class Service {
  final String serviceName;
  final String category;
  final String supplierName;
  final String supplierContact;
  final String description; // Added description
  final double price; // Added price

  Service({
    required this.serviceName,
    required this.category,
    required this.supplierName,
    required this.supplierContact,
    required this.description, // Added description
    required this.price, // Added price
  });
}

// Example data (This could be fetched from an API or database)
List<Service> services = [
  Service(
    serviceName: "Web Development",
    category: "IT Services",
    supplierName: "John Doe",
    supplierContact: "123-456-7890",
    description: "Professional web development services.",
    price: 100.00, // Added price
  ),
  Service(
    serviceName: "Graphic Design",
    category: "Creative Services",
    supplierName: "Jane Smith",
    supplierContact: "987-654-3210",
    description: "Creative design services for logos, brochures, and more.",
    price: 80.00, // Added price
  ),
  Service(
    serviceName: "Plumbing",
    category: "Home Services",
    supplierName: "Mike Johnson",
    supplierContact: "555-123-4567",
    description: "Reliable plumbing services for all your needs.",
    price: 50.00, // Added price
  ),
];

class ServiceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ListTile(
            title: Text(service.serviceName),
            subtitle: Text(service.category),
            onTap: () {
              // Navigate to the ServiceDetailsScreen with the selected service
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsScreen(
                    serviceName: service.serviceName,
                    category: service.category,
                    description: service.description, // Pass description
                    price: service.price, // Pass price
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'supplier_login_screen.dart';
import 'dart:math';

class SupplierSignUpScreen extends StatefulWidget {
  const SupplierSignUpScreen({super.key});

  @override
  _SupplierSignUpScreenState createState() => _SupplierSignUpScreenState();
}

class _SupplierSignUpScreenState extends State<SupplierSignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedService;
  List<String> _services = []; // Dynamic services list
  String? _selectedGender;
  List<String> _genders = ["Male", "Female", "Other"]; // Gender options list
  String _captcha = '';

  // New Fields for Address (County, State, City)
  String? _selectedCounty;
  String? _selectedState;
  String? _selectedCity;

  final List<String> _counties = [
    'County 1',
    'County 2',
    'County 3'
  ]; // Example counties
  final List<String> _states = [
    'State 1',
    'State 2',
    'State 3'
  ]; // Example states
  final List<String> _cities = ['City 1', 'City 2', 'City 3']; // Example cities

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchServicesFromAdmin(); // Fetch services when the screen loads
    _generateCaptcha(); // Generate initial captcha
  }

  Future<void> _fetchServicesFromAdmin() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _services = [
        "Delivery",
        "Logistics",
        "Product Supply",
        "Consultancy",
        "Other"
      ]; // Example services fetched
    });
  }

  void _generateCaptcha() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    setState(() {
      _captcha = String.fromCharCodes(
        Iterable.generate(
            6, (_) => characters.codeUnitAt(random.nextInt(characters.length))),
      );
    });
  }

  void _handleSignUp() {
    if (_captchaController.text != _captcha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Captcha does not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String dob = _dobController.text;
    final String email = _emailController.text;
    final String mobileNumber = _mobileNumberController.text;
    final String password = _passwordController.text;
    final String service = _selectedService ?? "Not Selected";

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a service."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure County, State, and City are selected
    if (_selectedCounty == null ||
        _selectedState == null ||
        _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your County, State, and City."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Account created for $firstName $lastName as $service!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SupplierLoginScreen(),
      ),
    );
  }

  void _requestOtp(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("OTP sent to $type!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Signup"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Supplier Signup",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Middle Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Prevent manual text input
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900), // Restricting the date range
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dobController.text = '${selectedDate.toLocal()}'
                          .split(' ')[0]; // Format date
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _requestOtp("email"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text(
                      "Get OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        labelText: "Mobile Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _requestOtp("mobile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text(
                      "Get OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _services.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                value: _selectedService,
                items: _services.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.store),
                  labelText: "Service Provided",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                      value: gender, child: Text(gender));
                }).toList(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.transgender),
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCounty,
                items: _counties.map((String county) {
                  return DropdownMenuItem<String>(
                    value: county,
                    child: Text(county),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.public),
                  labelText: "County",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCounty = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedState,
                items: _states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_city),
                  labelText: "State",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                items: _cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captchaController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.security),
                        labelText: "Enter Captcha",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _captcha,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generateCaptcha,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Signup",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupplierLoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.red,
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
  }
}*/

/*
import 'package:flutter/material.dart';
import 'supplier_dashboard_screen.dart';
import 'supplier_signup_screen.dart';
import 'supplier side/forgot_password_screen.dart'; // Add your ForgotPasswordScreen file here

class SupplierLoginScreen extends StatefulWidget {
  const SupplierLoginScreen({super.key});

  @override
  _SupplierLoginScreenState createState() => _SupplierLoginScreenState();
}

class _SupplierLoginScreenState extends State<SupplierLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Email validation function
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  void _handleLogin(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    // Email validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email cannot be empty!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password cannot be empty!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate login delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Dummy validation for login
    if (email == "axesh@gmail.com" && password == "1") {
      // Clear the text fields on successful login
      _emailController.clear();
      _passwordController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SupplierDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Login"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Supplier Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Email Input Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Password Input Field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Forgot Password Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Login Button with Loading indicator
            ElevatedButton(
              onPressed: _isLoading ? null : () => _handleLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            // Row for Sign Up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupplierSignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Signup",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
