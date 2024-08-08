import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<void> markOrderAsDelivered(
  //     String orderId, String customerId, String driverId) async {
  //   try {
  //     Timestamp deliveryTime = Timestamp.now();

  //     // Fetch customer data
  //     DocumentSnapshot customerDoc =
  //         await _firestore.collection('customers').doc(customerId).get();
  //     if (!customerDoc.exists) {
  //       print('Customer not found for customerId: $customerId');
  //       return;
  //     }
  //     Map<String, dynamic> customerData =
  //         customerDoc.data() as Map<String, dynamic>;
  //     String customerName = customerData['name'];
  //     String customerPhone = customerData['phoneNo'];
  //     String deliveryAddress = customerData['lunchAddress'];

  //     // Fetch driver data
  //     DocumentSnapshot driverDoc =
  //         await _firestore.collection('drivers').doc(driverId).get();
  //     if (!driverDoc.exists) {
  //       print('Driver not found for driverId: $driverId');
  //       return;
  //     }
  //     Map<String, dynamic> driverData =
  //         driverDoc.data() as Map<String, dynamic>;
  //     String driverName = driverData['name'];
  //     String driverPhone = driverData['phoneNo'];

  //     // Save the delivered order in a separate collection with orderId as the document ID
  //     await _firestore.collection('deliveredOrders').doc(orderId).set({
  //       'orderId': orderId,
  //       'customerId': customerId,
  //       'customerName': customerName,
  //       'customerPhone': customerPhone,
  //       'driverId': driverId,
  //       'driverName': driverName,
  //       'driverPhone': driverPhone,
  //       'deliveryTime': deliveryTime,
  //       'deliveryAddress': deliveryAddress,
  //       'status': 'delivered',
  //     });

  //     // Update the customer's delivery status
  //     await _firestore.collection('customers').doc(customerId).update({
  //       'lastDeliveryTime': deliveryTime,
  //     });

  //     print('Order marked as delivered');
  //   } catch (e) {
  //     print('Error marking order as delivered: $e');
  //     rethrow;
  //   }
  // }

  Future<void> markOrderAsDelivered(String orderId, String customerId,
      String driverId, String mealTime) async {
    try {
      Timestamp deliveryTime = Timestamp.now();

      // Fetch customer data
      DocumentSnapshot customerDoc =
          await _firestore.collection('customers').doc(customerId).get();
      if (!customerDoc.exists) {
        print('Customer not found for customerId: $customerId');
        return;
      }
      Map<String, dynamic> customerData =
          customerDoc.data() as Map<String, dynamic>;
      String customerName = customerData['name'];
      String customerPhone = customerData['phoneNo'];
      String deliveryAddress = mealTime == 'lunch'
          ? customerData['lunchAddress']
          : customerData['dinnerAddress'];

      // Fetch driver data
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      if (!driverDoc.exists) {
        print('Driver not found for driverId: $driverId');
        return;
      }
      Map<String, dynamic> driverData =
          driverDoc.data() as Map<String, dynamic>;
      String driverName = driverData['name'];
      String driverPhone = driverData['phoneNo'];

      // Save the delivered order in a separate collection with orderId as the document ID
      await _firestore.collection('deliveredOrders').doc(orderId).set({
        'orderId': orderId,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'deliveryTime': deliveryTime,
        'deliveryAddress': deliveryAddress,
        'status': 'delivered',
      });

      // Update the customer's delivery status
      await _firestore.collection('customers').doc(customerId).update({
        'lastDeliveryTime': deliveryTime,
      });

      print('Order marked as delivered');
    } catch (e) {
      print('Error marking order as delivered: $e');
      rethrow; // Preserve stack trace
    }
  }

  Future<bool> canDeliver(String customerId) async {
    DocumentSnapshot customerDoc =
        await _firestore.collection('customers').doc(customerId).get();

    if (customerDoc.exists) {
      Timestamp lastDeliveryTime;
      try {
        lastDeliveryTime = customerDoc['lastDeliveryTime'];
      } catch (e) {
        lastDeliveryTime =
            Timestamp(0, 0); // default value if field does not exist
      }
      Timestamp now = Timestamp.now();

      // Check if 30 minutes have passed since the last delivery
      return now.seconds - lastDeliveryTime.seconds >= 1800;
    }

    return true;
  }

  Future<void> saveDeliveredOrder({
    required String orderId,
    required String customerId,
    required String driverId,
    required String deliveryAddress,
  }) async {
    try {
      // Fetch customer data
      DocumentSnapshot customerDoc =
          await _firestore.collection('customers').doc(customerId).get();
      if (!customerDoc.exists) {
        print('Customer not found for customerId: $customerId');
        return;
      }
      Map<String, dynamic> customerData =
          customerDoc.data() as Map<String, dynamic>;
      String customerName = customerData['name'];
      String customerPhone = customerData['phoneNo'];

      // Fetch driver data
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      if (!driverDoc.exists) {
        print('Driver not found for driverId: $driverId');
        return;
      }
      Map<String, dynamic> driverData =
          driverDoc.data() as Map<String, dynamic>;
      String driverName = driverData['name'];
      String driverPhone = driverData['phoneNo'];

      await _firestore.collection('deliveredOrders').doc(orderId).set({
        'orderId': orderId,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'deliveryTime': FieldValue.serverTimestamp(),
        'deliveryAddress': deliveryAddress,
        'status': 'delivered',
      });
      print('Delivered order saved successfully');
    } catch (e) {
      print('Error saving delivered order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersByDriver(
      String driverId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('deliveredOrders')
          .where('driverId', isEqualTo: driverId)
          .get();

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
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchOrderInfo(String orderId) async {
    try {
      DocumentSnapshot orderDoc =
          await _firestore.collection('deliveredOrders').doc(orderId).get();
      if (orderDoc.exists) {
        print('Order document found for orderId: $orderId');
        Map<String, dynamic>? orderData =
            orderDoc.data() as Map<String, dynamic>?;

        return orderData;
      } else {
        print('Order not found for orderId: $orderId');
        return null;
      }
    } catch (e) {
      print('Error fetching order info: $e');
      return null;
    }
  }
}
