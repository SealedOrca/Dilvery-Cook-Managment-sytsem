import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String customerId;
  String name;
  String phoneNo;
  String foodOfChoice;
  DateTime joinDate;
  int monthlyBill;
  String lunchAddress;
  String dinnerAddress;
  List<String> mealtime;
  int lunchPriority;
  int dinnerPriority;
  String lunchDriverId;
  String lunchDriverName;
  String dinnerDriverId;
  String dinnerDriverName;

  Customer({
    required this.customerId,
    required this.name,
    required this.phoneNo,
    required this.foodOfChoice,
    required this.joinDate,
    required this.monthlyBill,
    required this.lunchAddress,
    required this.dinnerAddress,
    required this.mealtime,
    required this.lunchPriority,
    required this.dinnerPriority,
    required this.lunchDriverId,
    required this.lunchDriverName,
    required this.dinnerDriverId,
    required this.dinnerDriverName,
  });

  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Customer(
      customerId: doc.id,
      name: data['name'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      foodOfChoice: data['foodOfChoice'] ?? '',
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      monthlyBill: data['monthlyBill'] ?? 0,
      lunchAddress: data['lunchAddress'] ?? '',
      dinnerAddress: data['dinnerAddress'] ?? '',
      mealtime: List<String>.from(data['mealtime'] ?? []),
      lunchPriority: data['lunchPriority'] ?? 0,
      dinnerPriority: data['dinnerPriority'] ?? 0,
      lunchDriverId: data['assignedDrivers']['lunch']['driverId'] ?? '',
      lunchDriverName: data['assignedDrivers']['lunch']['driverName'] ?? '',
      dinnerDriverId: data['assignedDrivers']['dinner']['driverId'] ?? '',
      dinnerDriverName: data['assignedDrivers']['dinner']['driverName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'name': name,
      'phoneNo': phoneNo,
      'foodOfChoice': foodOfChoice,
      'joinDate': joinDate,
      'monthlyBill': monthlyBill,
      'lunchAddress': lunchAddress,
      'dinnerAddress': dinnerAddress,
      'mealtime': mealtime,
      'lunchPriority': lunchPriority,
      'dinnerPriority': dinnerPriority,
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
    };
  }
}
