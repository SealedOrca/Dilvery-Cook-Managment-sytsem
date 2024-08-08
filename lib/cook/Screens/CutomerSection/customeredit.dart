import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';

class EditCustomerPage extends StatefulWidget {
  final String customerId;

  const EditCustomerPage({super.key, required this.customerId});

  @override
  _EditCustomerPageState createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _lunchAddressController = TextEditingController();
  final TextEditingController _dinnerAddressController =
      TextEditingController();
  final TextEditingController _foodOfChoiceController = TextEditingController();
  final TextEditingController _monthlyBillController = TextEditingController();

  DateTime? _joinDate;
  bool _lunchSelected = false;
  bool _dinnerSelected = false;
  String? _selectedLunchDriverId;
  String? _selectedDinnerDriverId;

  List<Map<String, dynamic>> _driverOptions = [];
  late Future<void> _initializeData;

  @override
  void initState() {
    super.initState();
    _initializeData = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      List<Map<String, dynamic>> drivers =
          await DatabaseController().getAllDrivers();
      print('Fetched Drivers: $drivers');
      if (mounted) {
        setState(() {
          _driverOptions = drivers;
        });
      }

      if (widget.customerId.isNotEmpty) {
        Map<String, dynamic> customer =
            await DatabaseController().getCustomerById(widget.customerId);
        print('Fetched Customer Data: $customer');
        if (mounted) {
          _populateCustomerData(customer);
        }
      }
    } catch (e) {
      print('Error loading initial data: $e');
      _showSnackbar('Failed to load data. Please try again.');
    }
  }

  void _populateCustomerData(Map<String, dynamic> customer) {
    if (mounted) {
      setState(() {
        _nameController.text = customer['name'] ?? '';
        _phoneNoController.text = customer['phoneNo'] ?? '';
        _lunchAddressController.text = customer['lunchAddress'] ?? '';
        _dinnerAddressController.text = customer['dinnerAddress'] ?? '';
        _foodOfChoiceController.text = customer['foodOfChoice'] ?? '';
        _monthlyBillController.text =
            (customer['monthlyBill'] as num?)?.toString() ?? '';
        _joinDate = (customer['joinDate'] as Timestamp?)?.toDate();

        List<String> mealtime = List<String>.from(customer['mealtime'] ?? []);
        _lunchSelected = mealtime.contains('lunch');
        _dinnerSelected = mealtime.contains('dinner');

        _selectedLunchDriverId =
            customer['assignedDrivers']?['lunch']?['driverId'];
        _selectedDinnerDriverId =
            customer['assignedDrivers']?['dinner']?['driverId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
      ),
      body: FutureBuilder<void>(
        future: _initializeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                    ),
                    _buildTextField(
                      controller: _phoneNoController,
                      label: 'Phone Number',
                    ),
                    _buildTextField(
                      controller: _lunchAddressController,
                      label: 'Lunch Address',
                    ),
                    _buildTextField(
                      controller: _dinnerAddressController,
                      label: 'Dinner Address',
                    ),
                    _buildDropdown(
                      items: _driverOptions,
                      value: _selectedLunchDriverId,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedLunchDriverId = value;
                          });
                        }
                      },
                      label: 'Select Lunch Driver',
                    ),
                    _buildDropdown(
                      items: _driverOptions,
                      value: _selectedDinnerDriverId,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedDinnerDriverId = value;
                          });
                        }
                      },
                      label: 'Select Dinner Driver',
                    ),
                    _buildTextField(
                      controller: _monthlyBillController,
                      label: 'Monthly Bill',
                      keyboardType: TextInputType.number,
                    ),
                    _buildFoodOfChoiceField(),
                    _buildJoinDateField(),
                    _buildMealtimeCheckboxes(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _editCustomer,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDropdown({
    required List<Map<String, dynamic>> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: value,
        items: items.map((item) {
          print('Dropdown Item: $item');
          return DropdownMenuItem<String>(
            value: item['driverId'],
            child: Text(item['name'] ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  Widget _buildFoodOfChoiceField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _foodOfChoiceController,
        decoration: const InputDecoration(labelText: 'Food of Choice'),
      ),
    );
  }

  Widget _buildJoinDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              'Join Date: ${_joinDate != null ? DateFormat.yMMMd().format(_joinDate!) : 'Not Selected'}'),
          ElevatedButton(
            onPressed: () => _selectJoinDate(context),
            child: const Text('Select Date'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealtimeCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Lunch'),
          value: _lunchSelected,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _lunchSelected = value ?? false;
              });
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Dinner'),
          value: _dinnerSelected,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _dinnerSelected = value ?? false;
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _editCustomer() async {
    String name = _nameController.text.trim();
    String phoneNo = _phoneNoController.text.trim();
    String lunchAddress = _lunchAddressController.text.trim();
    String dinnerAddress = _dinnerAddressController.text.trim();
    String foodOfChoice = _foodOfChoiceController.text.trim();
    String monthlyBillText = _monthlyBillController.text.trim();

    if (name.isEmpty ||
        phoneNo.isEmpty ||
        lunchAddress.isEmpty ||
        dinnerAddress.isEmpty ||
        foodOfChoice.isEmpty ||
        monthlyBillText.isEmpty ||
        _joinDate == null ||
        (!_lunchSelected && !_dinnerSelected)) {
      _showSnackbar(
          'Please fill in all fields and select join date and mealtime.');
      return;
    }

    double? monthlyBill;
    try {
      monthlyBill = double.parse(monthlyBillText);
    } catch (e) {
      _showSnackbar('Invalid monthly bill format.');
      return;
    }

    List<String> mealtime = [];
    if (_lunchSelected) mealtime.add('lunch');
    if (_dinnerSelected) mealtime.add('dinner');

    String lunchDriverName = _getDriverNameById(_selectedLunchDriverId);
    String dinnerDriverName = _getDriverNameById(_selectedDinnerDriverId);

    Map<String, dynamic> updatedCustomerData = {
      'name': name,
      'phoneNo': phoneNo,
      'lunchAddress': lunchAddress,
      'dinnerAddress': dinnerAddress,
      'foodOfChoice': foodOfChoice,
      'joinDate': Timestamp.fromDate(_joinDate!),
      'monthlyBill': monthlyBill,
      'mealtime': mealtime,
      'assignedDrivers': {
        'lunch': {
          'driverId': _selectedLunchDriverId,
          'driverName': lunchDriverName,
        },
        'dinner': {
          'driverId': _selectedDinnerDriverId,
          'driverName': dinnerDriverName,
        },
      },
    };

    try {
      await DatabaseController().updateCustomer(
        customerId: widget.customerId,
        customerData: updatedCustomerData,
      );
      _showSnackbar('Customer updated successfully.');
      Navigator.pop(context);
    } catch (e) {
      print('Error updating customer: $e');
      _showSnackbar('Failed to update customer. Please try again.');
    }
  }

  Future<void> _selectJoinDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _joinDate) {
      setState(() {
        _joinDate = pickedDate;
      });
    }
  }

  String _getDriverNameById(String? driverId) {
    final driver = _driverOptions.firstWhere(
      (driver) => driver['driverId'] == driverId,
      orElse: () => {},
    );
    return driver['name'] ?? 'Unknown';
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
