import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/widgets/admin_gate.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus,
    String userId,
  ) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });

      // Create a notification for the user
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Order Status Updated',
        'body': 'Your order ($orderId) has been updated to "$newStatus".',
        'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order status updated!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  void _showStatusDialog(String orderId, String currentStatus, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        const statuses = [
          'Pending',
          'Confirmed',
          'Processing',
          'Shipped',
          'Delivered',
          'Cancelled',
        ];
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return ListTile(
                title: Text(status),
                trailing: currentStatus == status
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _updateOrderStatus(orderId, status, userId);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage Orders')),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No orders found.'));
            }

            final orders = snapshot.data!.docs;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final data = order.data() as Map<String, dynamic>;

                final Timestamp? ts = data['createdAt'] as Timestamp?;
                final String formattedDate = ts != null
                    ? DateFormat('MM/dd/yyyy hh:mm a').format(ts.toDate())
                    : 'N/A';

                final String status = (data['status'] as String?) ?? 'Pending';
                final double total =
                    (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
                final String userId = (data['userId'] as String?) ?? 'Unknown';

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'Order ID: ${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    subtitle: Text(
                      'User: $userId\nTotal: ₱${total.toStringAsFixed(2)} | Date: $formattedDate',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: status == 'Pending'
                              ? Colors.orange
                              : status == 'Confirmed'
                              ? Colors.cyan
                              : status == 'Processing'
                              ? Colors.blue
                              : status == 'Shipped'
                              ? Colors.deepPurple
                              : status == 'Delivered'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        if (status == 'Pending')
                          TextButton.icon(
                            onPressed: () => _updateOrderStatus(
                              order.id,
                              'Confirmed',
                              userId,
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Confirm'),
                          ),
                        PopupMenuButton<String>(
                          tooltip: 'Change status',
                          onSelected: (value) =>
                              _updateOrderStatus(order.id, value, userId),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            PopupMenuItem(
                              value: 'Confirmed',
                              child: Text('Confirmed'),
                            ),
                            PopupMenuItem(
                              value: 'Processing',
                              child: Text('Processing'),
                            ),
                            PopupMenuItem(
                              value: 'Shipped',
                              child: Text('Shipped'),
                            ),
                            PopupMenuItem(
                              value: 'Delivered',
                              child: Text('Delivered'),
                            ),
                            PopupMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancelled'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    onTap: () => _showStatusDialog(order.id, status, userId),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
