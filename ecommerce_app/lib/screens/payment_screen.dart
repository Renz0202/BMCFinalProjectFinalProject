import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. An enum to represent our different payment methods
enum PaymentMethod { card, gcash, bank }

class PaymentScreen extends StatefulWidget {
  // 2. We need to know the total amount to be paid
  final double totalAmount;

  // 3. The constructor will require this amount
  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 4. State variables to track selection and loading
  PaymentMethod _selectedMethod = PaymentMethod.card; // Default to card
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });
    // Capture objects that use BuildContext before async gaps
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 3));

      await cartProvider.placeOrder();
      await cartProvider.clearCart();

      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
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
  Widget build(BuildContext context) {
    final String formattedTotal = '₱${widget.totalAmount.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Amount:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              formattedTotal,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            Text(
              'Select Payment Method:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            SegmentedButton<PaymentMethod>(
              segments: const <ButtonSegment<PaymentMethod>>[
                ButtonSegment<PaymentMethod>(
                  value: PaymentMethod.card,
                  label: Text('Credit/Debit Card'),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment<PaymentMethod>(
                  value: PaymentMethod.gcash,
                  label: Text('GCash'),
                  icon: Icon(Icons.phone_android),
                ),
                ButtonSegment<PaymentMethod>(
                  value: PaymentMethod.bank,
                  label: Text('Bank Transfer'),
                  icon: Icon(Icons.account_balance),
                ),
              ],
              selected: <PaymentMethod>{_selectedMethod},
              onSelectionChanged: (Set<PaymentMethod> selection) {
                setState(() {
                  _selectedMethod = selection.first;
                });
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.comfortable,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Pay Now ($formattedTotal)'),
            ),
          ],
        ),
      ),
    );
  }
}
