// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class CustomerListView extends StatelessWidget {
//   final List<Map<String, dynamic>> customers;

//   const CustomerListView({super.key, required this.customers});

//   @override
//   Widget build(BuildContext context) {
//     print("Customer List: $customers"); // Debugging print statement

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Customer List'),
//         centerTitle: true,
//       ),
//       body: customers.isEmpty
//           ? Center(
//               child: Text(
//                 'No customers available',
//                 style: TextStyle(color: Colors.grey[700], fontSize: 18),
//               ),
//             )
//           : ListView.separated(
//               itemCount: customers.length,
//               separatorBuilder: (context, index) => Divider(
//                 height: 1,
//                 color: Colors.grey[800],
//               ),
//               itemBuilder: (context, index) {
//                 String customerName = customers[index]['name'] ?? '';
//                 String customerFoodofchoice =
//                     customers[index]['Foodofchoice'] ?? '';

//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Card(
//                     color: Colors.white,
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 16),
//                       title: Text(
//                         customerName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       subtitle: Text(
//                         'Favorite Food: $customerFoodofchoice',
//                         style: TextStyle(color: Colors.grey[700]),
//                       ),
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.purple,
//                         child: const Icon(Icons.shopping_cart,
//                             color: Colors.white),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => CustomerDetailsPage(
//                               customerData: customers[index],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class CustomerDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> customerData;

//   const CustomerDetailsPage({Key? key, required this.customerData})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Customer Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailItem('Name', customerData['name']),
//             _buildDetailItem('Phone Number', customerData['phoneNo']),
//             _buildDetailItem('Address', customerData['address']),
//             _buildDetailItem('Food of Choice', customerData['foodOfChoice']),
//             _buildDetailItem(
//               'Monthly Bill',
//               customerData['monthlyBill'] != null
//                   ? customerData['monthlyBill'].toString()
//                   : 'N/A',
//             ),
//             _buildDetailItem('Time', _formatDateTime(customerData['time'])),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value != null ? value.toString() : 'N/A',
//             style: const TextStyle(
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(dynamic dateTime) {
//     if (dateTime is DateTime) {
//       // Format DateTime as desired
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//     } else if (dateTime is Timestamp) {
//       // Convert Timestamp to DateTime and then format
//       return '${dateTime.toDate().day}/${dateTime.toDate().month}/${dateTime.toDate().year}';
//     } else {
//       // Handle other cases, like String representation or fallback
//       return dateTime.toString();
//     }
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CustomerListView extends StatelessWidget {
//   final List<DocumentSnapshot> customers;

//   const CustomerListView({super.key, required this.customers});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue[800],
//         title: const Text('Customer List'),
//         centerTitle: true,
//       ),
//       body: customers.isEmpty
//           ? Center(
//               child: Text(
//                 'No customers available',
//                 style: TextStyle(color: Colors.grey[700], fontSize: 18),
//               ),
//             )
//           : ListView.separated(
//               itemCount: customers.length,
//               separatorBuilder: (context, index) => Divider(
//                 height: 1,
//                 color: Colors.grey[300],
//               ),
//               itemBuilder: (context, index) {
//                 final customer = customers[index];
//                 final customerName = customer['name'] ?? 'Unknown';
//                 final customerFoodOfChoice =
//                     customer['foodOfChoice'] ?? 'Not specified';

//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Card(
//                     color: Colors.white,
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 16),
//                       title: Text(
//                         customerName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       subtitle: Text(
//                         'Favorite Food: $customerFoodOfChoice',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.blue[700],
//                         child: Icon(Icons.person, color: Colors.white),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => CustomerDetailsPage(
//                               // customerSnapshot: customer,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class CustomerDetailsPage extends StatelessWidget {
//   final DocumentSnapshot customerSnapshot;

//   const CustomerDetailsPage({super.key, required this.customerSnapshot});

//   @override
//   Widget build(BuildContext context) {
//     final customerData = customerSnapshot.data() as Map<String, dynamic>;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue[800],
//         title: const Text('Customer Details'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             _buildDetailItem('Name', customerData['name']),
//             _buildDetailItem('Phone Number', customerData['phoneNo']),
//             _buildDetailItem('Lunch Address', customerData['lunchAddress']),
//             _buildDetailItem('Dinner Address', customerData['dinnerAddress']),
//             _buildDetailItem('Food of Choice', customerData['foodOfChoice']),
//             _buildDetailItem(
//               'Monthly Bill',
//               customerData['monthlyBill'] != null
//                   ? customerData['monthlyBill'].toString()
//                   : 'N/A',
//             ),
//             _buildDetailItem(
//                 'Join Date', _formatDateTime(customerData['joinDate'])),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           Text(
//             value != null ? value.toString() : 'N/A',
//             style: const TextStyle(
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(dynamic dateTime) {
//     if (dateTime is DateTime) {
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//     } else if (dateTime is Timestamp) {
//       return '${dateTime.toDate().day}/${dateTime.toDate().month}/${dateTime.toDate().year}';
//     } else {
//       return dateTime.toString();
//     }
//   }
// }
import 'package:flutter/material.dart';

class CustomerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> customerData;

  CustomerDetailsPage({required this.customerData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerData['name'] ?? 'N/A',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Contact: ${customerData['contact'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Address: ${customerData['address'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Additional Details: ${customerData['details'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
