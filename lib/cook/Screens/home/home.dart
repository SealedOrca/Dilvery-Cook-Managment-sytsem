import 'package:fcook/AllRounders/ternms&condition.dart';
import 'package:fcook/cook/Screens/home/dilverorderpagecook.dart';
import 'package:flutter/material.dart';
import 'package:fcook/AllRounders/walkthroughpage.dart';
import 'package:fcook/cook/Screens/home/customerprierty.dart';
import 'package:fcook/cook/Screens/CutomerSection/viewcustomers.dart';
import 'package:fcook/cook/Screens/DriverSection/driverview.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart' as Controllers;

void main() => runApp(FCookApp());

class FCookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/WalkthroughPage': (context) => const WalkthroughPage(),
        '/viewCustomers': (context) => const CustomerView(),
        '/viewDrivers': (context) => const DriverView(),
        '/manageQueue': (context) => const ManageQueuePage(),
        '/DeliveredOrders': (context) => DeliveredOrdersPage(),
      },
      onGenerateRoute: (settings) {
        return _errorRoute();
      },
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text(
            'Error: Route not found or arguments invalid.',
            style: TextStyle(fontSize: 24, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Controllers.DatabaseController dbController =
      Controllers.DatabaseController();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    const CustomerView(),
    const DriverView(),
    const ManageQueuePage(),
    DeliveredOrdersPage(),
  ];

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WalkthroughPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook'),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'View Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'View Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Manage Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Delivered-Orders',
          ),
        ],
        backgroundColor: Colors.blue[50],
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.black54,
        elevation: 8.0,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalCard(context),
          const SizedBox(height: 12.0), // Reduced spacing
          Expanded(
            child: ListView(
              children: [
                _buildManagementCard(
                  context,
                  color: Colors.blue[200]!,
                  icon: Icons.directions_bus,
                  title: 'Manage Drivers',
                  future: Controllers.DatabaseController().getAllDrivers(),
                  onTap: () {
                    Navigator.pushNamed(context, '/viewDrivers');
                  },
                ),
                const SizedBox(height: 12.0), // Reduced spacing
                _buildManagementCard(
                  context,
                  color: Colors.blue[200]!,
                  icon: Icons.shopping_cart,
                  title: 'Manage Customers',
                  future:
                      Controllers.DatabaseController().getAllCustomersAsMap(),
                  onTap: () {
                    Navigator.pushNamed(context, '/viewCustomers');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    return Card(
      elevation: 6, // Slightly reduced elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Reduced border radius
        side: BorderSide(
            color: Colors.blue[700]!, width: 1.5), // Reduced border width
      ),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryTile(
              context,
              color: Colors.blue[300]!,
              icon: Icons.directions_bus,
              title: 'Total Drivers',
              future: Controllers.DatabaseController().getTotalDrivers(),
              onTap: () {
                Navigator.pushNamed(context, '/viewDrivers');
              },
            ),
            _buildSummaryTile(
              context,
              color: Colors.blue[300]!,
              icon: Icons.shopping_cart,
              title: 'Total Customers',
              future: Controllers.DatabaseController().getTotalCustomers(),
              onTap: () {
                Navigator.pushNamed(context, '/viewCustomers');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required Future<int> future,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6, // Slightly reduced elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Reduced border radius
          side: BorderSide(
              color: Colors.blue[700]!, width: 1.5), // Reduced border width
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color), // Slightly reduced icon size
              const SizedBox(height: 6.0), // Reduced spacing
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14, // Slightly reduced font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6.0), // Reduced spacing
              FutureBuilder<int>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    int total = snapshot.data?.toInt() ?? 0;
                    return Text(
                      total.toString(),
                      style: TextStyle(
                        fontSize: 20, // Slightly reduced font size
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required Future<List<Map<String, dynamic>>> future,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6, // Slightly reduced elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Reduced border radius
        side: BorderSide(
            color: Colors.blue[700]!, width: 1.5), // Reduced border width
      ),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(icon,
                  size: 30, color: color), // Slightly reduced icon size
              title: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14, // Slightly reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: onTap,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>> items = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.map((item) {
                      final name = item['name'] ?? 'N/A';
                      final address = item['address'] ?? 'N/A';
                      final phone =
                          item['phoneNo'] ?? 'N/A'; // Added phone number
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: 6.0), // Reduced bottom margin
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blue[300]!,
                              width: 1.0), // Reduced border width
                          borderRadius: BorderRadius.circular(
                              6.0), // Reduced border radius
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 14), // Reduced font size
                          ),
                          subtitle: Text(
                            '$address\nPhone: $phone', // Display phone number
                            style: const TextStyle(
                                fontSize: 12), // Reduced font size
                          ),
                          contentPadding: const EdgeInsets.all(
                              8.0), // Reduced content padding
                          onTap: () {
                            // Removed navigation to detail pages
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
