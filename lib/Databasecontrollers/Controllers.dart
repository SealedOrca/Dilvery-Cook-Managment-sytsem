import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcook/Databasecontrollers/customermodel.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class DatabaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Fetch all drivers from Firestore
  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('drivers').get();

      // Mapping each document to a Map<String, dynamic>
      List<Map<String, dynamic>> drivers =
          snapshot.docs.map((doc) => doc.data()).toList();

      print('Fetched ${drivers.length} drivers successfully');
      return drivers;
    } catch (e) {
      print('Error fetching drivers: $e');
      return []; // Return an empty list on error or no data
    }
  }

  Future<int> getTotalDrivers() async {
    try {
      var snapshot = await _firestore.collection('drivers').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting total drivers: $e');
      return 0;
    }
  }

  Future<int> getTotalCustomers() async {
    try {
      var snapshot = await _firestore.collection('customers').get();
      // Convert double to int if necessary
      int totalCustomers = snapshot.docs.length;
      return totalCustomers;
    } catch (e) {
      print('Error getting total customers: $e');
      return 0;
    }
  }

  Future<String> _fetchDriverIdByName(String driverName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('drivers')
          .where('name', isEqualTo: driverName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        throw Exception('Driver not found for name: $driverName');
      }
    } catch (e) {
      throw Exception('Error fetching driver ID for name: $driverName. $e');
    }
  }

  Future<void> addCustomer({
    required String name,
    required String phoneNo,
    required String lunchAddress,
    required String dinnerAddress,
    required String foodOfChoice,
    required double monthlyBill,
    required DateTime joinDate,
    required List<String> mealtime,
    required String lunchDriverName,
    required String dinnerDriverName,
  }) async {
    // Validate mealtime
    if (mealtime.isEmpty ||
        !mealtime.every((meal) => meal == 'lunch' || meal == 'dinner')) {
      throw Exception('Mealtime must include only "lunch" and/or "dinner"');
    }

    try {
      // Fetch driver IDs based on driver names
      String lunchDriverId = await _fetchDriverIdByName(lunchDriverName);
      String dinnerDriverId = await _fetchDriverIdByName(dinnerDriverName);

      // Ensure that driver IDs are not empty
      if (lunchDriverId.isEmpty || dinnerDriverId.isEmpty) {
        throw Exception('Driver IDs for lunch and dinner must not be empty');
      }

      // Fetch the current highest priority values for lunch and dinner in parallel
      List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [
        _firestore
            .collection('customers')
            .where('mealtime', arrayContainsAny: ['lunch'])
            .orderBy('lunchPriority', descending: true)
            .limit(1)
            .get(),
        _firestore
            .collection('customers')
            .where('mealtime', arrayContainsAny: ['dinner'])
            .orderBy('dinnerPriority', descending: true)
            .limit(1)
            .get(),
      ];

      // Wait for both queries to complete
      List<QuerySnapshot<Map<String, dynamic>>> results =
          await Future.wait(futures);

      // Determine new priorities for lunch and dinner
      int newLunchPriority = results[0].docs.isNotEmpty
          ? results[0].docs.first.data()['lunchPriority'] + 1
          : 1;
      int newDinnerPriority = results[1].docs.isNotEmpty
          ? results[1].docs.first.data()['dinnerPriority'] + 1
          : 1;

      // Generate a new customer document with auto-generated ID
      DocumentReference<Map<String, dynamic>> docRef =
          _firestore.collection('customers').doc();

      // Retrieve the auto-generated customer ID
      String customerId = docRef.id;

      // Prepare the data to be set in the document
      Map<String, dynamic> customerData = {
        'name': name,
        'phoneNo': phoneNo,
        'foodOfChoice': foodOfChoice,
        'monthlyBill': monthlyBill,
        'joinDate': joinDate,
        'mealtime': mealtime,
        'assignedDrivers': {
          'lunch': {
            'driverId': lunchDriverId,
            'driverName': lunchDriverName,
          },
          'dinner': {
            'driverId': dinnerDriverId,
            'driverName': dinnerDriverName,
          },
        },
        'customerId': customerId,
        'lunchPriority': newLunchPriority,
        'dinnerPriority': newDinnerPriority,
      };

      // Add lunch address if provided
      if (mealtime.contains('lunch')) {
        customerData['lunchAddress'] = lunchAddress;
      }

      // Add dinner address if provided
      if (mealtime.contains('dinner')) {
        customerData['dinnerAddress'] = dinnerAddress;
      }

      // Save customer data to Firestore
      await docRef.set(customerData);

      // Log success message
      print(
          'Customer added successfully with ID: $customerId, Lunch Priority: $newLunchPriority, Dinner Priority: $newDinnerPriority');
    } catch (e) {
      // Handle errors
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            print('Error: Permission denied. Ensure proper Firestore rules.');
            break;
          case 'unavailable':
            print('Error: Firestore service unavailable. Try again later.');
            break;
          default:
            print('Failed to add customer: $e');
        }
      } else {
        print('Failed to add customer: $e');
      }
      throw Exception('Failed to add customer: $e');
    }
  }

  // Add a new driver to Firestore
  Future<void> addDriver({
    required String name,
    required String phoneNo,
    required String address,
    required double salary,
    required String email,
    required String password,
  }) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's UID
      String uid = userCredential.user!.uid;

      // Prepare the data to be set in the document
      Map<String, dynamic> driverData = {
        'name': name,
        'phoneNo': phoneNo,
        'address': address,
        'salary': salary,
        'assignedCustomers': [], // Initialize with an empty list
        'driverId': uid, // Use the user's UID as the driver ID
        'email': email, // Store the email in the document
      };

      // Save driver data to Firestore
      await _firestore.collection('drivers').doc(uid).set(driverData);

      // Log success message
      print('Driver added successfully with ID: $uid');
    } catch (e) {
      // Handle errors
      print('Error adding driver: $e');
      throw Exception('Failed to add driver');
    }
  }

  // Delete a driver from Firestore by ID
  Future<void> deleteDriver(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).delete();
      print('Driver with ID $driverId deleted successfully');
    } catch (e) {
      print('Error deleting driver: $e');
      throw Exception('Failed to delete driver');
    }
  }

  Future<List<Customer>> getAssignedCustomers(
      String driverId, String mealTime) async {
    try {
      // Validate the mealTime parameter
      if (mealTime != 'lunch' && mealTime != 'dinner') {
        throw ArgumentError('Invalid mealTime parameter: $mealTime');
      }

      QuerySnapshot<Map<String, dynamic>> snapshot;

      try {
        // Fetch data from Firestore based on mealTime
        if (mealTime == 'lunch') {
          snapshot = await _firestore
              .collection('customers')
              .where('assignedDrivers.lunch.driverId', isEqualTo: driverId)
              .get();
        } else {
          snapshot = await _firestore
              .collection('customers')
              .where('assignedDrivers.dinner.driverId', isEqualTo: driverId)
              .get();
        }
      } catch (e) {
        print('Error fetching data from Firestore: $e');
        rethrow;
      }

      try {
        // Process and return data
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            try {
              return Customer.fromFirestore(doc);
            } catch (e) {
              print('Error converting document to Customer: $e');
              rethrow;
            }
          }).toList();
        } else {
          print(
              'No customers found for driverId: $driverId and mealTime: $mealTime');
          return [];
        }
      } catch (e) {
        print('Error processing snapshot data: $e');
        return [];
      }
    } catch (e) {
      print('Error in getAssignedCustomers method: $e');
      return [];
    }
  }

  // Edit an existing driver in Firestore by ID
  Future<void> editDriver({
    required String driverId,
    required String name,
    required String phoneNo,
    required String address,
    required double salary,
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (name.isEmpty ||
          phoneNo.isEmpty ||
          address.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        throw ArgumentError('All fields must be provided and not empty.');
      }

      // Ensure salary is a valid number
      if (salary <= 0) {
        throw ArgumentError('Salary must be greater than zero.');
      }

      // Update driver information in Firestore
      await _firestore.collection('drivers').doc(driverId).update({
        'name': name,
        'phoneNo': phoneNo,
        'address': address,
        'salary': salary,
        'email': email,
        'password': password,
      });

      // Log success message
      print('Driver with ID $driverId updated successfully');
    } catch (e) {
      // Handle specific Firebase exceptions
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            print('Error: Permission denied. Ensure proper Firestore rules.');
            break;
          case 'unavailable':
            print('Error: Firestore service unavailable. Try again later.');
            break;
          default:
            print('Failed to edit driver: $e');
        }
      } else if (e is ArgumentError) {
        print('Invalid argument: $e');
      } else {
        print('Failed to edit driver: $e');
      }
      throw Exception('Failed to edit driver: $e');
    }
  }

  // Assign a customer to a driver in Firestore by updating assignedCustomers array
  Future<void> assignCustomerToDriver(
      String driverId, String customerId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'assignedCustomers': FieldValue.arrayUnion([customerId]),
      });

      print('Customer $customerId assigned to driver $driverId');
    } catch (e) {
      print('Error assigning customer to driver: $e');
      throw Exception('Failed to assign customer to driver');
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    required Map<String, dynamic> customerData,
  }) async {
    try {
      // Update the customer data in Firestore
      await _firestore
          .collection('customers')
          .doc(customerId)
          .update(customerData);
      print('Customer with ID $customerId updated successfully');
    } catch (e) {
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            print('Error: Permission denied. Ensure proper Firestore rules.');
            break;
          case 'unavailable':
            print('Error: Firestore service unavailable. Try again later.');
            break;
          default:
            print('Failed to update customer: $e');
        }
      } else {
        print('Failed to update customer: $e');
      }
      throw Exception('Failed to update customer: $e');
    }
  }

  Future<void> deleteCustomerById(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Assign a driver to a customer in Firestore by setting assignedDriver field
  Future<void> assignDriverToCustomer(
      String customerId, String driverId, String driverName) async {
    try {
      await _firestore.collection('customers').doc(customerId).update({
        'assignedDriver': {
          'driverId': driverId,
          'driverName': driverName,
        },
      });

      print('Driver $driverId ($driverName) assigned to customer $customerId');
    } catch (e) {
      print('Error assigning driver to customer: $e');
      throw Exception('Failed to assign driver to customer');
    }
  }

  // Edit an existing customer in Firestore by ID
  Future<void> editCustomer({
    required String customerId,
    required String name,
    required String phoneNo,
    required String lunchAddress,
    required String dinnerAddress,
    required String foodOfChoice,
    required double monthlyBill,
    required List<String> mealtime,
    required String lunchDriverName,
    required String dinnerDriverName,
  }) async {
    // Validate mealtime
    if (mealtime.isEmpty ||
        !mealtime.every((meal) => meal == 'lunch' || meal == 'dinner')) {
      throw Exception('Mealtime must include only "lunch" and/or "dinner"');
    }

    try {
      // Fetch driver IDs based on driver names
      String lunchDriverId = await _fetchDriverIdByName(lunchDriverName);
      String dinnerDriverId = await _fetchDriverIdByName(dinnerDriverName);

      // Ensure that driver IDs are not empty
      if (lunchDriverId.isEmpty || dinnerDriverId.isEmpty) {
        throw Exception('Driver IDs for lunch and dinner must not be empty');
      }

      // Retrieve the current customer document
      DocumentSnapshot<Map<String, dynamic>> customerDoc =
          await _firestore.collection('customers').doc(customerId).get();

      // Check if the customer exists
      if (!customerDoc.exists) {
        throw Exception('Customer not found');
      }

      // Determine new priorities for lunch and dinner
      int newLunchPriority = mealtime.contains('lunch')
          ? await _fetchNewPriority('lunch')
          : customerDoc.data()?['lunchPriority'] ?? 0;
      int newDinnerPriority = mealtime.contains('dinner')
          ? await _fetchNewPriority('dinner')
          : customerDoc.data()?['dinnerPriority'] ?? 0;

      // Prepare the data to be updated in the document
      Map<String, dynamic> customerData = {
        'name': name,
        'phoneNo': phoneNo,
        'foodOfChoice': foodOfChoice,
        'monthlyBill': monthlyBill,
        'mealtime': mealtime,
        'assignedDrivers': {
          'lunch': {
            'driverId': lunchDriverId,
            'driverName': lunchDriverName,
          },
          'dinner': {
            'driverId': dinnerDriverId,
            'driverName': dinnerDriverName,
          },
        },
        'lunchPriority': newLunchPriority,
        'dinnerPriority': newDinnerPriority,
      };

      // Add lunch address if provided
      if (mealtime.contains('lunch')) {
        customerData['lunchAddress'] = lunchAddress;
      } else {
        customerData.remove('lunchAddress');
      }

      // Add dinner address if provided
      if (mealtime.contains('dinner')) {
        customerData['dinnerAddress'] = dinnerAddress;
      } else {
        customerData.remove('dinnerAddress');
      }

      // Update the customer data in Firestore
      await _firestore
          .collection('customers')
          .doc(customerId)
          .update(customerData);

      // Log success message
      print('Customer with ID $customerId updated successfully');
    } catch (e) {
      // Handle errors
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            print('Error: Permission denied. Ensure proper Firestore rules.');
            break;
          case 'unavailable':
            print('Error: Firestore service unavailable. Try again later.');
            break;
          default:
            print('Failed to update customer: $e');
        }
      } else {
        print('Failed to update customer: $e');
      }
      throw Exception('Failed to update customer: $e');
    }
  }

