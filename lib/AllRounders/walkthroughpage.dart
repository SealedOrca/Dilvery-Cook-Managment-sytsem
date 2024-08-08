import 'package:fcook/Drivers/login/driverlogin.dart';
import 'package:fcook/cook/Screens/Login/login.dart';
import 'package:flutter/material.dart';

class WalkthroughPage extends StatelessWidget {
  const WalkthroughPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bk1.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Our Service',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18.0),
                backgroundColor: Colors.black, // Black button background
                foregroundColor: Colors.white, // White text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverLoginPage(),
                  ),
                );
              },
              child: const Text('Driver'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18.0),
                backgroundColor: Colors.black, // Black button background
                foregroundColor: Colors.white, // White text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CookLoginPage(),
                  ),
                );
              },
              child: const Text('Cook'),
            ),
          ],
        ),
      ),
    );
  }
}
