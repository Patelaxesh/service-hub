import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:serviceshub/features/supplier/screens/supplier_dashboard_screen.dart';
import 'package:serviceshub/features/supplier/screens/supplier_forgot_password_screen.dart';
import 'package:serviceshub/features/supplier/screens/supplier_signup_screen.dart';

// Brand primary color defined here
const Color primaryColor = Color(0xFFE53935);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Fixed: Added named key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supplier Login',
      theme: ThemeData(
        // Using primaryColor to generate the color scheme
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        primaryColor: primaryColor,
      ),
      // SupplierScreen now acts as our smart Gateway/Auth Router
      home: const SupplierScreen(),
    );
  }
}

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This callback executes immediately after the layout pass
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in, skip the login form entirely!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SupplierDashboardScreen(uid: user.uid),
          ),
        );
      } else {
        // No active session found, take them to the login gate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SupplierLoginScreen(),
          ),
        );
      }
    });

    // Clean, modern look while checking authentication status
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }
}

class SupplierLoginScreen extends StatefulWidget {
  final String? uid;

  const SupplierLoginScreen({super.key, this.uid});

  @override
  State<SupplierLoginScreen> createState() => _SupplierLoginScreenState(); // Fixed: Exposing private types in public APIs
}

class _SupplierLoginScreenState extends State<SupplierLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully! Please login."),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  void _handleLogin(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email cannot be empty!"),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address!"),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password cannot be empty!"),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return; // Fixed: Guarded BuildContext usage across async gaps

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SupplierDashboardScreen(uid: userCredential.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Fixed: Guarded BuildContext usage across async gaps
      String message = e.message ?? "An error occurred. Please try again.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Login"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // Ensures text/icons are visible on red
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Supplier Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                focusNode: _passwordFocusNode,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const SupplierForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}