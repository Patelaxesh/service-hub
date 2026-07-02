import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serviceshub/features/customer/screens/customer_payment_screen.dart';

class CustomerCartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialCartItems;

  const CustomerCartScreen({super.key, this.initialCartItems = const []});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  late List<Map<String, dynamic>> cartItems;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.initialCartItems);
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    if (_auth.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final doc = await _firestore
          .collection('carts')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        final firestoreCart =
            List<Map<String, dynamic>>.from(doc['items'] ?? []);
        setState(() => cartItems = firestoreCart);

        if (widget.initialCartItems.isNotEmpty) {
          await _mergeInitialItems();
        }
      } else if (widget.initialCartItems.isNotEmpty) {
        await _saveCartToFirestore();
      }
    } catch (e) {
      _showError('Error loading cart: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mergeInitialItems() async {
    final existingIds = cartItems.map((item) => item['id']).toSet();
    final newItems = widget.initialCartItems
        .where((item) => !existingIds.contains(item['id']))
        .toList();

    if (newItems.isNotEmpty) {
      setState(() => cartItems.addAll(newItems));
      await _saveCartToFirestore();
    }
  }

  Future<void> _saveCartToFirestore() async {
    if (_auth.currentUser == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('carts').doc(_auth.currentUser!.uid).set({
        'items': cartItems.map((item) => _sanitizeItem(item)).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _showError('Error saving cart: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Map<String, dynamic> _sanitizeItem(Map<String, dynamic> item) {
    return {
      'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'name': item['name'] ?? 'Unnamed Item',
      'description': item['description'] ?? 'No description',
      'price': item['price'] ?? 0.0,
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> removeItem(int index) async {
    if (index < 0 || index >= cartItems.length) return;

    final removedItem = cartItems[index];
    setState(() => cartItems.removeAt(index));

    try {
      await _saveCartToFirestore();
    } catch (e) {
      setState(() => cartItems.insert(index, removedItem));
      _showError('Failed to remove item: $e');
    }
  }

  double calculateTotal() {
    return cartItems.fold(
        0, (sums, item) => sums + (item['price'] as num).toDouble());
  }

  String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return format.format(amount);
  }

  String getServiceName() {
    return cartItems.isNotEmpty ? cartItems[0]['name'] : "Service Booking";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛒 Your Cart"),
        backgroundColor: Colors.greenAccent,
        //centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Help',
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _buildCartItemsList(),
                ),
                if (cartItems.isNotEmpty) _buildCheckoutCard(),
              ],
            ),
    );
  }

  Widget _buildCartItemsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: cartItems.isEmpty
          ? _buildEmptyCart()
          : ListView.separated(
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildCartItem(index),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add services to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cartItems[index];
    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(),
      onDismissed: (direction) => removeItem(index),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.greenAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['description'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatCurrency((item['price'] as num).toDouble()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => removeItem(index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Remove',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalRow(),
          const SizedBox(height: 12),
          _buildProceedButton(),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          formatCurrency(calculateTotal()),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerPaymentScreen(
                      serviceName: getServiceName(),
                      totalAmount: calculateTotal(),
                    ),
                  ),
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              )
            : const Text(
                'Proceed to Book',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cart Help'),
        content: const Text(
          'Here you can manage your cart items, remove them, and proceed to booking. '
          'Swipe left on any item to quickly remove it from your cart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }
}
