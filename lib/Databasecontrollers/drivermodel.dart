import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String driverId;
  final String name;
  final String phoneNo;
  final String email;
  final int salary;

  Driver({
    required this.driverId,
    required this.name,
    required this.phoneNo,
    required this.email,
    required this.salary,
  });

  factory Driver.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Driver(
      driverId: doc.id,
      name: data['driverName'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      email: data['email'] ?? '',
      salary: data['salary'] ?? 0,
    );
  }
}
