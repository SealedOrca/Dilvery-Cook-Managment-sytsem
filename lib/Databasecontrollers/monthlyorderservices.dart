import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> checkMissedDeliveries(String customerId) async {
  final firestore = FirebaseFirestore.instance;

  // Get the current month and year
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  // Fetch delivered orders for the current month
  final deliveredOrdersSnapshot = await firestore
      .collection('deliveredOrders')
      .where('deliveryDate', isGreaterThanOrEqualTo: startOfMonth)
      .where('deliveryDate', isLessThanOrEqualTo: endOfMonth)
      .get();

  // Fetch the customer document to get the expected delivery details
  final customerDoc =
      await firestore.collection('customers').doc(customerId).get();
  if (!customerDoc.exists) {
    print('Customer not found');
    return;
  }

  final customerData = customerDoc.data()!;
  final customerLunchTime = customerData['lunchTime'] as Timestamp;
  final customerDinnerTime = customerData['dinnerTime'] as Timestamp;

  // Convert timestamps to DateTime
  final lunchTime = customerLunchTime.toDate();
  final dinnerTime = customerDinnerTime.toDate();

  // Identify missed deliveries
  for (var orderDoc in deliveredOrdersSnapshot.docs) {
    final orderData = orderDoc.data();
    final deliveryDate = (orderData['deliveryDate'] as Timestamp).toDate();
    final mealTime = orderData['mealTime']
        as String; // Assuming mealTime is a string like 'lunch' or 'dinner'

    if (mealTime == 'lunch' && deliveryDate.hour != lunchTime.hour) {
      print('Missed Lunch Delivery: ${orderData['orderId']}');
    } else if (mealTime == 'dinner' && deliveryDate.hour != dinnerTime.hour) {
      print('Missed Dinner Delivery: ${orderData['orderId']}');
    }
  }
}
