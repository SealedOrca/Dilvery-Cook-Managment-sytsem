import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderListScreen extends StatefulWidget {
  final String driverId; // Pass the driverId to filter orders
  const OrderListScreen({super.key, required this.driverId});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('deliveredOrders')
          .where('driverId', isEqualTo: widget.driverId)
          .get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivered Orders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error in FutureBuilder: ${snapshot.error}');
            return Center(
                child: Text('Error fetching orders: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          } else {
            List<Map<String, dynamic>> orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order ID: ${order['orderId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name: ${order['customerName']}'),
                      Text('Customer Phone: ${order['customerPhone']}'),
                      Text('Driver Name: ${order['driverName']}'),
                      Text('Driver Phone: ${order['driverPhone']}'),
                      Text('Delivery Address: ${order['deliveryAddress']}'),
                    ],
                  ),
                  trailing: Text('Status: ${order['status']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
