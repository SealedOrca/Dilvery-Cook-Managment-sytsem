import 'package:flutter/material.dart';

class DriverListView extends StatelessWidget {
  final List<Map<String, dynamic>> drivers;

  const DriverListView({super.key, required this.drivers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        String driverName = drivers[index]['name'] ?? '';
        String driverPhone = drivers[index]['phoneNo'] ?? '';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              driverName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(driverPhone),
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.directions_bus, color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DriverDetailsPage(driverData: drivers[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// class DriverDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> driverData;

//   const DriverDetailsPage({super.key, required this.driverData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailItem('Name', driverData['name']),
//             _buildDetailItem('Phone Number', driverData['phoneNo']),
//             _buildDetailItem('Address', driverData['address']),
//             _buildDetailItem(
//                 'Salary',
//                 driverData['salary'] != null
//                     ? driverData['salary'].toString()
//                     : 'N/A'),
//             // Add more attributes as needed
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
// }

class DriverDetailsPage extends StatelessWidget {
  final Map<String, dynamic> driverData;

  DriverDetailsPage({required this.driverData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Details'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driverData['name'] ?? 'N/A',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Contact: ${driverData['contact'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Address: ${driverData['address'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Additional Details: ${driverData['details'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
