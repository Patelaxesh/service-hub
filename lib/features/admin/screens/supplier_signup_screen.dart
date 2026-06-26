import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:serviceshub/features/admin/screens/supplier_login_screen.dart';

class SupplierSignupScreen extends StatefulWidget {
  const SupplierSignupScreen({super.key});

  @override
  State<SupplierSignupScreen> createState() => _SupplierSignupScreenState();
}

class _SupplierSignupScreenState extends State<SupplierSignupScreen> {
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

// Static Gender List
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
            random.nextInt(characters.length),
          ),
        ),
      );
    });
  }

// Signup Function
  Future<void> _handleSignUp() async {
// Captcha Check
    if (_captchaController.text != _captcha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Captcha does not match!"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

// Password Match Check
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

// Password Length Check
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters!"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

// Gender Check
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select gender"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

// Country State City Check
    if (_country == null || _state == null || _city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Country, State and City"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

// Loading Start
    setState(() {
      _isLoading = true;
    });

    try {
// Create User
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

// User ID
      String userId = userCredential.user!.uid;

// Save Data in Firestore
      await _firestore.collection("Suppliers").doc(userId).set({
        "uid": userId,
        "firstName": _firstNameController.text.trim(),
        "middleName": _middleNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "dob": _dobController.text.trim(),
        "email": _emailController.text.trim(),
        "mobileNumber": _mobileNumberController.text.trim(),
        "gender": _selectedGender,
        "country": _country,
        "state": _state,
        "city": _city,
        "accountType": "supplier",
        "emailVerified": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

// Send Verification Email
      await userCredential.user!.sendEmailVerification();

// Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Account created successfully. "
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
          builder: (context) => SupplierLoginScreen(uid: userId),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to create account";

      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email already exists.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong",
          ),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text("Supplier Signup"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Supplier Signup",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

// First Name
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

// Middle Name
              TextField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Middle Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

// Last Name
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

// DOB
              TextFormField(
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
                      _dobController.text =
                          '${selectedDate.toLocal()}'.split(' ')[0];
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

// Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
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

              const SizedBox(height: 16),

// Email
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

// Mobile Number
              TextField(
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

// Password
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

// Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

// Country Dropdown
              DropdownButtonFormField<String>(
                value: _country,
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

              const SizedBox(height: 16),

// State Dropdown
              DropdownButtonFormField<String>(
                value: _state,
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

              const SizedBox(height: 16),

// City Dropdown
              DropdownButtonFormField<String>(
                value: _city,
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

              const SizedBox(height: 16),

// Captcha
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
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: _generateCaptcha,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

// Signup Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Signup",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

// Login Text
              Row(
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
}
