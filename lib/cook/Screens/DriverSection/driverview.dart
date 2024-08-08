import 'package:fcook/cook/Screens/DriverSection/driverlist.dart';
import 'package:flutter/material.dart';
import 'package:fcook/Databasecontrollers/Controllers.dart';
import 'package:fcook/cook/Screens/DriverSection/driver.dart';
import 'package:fcook/cook/Screens/DriverSection/driveredit.dart';

class DriverView extends StatefulWidget {
  const DriverView({super.key});

  @override
  _DriverViewState createState() => _DriverViewState();
}

class _DriverViewState extends State<DriverView> {
  late Future<List<Map<String, dynamic>>> driversFuture;
  bool isCardView = true;

  @override
  void initState() {
    super.initState();
    driversFuture = DatabaseController().getAllDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
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
        future: driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> drivers = snapshot.data ?? [];
            return isCardView
                ? _buildCardView(drivers)
                : _buildListView(drivers);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardView(List<Map<String, dynamic>> drivers) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
      ),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return _buildDriverCard(driver);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> drivers) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return _buildDriverListTile(driver);
      },
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driver['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Phone: ${driver['phoneNo'] ?? 'No Phone'}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Address: ${driver['address'] ?? 'No Address'}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Salary: ${driver['salary'] ?? 'No Salary'}',
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _navigateToEditDriver(driver);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmDeleteDriver(driver['driverId']);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverListTile(Map<String, dynamic> driver) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          driver['name'] ?? 'No Name',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text('Phone: ${driver['phoneNo'] ?? 'No Phone'}'),
            const SizedBox(height: 4.0),
            Text('Address: ${driver['address'] ?? 'No Address'}'),
            const SizedBox(height: 4.0),
            Text('Salary: ${driver['salary'] ?? 'No Salary'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _navigateToEditDriver(driver);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _confirmDeleteDriver(driver['driverId']);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDetailsPage(driverData: driver),
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditDriver(Map<String, dynamic> driver) {
    if (driver['driverId'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditDriverPage(
            driverId: driver['driverId'],
            currentName: driver['name'] ?? 'No Name',
            currentPhoneNo: driver['phoneNo'] ?? 'No Phone',
            currentAddress: driver['address'] ?? 'No Address',
            currentSalary: driver['salary']?.toDouble() ?? 0.0,
            currentEmail: driver['email'] ?? 'No Email',
            currentPassword: driver['password'] ?? 'No Password',
          ),
        ),
      );
    } else {
      print('Driver ID is null for driver: $driver');
    }
  }

  void _confirmDeleteDriver(String driverId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this driver?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteDriver(driverId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDriver(String driverId) async {
    try {
      await DatabaseController().deleteDriver(driverId);
      setState(() {
        driversFuture = DatabaseController().getAllDrivers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete driver: $e')),
      );
    }
  }
}
