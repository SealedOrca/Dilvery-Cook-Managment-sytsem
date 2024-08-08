import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveredOrdersPage extends StatefulWidget {
  @override
  _DeliveredOrdersPageState createState() => _DeliveredOrdersPageState();
}

class _DeliveredOrdersPageState extends State<DeliveredOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _deliveredOrdersFuture;

  @override
  void initState() {
    super.initState();
    _deliveredOrdersFuture = fetchAllDeliveredOrders();
  }

  Future<List<Map<String, dynamic>>> fetchAllDeliveredOrders() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('deliveredOrders').get();

      List<Map<String, dynamic>> orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;

        return {
          'orderId': data?.containsKey('orderId') == true
              ? data!['orderId']
              : 'Unknown',
          'customerId': data?.containsKey('customerId') == true
              ? data!['customerId']
              : 'Unknown',
          'customerName': data?.containsKey('customerName') == true
              ? data!['customerName']
              : 'Unknown',
          'customerPhone': data?.containsKey('customerPhone') == true
              ? data!['customerPhone']
              : 'Unknown',
          'driverId': data?.containsKey('driverId') == true
              ? data!['driverId']
              : 'Unknown',
          'driverName': data?.containsKey('driverName') == true
              ? data!['driverName']
              : 'Unknown',
          'driverPhone': data?.containsKey('driverPhone') == true
              ? data!['driverPhone']
              : 'Unknown',
          'deliveryTime': data?.containsKey('deliveryTime') == true
              ? data!['deliveryTime']
              : Timestamp(0, 0),
          'deliveryAddress': data?.containsKey('deliveryAddress') == true
              ? data!['deliveryAddress']
              : 'Unknown',
          'status':
              data?.containsKey('status') == true ? data!['status'] : 'Unknown',
        };
      }).toList();

      return orders;
    } catch (e) {
      print('Error fetching all delivered orders: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivered Orders'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _deliveredOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No delivered orders found.'));
          } else {
            List<Map<String, dynamic>> orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Order ID: ${order['orderId']}'),
                    subtitle: Text(
                      'Customer: ${order['customerName']}\n'
                      'Phone: ${order['customerPhone']}\n'
                      'Address: ${order['deliveryAddress']}\n'
                      'Driver: ${order['driverName']}\n'
                      'Delivery Time: ${order['deliveryTime']}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
