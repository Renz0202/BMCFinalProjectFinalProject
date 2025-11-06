import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final Timestamp? timestamp = orderData['createdAt'] as Timestamp?;
    final String formattedDate;

    if (timestamp != null) {
      formattedDate = DateFormat(
        'MM/dd/yyyy - hh:mm a',
      ).format(timestamp.toDate());
    } else {
      formattedDate = 'Date not available';
    }

    final double totalPrice =
        (orderData['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final int itemCount = (orderData['itemCount'] as num?)?.toInt() ?? 0;
    final String status = (orderData['status'] as String?) ?? 'Unknown';

    Color statusColor(BuildContext context) {
      switch (status) {
        case 'Pending':
          return Colors.orange;
        case 'Processing':
          return Colors.blue;
        case 'Shipped':
          return Colors.deepPurple;
        case 'Delivered':
          return Colors.green;
        case 'Cancelled':
          return Colors.red;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.receipt_long, color: Colors.white),
          ),
          title: Text(
            'Total: ₱${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Items: $itemCount'),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(status),
                      backgroundColor: statusColor(context),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
