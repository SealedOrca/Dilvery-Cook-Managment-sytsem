import 'package:fcook/Databasecontrollers/Controllers.dart';
import 'package:fcook/Databasecontrollers/customermodel.dart';
import 'package:fcook/Databasecontrollers/orderservices.dart';
import 'package:fcook/Drivers/screens/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package

class AssignedCustomersPage extends StatefulWidget {
  final String driverId;
  final String mealTime; // 'lunch' or 'dinner'

  const AssignedCustomersPage(
      {super.key, required this.driverId, required this.mealTime});

  @override
  _AssignedCustomersPageState createState() => _AssignedCustomersPageState();
}

class _AssignedCustomersPageState extends State<AssignedCustomersPage> {
  final DatabaseController _dbController = DatabaseController();
  final OrderService _orderService = OrderService();
  late Future<List<Customer>> _assignedCustomersFuture;
  final Uuid _uuid = Uuid(); // Instance of Uuid

  @override
  void initState() {
    super.initState();
    _assignedCustomersFuture =
        _dbController.getAssignedCustomers(widget.driverId, widget.mealTime);
  }

  String generateOrderId() {
    return _uuid.v4(); // Generate a unique order ID
  }

  Future<void> _markOrderAsDelivered(String customerId, String address) async {
    try {
      String orderId = generateOrderId(); // Generate a unique order ID

      // Call the OrderService method with the correct parameters
      await _orderService.markOrderAsDelivered(orderId, customerId,
          widget.driverId, address); // Use generated orderId

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as delivered')),
      );

      // Refresh the list of assigned customers
      setState(() {
        _assignedCustomersFuture = _dbController.getAssignedCustomers(
            widget.driverId, widget.mealTime);
      });
    } catch (e) {
      print('Error marking order as delivered: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking order as delivered: $e')),
      );
    }
  }

  Future<void> _openMap(String address) async {
    final String query = Uri.encodeComponent(address);

    // Google Maps URI with the address directly
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: 'maps/search/',
      queryParameters: {'q': query},
    );

    try {
      // Attempt to open the URL
      await launchUrl(mapsUri);
    } catch (e) {
      print('Error launching map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening map: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.mealTime[0].toUpperCase() + widget.mealTime.substring(1)} Customers'),
        centerTitle: true,
        backgroundColor: chocolateBrownColor, // Chocolate Brown
        foregroundColor: Colors.white, // White text color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Customer>>(
        future: _assignedCustomersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching customers: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No customers assigned'));
          } else {
            List<Customer> customers = snapshot.data!;
            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                return _buildCustomerCard(context, customers[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    String address = widget.mealTime == 'lunch'
        ? customer.lunchAddress
        : customer.dinnerAddress;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: sandColor, // Sand color for card background
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Name: ${customer.name}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: chocolateBrownColor)), // Chocolate Brown
            const SizedBox(height: 8),
            Text('Phone No: ${customer.phoneNo}',
                style:
                    TextStyle(color: chocolateBrownColor)), // Chocolate Brown
            const SizedBox(height: 8),
            _buildAddressRow(
                '${widget.mealTime[0].toUpperCase() + widget.mealTime.substring(1)} Address:',
                address),
            const SizedBox(height: 8),
            Text('Food of Choice: ${customer.foodOfChoice}',
                style:
                    TextStyle(color: chocolateBrownColor)), // Chocolate Brown
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _markOrderAsDelivered(
                customer.customerId,
                address,
              ),
              child: const Text('Mark as Delivered'),
              style: ElevatedButton.styleFrom(
                foregroundColor: sandColor,
                backgroundColor: chocolateBrownColor, // Sand color text
                elevation: 5, // Shadow effect for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Padding inside the button
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold), // Text style
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String address) {
    return Row(
      children: [
        Expanded(
          child: Text('$label $address',
              style: TextStyle(color: chocolateBrownColor)), // Chocolate Brown
        ),
        IconButton(
          icon: Icon(Icons.map,
              color: chocolateBrownColor), // Chocolate Brown for map icon
          onPressed: () => _openMap(address),
        ),
      ],
    );
  }
}
