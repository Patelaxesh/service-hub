import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore dependency
import 'my_bookings_screen.dart'; // Assuming this is your bookings screen

class PaymentScreen extends StatefulWidget {
  final String serviceName;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.serviceName,
    required this.totalAmount,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPaymentMethod;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCouponApplied = false;
  double _discount = 0.0;
  final TextEditingController _addressController = TextEditingController();

  // Fields for Card Payment
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCVVController = TextEditingController();

  // Fields for UPI Payment
  final TextEditingController _upiIdController = TextEditingController();

  // Fields for Net Banking
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  // Fields for Wallets
  final TextEditingController _walletNumberController = TextEditingController();

  // Save booking data to Firestore
  // Save booking data to Firestore
  // Save booking data to Firestore
  Future<void> _saveBookingToFirestore() async {
    final double finalAmount = widget.totalAmount - _discount;
    // Set commission to 0 if payment method is COD, otherwise calculate 8%
    final double commission =
        selectedPaymentMethod == 'cod' ? 0.0 : finalAmount * 0.08;

    // Create a map with the booking details
    Map<String, dynamic> bookingData = {
      'serviceName': widget.serviceName,
      'finalAmount': finalAmount,
      'commission': commission,
      'bookingDate': DateTime.now().toString(),
      'serviceProvider': "Axesh Patel", // Replace with dynamic provider name
      'paymentMethod': selectedPaymentMethod ?? "Unknown",
      'bookingStatus': "Confirmed",
      'address': _addressController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add a new document with a generated ID to the "bookings" collection
    await FirebaseFirestore.instance.collection('bookings').add(bookingData);
  }

  void _handlePaymentConfirmation() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a payment processing delay
    await Future.delayed(Duration(seconds: 2));

    // Save the booking details to Firestore
    await _saveBookingToFirestore();

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful!"),
      ),
    );

    // Navigate to MyBookingsScreen with data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyBookingsScreen(
          serviceName: widget.serviceName,
          finalAmount: widget.totalAmount - _discount,
          bookingDate: "2025-4-15", // Replace with dynamic date
          serviceProvider: "Axesh Patel", // Replace with dynamic provider name
          paymentMethod:
              selectedPaymentMethod ?? "Unknown", // Use selected payment method
          bookingStatus: "Confirmed", // Replace with dynamic status
        ),
      ),
    );
  }

  void _applyCoupon(String code) {
    if (code == "DISCOUNT10") {
      setState(() {
        _discount = widget.totalAmount * 0.1; // 10% discount
        _isCouponApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Coupon Applied! You saved ₹${_discount.toStringAsFixed(2)}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid Coupon Code")),
      );
    }
  }

  bool _areAllFieldsFilled() {
    if (_addressController.text.isEmpty) return false;

    switch (selectedPaymentMethod) {
      case 'card':
        return _cardNumberController.text.isNotEmpty &&
            _cardNameController.text.isNotEmpty &&
            _cardExpiryController.text.isNotEmpty &&
            _cardCVVController.text.isNotEmpty;
      case 'upi':
        return _upiIdController.text.isNotEmpty;
      case 'net banking':
        return _bankNameController.text.isNotEmpty &&
            _accountNumberController.text.isNotEmpty;
      case 'wallets':
        return _walletNumberController.text.isNotEmpty;
      case 'cod':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double finalAmount = widget.totalAmount - _discount;

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment",
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.shade700,
                Colors.greenAccent.shade100
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Are you sure?"),
                  content: Text("Your changes will not be saved."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Exit"),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent.shade100,
                        Colors.greenAccent.shade400
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order Summary",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 16),
                      _buildSummaryRow("Service", widget.serviceName),
                      const SizedBox(height: 8),
                      _buildSummaryRow("Total Amount",
                          "₹${widget.totalAmount.toStringAsFixed(2)}"),
                      if (_isCouponApplied)
                        _buildSummaryRow(
                            "Discount", "-₹${_discount.toStringAsFixed(2)}",
                            isDiscount: true),
                      const SizedBox(height: 8),
                      Divider(color: Colors.greenAccent.shade700),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                          "Final Amount", "₹${finalAmount.toStringAsFixed(2)}",
                          isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Service Address Section
              Text("Service Address:",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Enter your service address",
                  labelStyle: GoogleFonts.poppins(),
                  prefixIcon: Icon(Icons.location_on,
                      color: Colors.greenAccent.shade700),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.greenAccent.shade700)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.greenAccent.shade700)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your service address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Payment Method Section
              Text("Select Payment Method:",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...['Card', 'UPI', 'Net Banking', 'Wallets', 'COD']
                  .map((method) => RadioListTile(
                        value: method.toLowerCase(),
                        groupValue: selectedPaymentMethod,
                        onChanged: (val) =>
                            setState(() => selectedPaymentMethod = val),
                        title: Row(
                          children: [
                            Icon(
                              method == 'Card'
                                  ? Icons.credit_card
                                  : method == 'UPI'
                                      ? Icons.account_balance_wallet
                                      : method == 'Net Banking'
                                          ? Icons.account_balance
                                          : method == 'Wallets'
                                              ? Icons.wallet
                                              : Icons.money,
                              color: Colors.greenAccent.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(method, style: GoogleFonts.poppins()),
                          ],
                        ),
                      )),
              const SizedBox(height: 20),

              // Dynamic Fields Based on Payment Method
              if (selectedPaymentMethod == 'card') ...[
                Text("Card Details",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: Icon(Icons.credit_card,
                        color: Colors.greenAccent.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cardNameController,
                  decoration: InputDecoration(
                    labelText: "Cardholder Name",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon:
                        Icon(Icons.person, color: Colors.greenAccent.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cardholder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cardExpiryController,
                        decoration: InputDecoration(
                          labelText: "Expiry Date (MM/YY)",
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: Icon(Icons.calendar_today,
                              color: Colors.greenAccent.shade700),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.greenAccent.shade700)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.greenAccent.shade700)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the expiry date';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cardCVVController,
                        decoration: InputDecoration(
                          labelText: "CVV",
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: Icon(Icons.lock,
                              color: Colors.greenAccent.shade700),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.greenAccent.shade700)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.greenAccent.shade700)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the CVV';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (selectedPaymentMethod == 'upi') ...[
                Text("UPI Details",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _upiIdController,
                  decoration: InputDecoration(
                    labelText: "UPI ID",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: Icon(Icons.account_balance_wallet,
                        color: Colors.greenAccent.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your UPI ID';
                    }
                    return null;
                  },
                ),
              ] else if (selectedPaymentMethod == 'net banking') ...[
                Text("Net Banking Details",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    labelText: "Bank Name",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: Icon(Icons.account_balance,
                        color: Colors.greenAccent.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the bank name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: "Account Number",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon:
                        Icon(Icons.numbers, color: Colors.greenAccent.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the account number';
                    }
                    return null;
                  },
                ),
              ] else if (selectedPaymentMethod == 'wallets') ...[
                Text("Wallet Details",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _walletNumberController,
                  decoration: InputDecoration(
                    labelText: "Wallet Number",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon:
                        Icon(Icons.wallet, color: Colors.greenAccent.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.greenAccent.shade700)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your wallet number';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

              // Coupon Code Section
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Coupon Code",
                  labelStyle: GoogleFonts.poppins(),
                  prefixIcon:
                      Icon(Icons.discount, color: Colors.greenAccent.shade700),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.check, color: Colors.greenAccent.shade700),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _applyCoupon(
                            "DISCOUNT10"); // Replace with dynamic coupon logic
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.greenAccent.shade700)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.greenAccent.shade700)),
                ),
              ),
              const SizedBox(height: 20),

              // Proceed to Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.payment, color: Colors.black),
                  onPressed: _isLoading || !_areAllFieldsFilled()
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (selectedPaymentMethod == 'cod') {
                              setState(() {
                                _isLoading = true;
                              });

                              // Save the booking details to Firestore
                              await _saveBookingToFirestore();

                              setState(() {
                                _isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "COD Confirmed! Please have the exact amount ready."),
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyBookingsScreen(
                                    serviceName: widget.serviceName,
                                    finalAmount: finalAmount,
                                    bookingDate:
                                        "2025-4-15", // Replace with dynamic date
                                    serviceProvider:
                                        "Axesh Patel", // Replace with dynamic provider name
                                    paymentMethod: selectedPaymentMethod ??
                                        "Unknown", // Use selected payment method
                                    bookingStatus:
                                        "Confirmed", // Replace with dynamic status
                                  ),
                                ),
                              );
                            } else {
                              _handlePaymentConfirmation();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  label: _isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text("Proceed to Pay",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),

              // Footer Message
              Center(
                child: Text(
                  "Secure Payment | 100% Refundable",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDiscount ? Colors.green : Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
