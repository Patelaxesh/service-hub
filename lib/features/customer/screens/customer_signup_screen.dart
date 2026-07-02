import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'customer_login_screen.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
// Controllers
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _middleNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _mobileNumberController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _captchaController = TextEditingController();

  final TextEditingController _dobController = TextEditingController();

// Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Variables
  String? _selectedGender;

  String? _country;

  String? _state;

  String? _city;

  String _captcha = '';

  bool _isPasswordVisible = false;

  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;

// Gender List
  final List<String> _genders = [
    "Male",
    "Female",
    "Other",
  ];

// Static Country List
  final List<String> _countries = [
    "India",
    "USA",
  ];

// Static State List
  final List<String> _states = [
    "Gujarat",
    "Maharashtra",
    "Delhi",
  ];

// Static City List
  final List<String> _cities = [
    "Surat",
    "Ahmedabad",
    "Mumbai",
    "Delhi",
  ];

  @override
  void initState() {
    super.initState();

    _generateCaptcha();
  }

// Generate Captcha
  void _generateCaptcha() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final random = Random();

    setState(() {
      _captcha = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => characters.codeUnitAt(
            random.nextInt(
              characters.length,
            ),
          ),
        ),
      );
    });
  }

// Error Snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

// Firebase Error
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage = "Failed to create account.";

    switch (e.code) {
      case 'weak-password':
        errorMessage = "The password provided is too weak.";
        break;

      case 'email-already-in-use':
        errorMessage = "The account already exists.";
        break;

      case 'invalid-email':
        errorMessage = "The email address is invalid.";
        break;
    }

    _showErrorSnackbar(errorMessage);
  }

// Signup Function
  Future<void> _handleSignUp() async {
// Captcha Check
    if (_captchaController.text != _captcha) {
      _showErrorSnackbar("Captcha does not match!");

      return;
    }

// Password Match Check
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackbar("Passwords do not match!");

      return;
    }

// Password Length Check
    if (_passwordController.text.length < 6) {
      _showErrorSnackbar("Password must be at least 6 characters.");

      return;
    }

// Gender Check
    if (_selectedGender == null) {
      _showErrorSnackbar("Please select your gender.");

      return;
    }

// Country State City Check
    if (_country == null || _state == null || _city == null) {
      _showErrorSnackbar("Please select Country, State and City.");

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
// Create Firebase User
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

// User ID
      String userId = userCredential.user!.uid;

// Save Data in Firestore
      await _firestore.collection('customers').doc(userId).set({
        'uid': userId,
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'mobileNumber': _mobileNumberController.text.trim(),
        'gender': _selectedGender,
        'country': _country,
        'state': _state,
        'city': _city,
        'accountType': 'customer',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

// Send Verification Email
      await userCredential.user!.sendEmailVerification();

// Success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Customer account created successfully. "
            "Verification email sent to "
            "${_emailController.text}",
          ),
          backgroundColor: Colors.green,
        ),
      );

// Navigate Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerLoginScreen(
            uid: userId,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      _showErrorSnackbar("Something went wrong.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Signup"),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Create Customer Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

// Personal Information
              _buildSectionHeader("Personal Information"),

              _buildTextField(
                _firstNameController,
                "First Name",
                Icons.person,
              ),

              _buildTextField(
                _middleNameController,
                "Middle Name",
                Icons.person,
              ),

              _buildTextField(
                _lastNameController,
                "Last Name",
                Icons.person_outline,
              ),

              _buildDateOfBirthField(),

              _buildGenderDropdown(),

// Contact Information
              _buildSectionHeader("Contact Information"),

              _buildTextField(
                _emailController,
                "Email",
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              _buildTextField(
                _mobileNumberController,
                "Mobile Number",
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),

// Security
              _buildSectionHeader("Security"),

              _buildPasswordField(
                _passwordController,
                "Password",
                _isPasswordVisible,
                () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),

              _buildPasswordField(
                _confirmPasswordController,
                "Confirm Password",
                _isConfirmPasswordVisible,
                () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),

// Location
              _buildSectionHeader("Location"),

              _buildLocationPicker(),

// Verification
              _buildSectionHeader("Verification"),

              _buildCaptchaField(),

// Signup Button
              _buildSignupButton(),

// Login Link
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

// Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

// Text Field
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

// DOB Field
  Widget _buildDateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          labelText: "Date of Birth",
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (selectedDate != null) {
            setState(() {
              _dobController.text = '${selectedDate.toLocal()}'.split(' ')[0];
            });
          }
        },
      ),
    );
  }

// Gender Dropdown
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.transgender),
          labelText: "Gender",
          border: OutlineInputBorder(),
        ),
        items: _genders.map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
      ),
    );
  }

// Password Field
  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isVisible,
    VoidCallback onVisibilityChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onVisibilityChanged,
          ),
        ),
      ),
    );
  }

// Location Picker
  Widget _buildLocationPicker() {
    return Column(
      children: [
// Country Dropdown
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _country,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.flag),
              labelText: "Country",
              border: OutlineInputBorder(),
            ),
            items: _countries.map((country) {
              return DropdownMenuItem(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _country = value;
              });
            },
          ),
        ),

// State Dropdown
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _state,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.map),
              labelText: "State",
              border: OutlineInputBorder(),
            ),
            items: _states.map((state) {
              return DropdownMenuItem(
                value: state,
                child: Text(state),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _state = value;
              });
            },
          ),
        ),

// City Dropdown
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _city,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_city),
              labelText: "City",
              border: OutlineInputBorder(),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _city = value;
              });
            },
          ),
        ),
      ],
    );
  }

// Captcha Field
  Widget _buildCaptchaField() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
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
    );
  }

// Signup Button
  Widget _buildSignupButton() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              )
            : const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

// Login Link
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerLoginScreen(
                  uid: '',
                ),
              ),
            );
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
