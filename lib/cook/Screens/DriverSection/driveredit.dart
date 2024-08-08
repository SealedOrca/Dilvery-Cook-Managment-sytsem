import 'package:flutter/material.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';

class EditDriverPage extends StatefulWidget {
  final String driverId;
  final String currentName;
  final String currentPhoneNo;
  final String currentAddress;
  final double currentSalary;
  final String currentEmail;
  final String currentPassword;

  const EditDriverPage({
    super.key,
    required this.driverId,
    required this.currentName,
    required this.currentPhoneNo,
    required this.currentAddress,
    required this.currentSalary,
    required this.currentEmail,
    required this.currentPassword,
  });

  @override
  _EditDriverPageState createState() => _EditDriverPageState();
}

class _EditDriverPageState extends State<EditDriverPage> {
  final DatabaseController _databaseController = DatabaseController();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _salaryController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhoneNo);
    _addressController = TextEditingController(text: widget.currentAddress);
    _salaryController =
        TextEditingController(text: widget.currentSalary.toString());
    _emailController = TextEditingController(text: widget.currentEmail);
    _passwordController = TextEditingController(text: widget.currentPassword);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver'),
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
            _buildTextField(_phoneController, 'Phone Number', Icons.phone),
            _buildTextField(_emailController, 'Email', Icons.email),
            _buildTextField(_passwordController, 'Password', Icons.lock,
                obscureText: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Address'),
            _buildTextField(_addressController, 'Address', Icons.home),
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
              onPressed: () {
                _saveChanges(context);
              },
              child: const Text('Save Changes'),
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
      TextEditingController controller, String labelText, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false}) {
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

  void _saveChanges(BuildContext context) {
    try {
      double salary = double.parse(_salaryController.text);
      _databaseController.editDriver(
        driverId: widget.driverId,
        name: _nameController.text,
        phoneNo: _phoneController.text,
        address: _addressController.text,
        salary: salary,
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pop(context); // Navigate back after editing
    } catch (e) {
      // Handle parse error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid salary value')),
      );
    }
  }
}
