import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcook/AllRounders/walkthroughpage.dart';
import 'package:fcook/Drivers/login/driverlogin.dart';
import 'package:fcook/Drivers/screens/earningscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';
import 'package:fcook/Drivers/screens/driverdinner.dart';
import 'package:fcook/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart'; // Make sure to import the file where you define your colors

class DriverHomePage extends StatefulWidget {
  final String driverId; // Added driverId parameter

  const DriverHomePage({Key? key, required this.driverId}) : super(key: key);

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final DatabaseController _dbController = DatabaseController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // You may want to initialize other components here if needed
  }

  Future<void> _logout() async {
    try {
      // Clear session data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_expiry');
      await prefs.remove('remembered_email');
      await prefs.remove('driver_id');

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to DriverLoginPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DriverLoginPage()),
        (Route<dynamic> route) => false,
      );

      // Optionally show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully logged out')),
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        centerTitle: true,
        backgroundColor: chocolateBrownColor, // Chocolate Brown
        foregroundColor: Colors.white, // White text color
        elevation: 0,
        automaticallyImplyLeading: false, // Remove the back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: chocolateBrownColor, // Chocolate Brown
        selectedItemColor: sandColor, // Sand color for selected items
        unselectedItemColor: taupeColor, // Taupe color for unselected items
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCard(
                  title: 'Assigned Customers for Lunch',
                  icon: Icons.lunch_dining,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignedCustomersPage(
                          driverId: widget.driverId, // Pass driverId
                          mealTime: 'lunch',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Assigned Customers for Dinner',
                  icon: Icons.dinner_dining,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignedCustomersPage(
                          driverId: widget.driverId, // Pass driverId
                          mealTime: 'dinner',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      case 1:
        return OrderListScreen(
            driverId: widget.driverId); // Pass driverId here as well
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: sandColor, // Sand color for card background
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(32), // Increased padding for larger cards
        leading: Icon(icon,
            size: 50, color: chocolateBrownColor), // Chocolate Brown for icon
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22, // Increased font size
            color: chocolateBrownColor, // Chocolate Brown for text
          ),
        ),
        trailing: Icon(Icons.arrow_forward,
            color: chocolateBrownColor), // Chocolate Brown for trailing icon
        onTap: onTap,
      ),
    );
  }
}
