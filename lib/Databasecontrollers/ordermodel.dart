import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final String driverId;
  final String customerId;
  final String status;
  final DateTime orderDate;
  final List<Map<String, dynamic>> items;

  Order({
    required this.orderId,
    required this.driverId,
    required this.customerId,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  // Factory method to create an Order from a Firestore document
  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Order(
      orderId: doc.id,
      driverId: data['driverId'] as String,
      customerId: data['customerId'] as String,
      status: data['status'] as String,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      items: List<Map<String, dynamic>>.from(data['items']),
    );
  }
}
