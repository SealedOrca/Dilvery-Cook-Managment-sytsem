import 'package:fcook/cook/Screens/CutomerSection/customeredit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  _CustomerViewState createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  late Future<List<Map<String, dynamic>>> customersFuture;
  List<Map<String, dynamic>> customers = [];
  bool isCardView = true;

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      customersFuture = DatabaseController().getAllCustomersAsMap();
      customers = await customersFuture;
      setState(() {}); // Update state to trigger build with initial data
    } catch (e) {
      print('Error loading customers: $e');
      // Optionally, show an error message to the user
    }
  }

  Future<void> showCustomerDetails(String customerId) async {
    try {
      Map<String, dynamic> customer =
          await DatabaseController().getCustomerById(customerId);
      if (customer.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Customer Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCustomerDetail('Name:', customer['name'] ?? 'No Name'),
                  _buildCustomerDetail(
                      'Phone:', customer['phoneNo'] ?? 'No Phone'),
                  _buildCustomerDetail('Lunch Address:',
                      customer['lunchAddress'] ?? 'No Address'),
                  _buildCustomerDetail('Dinner Address:',
                      customer['dinnerAddress'] ?? 'No Address'),
                  _buildCustomerDetail(
                      'Assigned Lunch Driver:',
                      customer['assignedDrivers']?['lunch']?['driverName'] ??
                          'No Assigned Driver'),
                  _buildCustomerDetail(
                      'Assigned Dinner Driver:',
                      customer['assignedDrivers']?['dinner']?['driverName'] ??
                          'No Assigned Driver'),
                  _buildCustomerDetail('Food of Choice:',
                      customer['foodOfChoice'] ?? 'No Food of Choice'),
                  _buildCustomerDetail(
                      'Join Date:',
                      customer['joinDate'] != null
                          ? DateFormat.yMMMd().format(
                              (customer['joinDate'] as Timestamp).toDate())
                          : 'No Join Date'),
                  _buildCustomerDetail('Monthly Bill:',
                      '\$${(customer['monthlyBill'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildCustomerDetail(
                      'Meal Times:',
                      (customer['mealtime'] as List<dynamic>?)?.join(", ") ??
                          'None'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        print('Customer not found with ID: $customerId');
      }
    } catch (e) {
      print('Error fetching customer details: $e');
      // Show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to fetch customer details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToEditCustomer(Map<String, dynamic> customer) {
    final String customerId = customer['customerId'] ?? '';

    if (customerId.isEmpty) {
      // Handle the case where customerId is empty or log an error
      print('Customer ID is missing. Customer data: $customer');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerPage(
          customerId: customerId,
        ),
      ),
    ).then((result) {
      if (result != null) {
        // Optionally, handle the result if needed
      }
      loadCustomers(); // Ensure this method is defined and correctly refreshes the data
    }).catchError((error) {
      // Handle navigation error
      print('Navigation error: $error');
    });
  }

  Future<void> _deleteCustomer(String customerId) async {
    try {
      await DatabaseController().deleteCustomerById(customerId);
      setState(() {
        customers.removeWhere((customer) => customer['id'] == customerId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully')),
      );
    } catch (e) {
      print('Error deleting customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting customer')),
      );
    }
  }

  Widget _buildCustomerItem(Map<String, dynamic> customer) {
    String name = customer['name'] ?? 'No Name';
    String phoneNo = customer['phoneNo'] ?? 'No Phone';
    String lunchAddress = customer['lunchAddress'] ?? 'No Address';
    String dinnerAddress = customer['dinnerAddress'] ?? 'No Address';
    String assignedLunchDriver = customer['assignedDrivers']?['lunch']
            ?['driverName'] ??
        'No Assigned Driver';
    String assignedDinnerDriver = customer['assignedDrivers']?['dinner']
            ?['driverName'] ??
        'No Assigned Driver';
    String foodOfChoice = customer['foodOfChoice'] ?? 'No Food of Choice';
    DateTime joinDate = (customer['joinDate'] as Timestamp).toDate();
    double monthlyBill = (customer['monthlyBill'] as num?)?.toDouble() ?? 0.0;
    List<String> mealTimes = (customer['mealtime'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: InkWell(
        onLongPress: () => showCustomerDetails(customer['id']),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerDetail('Name:', name,
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  _buildCustomerDetail('Phone:', phoneNo),
                  const SizedBox(height: 4),
                  _buildCustomerDetail('Lunch Address:', lunchAddress),
                  const SizedBox(height: 4),
                  _buildCustomerDetail('Dinner Address:', dinnerAddress),
                  const SizedBox(height: 4),
                  _buildCustomerDetail(
                      'Assigned Lunch Driver:', assignedLunchDriver),
                  const SizedBox(height: 4),
                  _buildCustomerDetail(
                      'Assigned Dinner Driver:', assignedDinnerDriver),
                  const SizedBox(height: 4),
                  _buildCustomerDetail('Food of Choice:', foodOfChoice),
                  const SizedBox(height: 4),
                  _buildCustomerDetail(
                      'Join Date:', DateFormat.yMMMd().format(joinDate)),
                  const SizedBox(height: 4),
                  _buildCustomerDetail(
                      'Monthly Bill:', '\$${monthlyBill.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  _buildCustomerDetail('Meal Times:', mealTimes.join(", ")),
                ],
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToEditCustomer(customer),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(customer['id']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String customerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCustomer(customerId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetail(String label, String value,
      {FontWeight fontWeight = FontWeight.normal}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          fontWeight: fontWeight,
        ),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isCardView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isCardView = !isCardView;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No customers found.'));
          } else {
            return isCardView
                ? ListView(
                    children: snapshot.data!.map(_buildCustomerItem).toList(),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildCustomerItem(snapshot.data![index]);
                    },
                  );
          }
        },
      ),
    );
  }
}
