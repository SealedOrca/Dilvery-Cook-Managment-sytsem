import 'package:fcook/Databasecontrollers/Controllers.dart';
import 'package:flutter/material.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final DatabaseController _databaseController = DatabaseController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _buildingNoController = TextEditingController();
  final TextEditingController _zoneNoController = TextEditingController();
  final TextEditingController _streetNoController = TextEditingController();
  final TextEditingController _floorNoController = TextEditingController();
  final TextEditingController _apartmentNoController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Driver'),
        centerTitle: true,
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
            _buildTextField(_emailController, 'Email', Icons.email),
            _buildTextField(_passwordController, 'Password', Icons.lock,
                obscureText: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Address'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      _buildingNoController, 'Building No.', Icons.home),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                      _zoneNoController, 'Zone No.', Icons.location_city),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      _streetNoController, 'Street No.', Icons.streetview),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                      _floorNoController, 'Floor No.', Icons.layers),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                      _apartmentNoController, 'Apartment No.', Icons.apartment),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Salary'),
            _buildTextField(
              _salaryController,
              'Salary',
              Icons.attach_money,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _addDriver();
              },
              child: const Text('Add Driver'),
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
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _addDriver() async {
    String name = _nameController.text.trim();
    String phoneNo = _phoneNoController.text.trim();
    String buildingNo = _buildingNoController.text.trim();
    String zoneNo = _zoneNoController.text.trim();
    String streetNo = _streetNoController.text.trim();
    String floorNo = _floorNoController.text.trim();
    String apartmentNo = _apartmentNoController.text.trim();
    String salaryText = _salaryController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validate inputs
    if (name.isEmpty ||
        phoneNo.isEmpty ||
        buildingNo.isEmpty ||
        zoneNo.isEmpty ||
        streetNo.isEmpty ||
        floorNo.isEmpty ||
        apartmentNo.isEmpty ||
        salaryText.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showSnackbar('Please fill in all fields.');
      return;
    }

    // Parse salary
    double? salary;
    try {
      salary = double.parse(salaryText);
    } catch (e) {
      _showSnackbar('Invalid salary format.');
      return;
    }

    // Construct address
    String address = '$buildingNo, $zoneNo, $streetNo, $floorNo, $apartmentNo';

    // Call addDriver method from DatabaseController
    try {
      await _databaseController.addDriver(
        name: name,
        phoneNo: phoneNo,
        address: address,
        salary: salary,
        email: email,
        password: password,
      );
      _showSnackbar('Driver added successfully!');
      _clearFields();
    } catch (e) {
      _showSnackbar('Failed to add driver: $e');
    }
  }

  void _clearFields() {
    _nameController.clear();
    _phoneNoController.clear();
    _buildingNoController.clear();
    _zoneNoController.clear();
    _streetNoController.clear();
    _floorNoController.clear();
    _apartmentNoController.clear();
    _salaryController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
