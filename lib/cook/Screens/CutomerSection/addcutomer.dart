import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final DatabaseController _databaseController = DatabaseController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _monthlyBillController = TextEditingController();

  String _foodOfChoice = 'Normal';
  Map<String, dynamic>? _selectedLunchDriver;
  Map<String, dynamic>? _selectedDinnerDriver;
  DateTime? _joinDate;

  bool _lunchSelected = false;
  bool _dinnerSelected = false;

  final List<String> _foodChoices = ['Normal', 'Diet'];
  List<Map<String, dynamic>> _driverOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchDriverOptions();
  }

  Future<void> _fetchDriverOptions() async {
    try {
      List<Map<String, dynamic>> drivers =
          await _databaseController.getAllDrivers();
      setState(() {
        _driverOptions = drivers;
      });
    } catch (e) {
      _showSnackbar('Failed to fetch drivers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Customers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Personal Information'),
            _buildTextField(_nameController, 'Name', Icons.person),
            const SizedBox(height: 12),
            _buildTextField(_phoneNoController, 'Phone Number', Icons.phone),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Address', Icons.home),
            const SizedBox(height: 16),
            _buildTextField(_address2Controller, 'Address 2', Icons.home),
            const SizedBox(height: 16),
            _buildSectionTitle('Food Preferences'),
            DropdownButtonFormField<String>(
              value: _foodOfChoice,
              onChanged: (value) {
                setState(() {
                  _foodOfChoice = value!;
                });
              },
              items: _foodChoices.map((choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Food of Choice',
                prefixIcon: Icon(Icons.restaurant_menu),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Assign Drivers'),
            _buildDriverDropdown(
              selectedDriver: _selectedLunchDriver,
              onDriverChanged: (value) {
                setState(() {
                  _selectedLunchDriver = value;
                });
              },
              labelText: 'Select Lunch Driver',
            ),
            const SizedBox(height: 16),
            _buildDriverDropdown(
              selectedDriver: _selectedDinnerDriver,
              onDriverChanged: (value) {
                setState(() {
                  _selectedDinnerDriver = value;
                });
              },
              labelText: 'Select Dinner Driver',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Billing Information'),
            _buildTextField(
              _monthlyBillController,
              'Monthly Bill',
              Icons.attach_money,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Join Date'),
            ElevatedButton(
              onPressed: () {
                _selectJoinDate(context);
              },
              child: Text(
                _joinDate == null
                    ? 'Select Join Date'
                    : 'Join Date: ${DateFormat('yyyy-MM-dd').format(_joinDate!)}',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Mealtime'),
            CheckboxListTile(
              title: const Text('Lunch'),
              value: _lunchSelected,
              onChanged: (bool? value) {
                setState(() {
                  _lunchSelected = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Dinner'),
              value: _dinnerSelected,
              onChanged: (bool? value) {
                setState(() {
                  _dinnerSelected = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _confirmAddCustomer();
              },
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDriverDropdown({
    required Map<String, dynamic>? selectedDriver,
    required ValueChanged<Map<String, dynamic>?> onDriverChanged,
    required String labelText,
  }) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: selectedDriver,
      items: _driverOptions.map((driver) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: driver,
          child: Text(driver['name']),
        );
      }).toList(),
      onChanged: onDriverChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _confirmAddCustomer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Add Customer'),
          content: const Text('Are you sure you want to add this customer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _addCustomer();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCustomer() async {
    String name = _nameController.text.trim();
    String phoneNo = _phoneNoController.text.trim();
    String lunchAddress = _addressController.text.trim();
    String dinnerAddress = _address2Controller.text.trim();
    String foodOfChoice = _foodOfChoice;
    String? lunchDriverName =
        _selectedLunchDriver != null ? _selectedLunchDriver!['name'] : '';
    String? dinnerDriverName =
        _selectedDinnerDriver != null ? _selectedDinnerDriver!['name'] : '';
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

    if (mealtime.isEmpty) {
      _showSnackbar('Please select at least one mealtime (Lunch or Dinner).');
      return;
    }

    if (lunchDriverName!.isEmpty || dinnerDriverName!.isEmpty) {
      _showSnackbar('Please select both lunch and dinner drivers.');
      return;
    }

    try {
      // Log driver names to verify they are correct
      print('Selected lunch driver name: $lunchDriverName');
      print('Selected dinner driver name: $dinnerDriverName');

      await _databaseController.addCustomer(
        name: name,
        phoneNo: phoneNo,
        lunchAddress: lunchAddress,
        dinnerAddress: dinnerAddress,
        foodOfChoice: foodOfChoice,
        monthlyBill: monthlyBill,
        joinDate: _joinDate!,
        mealtime: mealtime,
        lunchDriverName: lunchDriverName,
        dinnerDriverName: dinnerDriverName,
      );
      _showSnackbar('Customer added successfully!');
      _clearFields();
    } catch (e) {
      _showSnackbar('Failed to add customer: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _phoneNoController.clear();
    _addressController.clear();
    _address2Controller.clear();
    _monthlyBillController.clear();
    _foodOfChoice = 'Normal';
    _selectedLunchDriver = null;
    _selectedDinnerDriver = null;
    _joinDate = null;
    _lunchSelected = false;
    _dinnerSelected = false;
  }

  Future<void> _selectJoinDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _joinDate) {
      setState(() {
        _joinDate = picked;
      });
    }
  }
}