// Helper function to fetch new priority value
  Future<int> _fetchNewPriority(String mealType) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('customers')
          .where('mealtime', arrayContains: mealType)
          .orderBy('${mealType}Priority', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int currentPriority =
            querySnapshot.docs.first.data()['${mealType}Priority'];
        return currentPriority + 1;
      } else {
        return 1; // If no documents found, start with priority 1
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching new priority: $e');
      }
      return 1; // Default priority in case of error
    }
  }

// Method to fetch customers as Map<String, dynamic>
  Future<List<Map<String, dynamic>>> getAllCustomersAsMap() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('customers').get();
      List<Map<String, dynamic>> customers =
          snapshot.docs.map((doc) => doc.data()).toList();
      print('Fetched ${customers.length} customers successfully');
      return customers;
    } catch (e) {
      print('Error fetching customers: $e');
      return []; // Return an empty list on error or no data
    }
  }

// Method to fetch customers as List<Customer>
  Future<List<Customer>> getAllCustomers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('customers').get();
      List<Customer> customers =
          snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
      return customers;
    } catch (e) {
      print('Error fetching customers: $e');
      throw Exception('Failed to fetch customers');
    }
  }

  Future<Map<String, dynamic>> getCustomerById(String customerId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('customers').doc(customerId).get();

      if (snapshot.exists) {
        print('Fetched customer with ID: $customerId');
        return snapshot.data()!;
      } else {
        print('Customer not found with ID: $customerId');
        return {};
      }
    } catch (e) {
      print('Error fetching customer: $e');
      return {};
    }
  }

  Future<void> fetchCustomersForDriver(String driverId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('lunchDriverId', isEqualTo: driverId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No customers found for the driverId: $driverId');
      } else {
        for (var doc in querySnapshot.docs) {
          print('Customer: ${doc.data()}');
        }
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

// Method to fetch customers as Map<String, dynamic> with a specific ID
  Future<List<Map<String, dynamic>>> getAllCustomersAsMapWithId(
      String customerId) async {
    List<Customer> customers = await getAllCustomers();
    return customers.map((customer) => customer.toMap()).toList();
  }

  Future<void> updateCustomerPriority(
      String customerId, int newPriority, String mealType) async {
    try {
      await _firestore.collection('customers').doc(customerId).update({
        '${mealType}Priority': newPriority,
      });

      print(
          'Customer with ID $customerId $mealType priority updated to $newPriority');
    } catch (e) {
      print('Error updating customer priority: $e');
      throw Exception('Failed to update customer priority');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
      print('Customer with ID $customerId deleted successfully');
    } catch (e) {
      print('Error deleting customer: $e');
      throw Exception('Failed to delete customer');
    }
  }

  Future<void> receiveNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification received: ${message.notification?.body}');
      // Handle the received notification
    });
  }
}

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
