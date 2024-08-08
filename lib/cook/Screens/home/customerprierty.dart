import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';

class ManageQueuePage extends StatefulWidget {
  const ManageQueuePage({super.key});

  @override
  _ManageQueuePageState createState() => _ManageQueuePageState();
}

class _ManageQueuePageState extends State<ManageQueuePage> {
  final DatabaseController _databaseController = DatabaseController();
  List<Map<String, dynamic>> _dinnerCustomers = [];
  List<Map<String, dynamic>> _lunchCustomers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      List<Map<String, dynamic>> customers =
          await _databaseController.getAllCustomersAsMap();

      setState(() {
        _dinnerCustomers = customers
            .where((customer) => customer['mealtime'].contains('dinner'))
            .toList();
        _lunchCustomers = customers
            .where((customer) => customer['mealtime'].contains('lunch'))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customers: $e');
      }
    }
  }

  Future<void> _updatePriorities(
      List<Map<String, dynamic>> customers, String mealType) async {
    try {
      for (int i = 0; i < customers.length; i++) {
        await _databaseController.updateCustomerPriority(
          customers[i]['customerId'],
          i + 1,
          mealType,
        );
      }
      // Refresh the customer list to reflect changes
      _fetchCustomers();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating priorities: $e');
      }
    }
  }

  Future<void> _updateCustomerPriority(
      String customerId, int newPriority, String mealType) async {
    try {
      await _databaseController.updateCustomerPriority(
          customerId, newPriority, mealType);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating customer priority: $e');
      }
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
    try {
      await _databaseController.deleteCustomer(customerId);
      _fetchCustomers(); // Refresh customer list
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting customer: $e');
      }
    }
  }

  void _addCustomerDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController foodOfChoiceController =
        TextEditingController();
    final TextEditingController monthlyBillController = TextEditingController();
    final TextEditingController driverIdController = TextEditingController();
    final TextEditingController driverNameController = TextEditingController();
    String mealType = 'dinner';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address')),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone No')),
                TextField(
                    controller: foodOfChoiceController,
                    decoration:
                        const InputDecoration(labelText: 'Food of Choice')),
                TextField(
                    controller: monthlyBillController,
                    decoration:
                        const InputDecoration(labelText: 'Monthly Bill'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: driverIdController,
                    decoration: const InputDecoration(labelText: 'Driver ID')),
                TextField(
                    controller: driverNameController,
                    decoration:
                        const InputDecoration(labelText: 'Driver Name')),
                DropdownButtonFormField<String>(
                  value: mealType,
                  onChanged: (newValue) {
                    setState(() {
                      mealType = newValue!;
                    });
                  },
                  items: <String>['dinner', 'lunch']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    addressController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    foodOfChoiceController.text.isEmpty ||
                    monthlyBillController.text.isEmpty ||
                    driverIdController.text.isEmpty ||
                    driverNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                try {
                  await _databaseController.addCustomer(
                    name: nameController.text,
                    phoneNo: phoneController.text,
                    lunchAddress:
                        mealType == 'lunch' ? addressController.text : '',
                    dinnerAddress:
                        mealType == 'dinner' ? addressController.text : '',
                    foodOfChoice: foodOfChoiceController.text,
                    monthlyBill: double.parse(monthlyBillController.text),
                    joinDate: DateTime.now(),
                    mealtime: [mealType],
                    lunchDriverName:
                        mealType == 'lunch' ? driverNameController.text : '',
                    dinnerDriverName:
                        mealType == 'dinner' ? driverNameController.text : '',
                  );

                  Navigator.of(context).pop();
                  _fetchCustomers(); // Refresh customer list

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Customer added successfully')),
                  );
                } catch (e) {
                  if (kDebugMode) {
                    print('Error adding customer: $e');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add customer')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex, String mealType) {
    setState(() {
      List<Map<String, dynamic>> customers =
          mealType == 'dinner' ? _dinnerCustomers : _lunchCustomers;

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final customer = customers.removeAt(oldIndex);
      customers.insert(newIndex, customer);

      // Update priorities after reordering
      for (int i = 0; i < customers.length; i++) {
        customers[i]['priority'] = i + 1;
      }

      // Update priorities in the database
      _updatePriorities(customers, mealType);
    });
  }

  Widget _buildCustomerList(
      List<Map<String, dynamic>> customers, String mealType) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        _onReorder(oldIndex, newIndex, mealType);
      },
      children: customers.map((customer) {
        return ListTile(
          key: ValueKey(customer['customerId']),
          leading: Text('${customers.indexOf(customer) + 1}'),
          title: Text(customer['name']),
          subtitle: Text(
              'Priority: ${mealType == 'dinner' ? customer['dinnerPriority'] : customer['lunchPriority']}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteCustomerDialog(customer['customerId']);
            },
          ),
        );
      }).toList(),
    );
  }

  void _deleteCustomerDialog(String customerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Delivery Queue')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Dinner'),
                Tab(text: 'Lunch'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCustomerList(_dinnerCustomers, 'dinner'),
                  _buildCustomerList(_lunchCustomers, 'lunch'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCustomerDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
