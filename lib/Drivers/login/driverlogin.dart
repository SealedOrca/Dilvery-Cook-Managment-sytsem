import 'package:fcook/Drivers/screens/driverhome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  _DriverLoginPageState createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _checkSession();
  }

  Future<void> _loadRememberedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('remembered_email');
    if (email != null) {
      _emailController.text = email;
    }
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sessionExpiryTime = prefs.getInt('session_expiry');
    if (sessionExpiryTime != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime > sessionExpiryTime) {
        // Session expired
        await FirebaseAuth.instance.signOut();
        prefs.remove('session_expiry');
        prefs.remove('remembered_email');
        prefs.remove('driver_id');

        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverLoginPage()),
        );
      } else {
        // Session still valid, navigate to home
        String? driverId = prefs.getString('driver_id');
        if (driverId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DriverHomePage(driverId: driverId)),
          );
        }
      }
    }
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch driver details from Firestore based on user's UID
      String uid = userCredential.user!.uid;
      DocumentSnapshot<Map<String, dynamic>> driverSnapshot =
          await FirebaseFirestore.instance.collection('drivers').doc(uid).get();

      if (driverSnapshot.exists) {
        String driverId = driverSnapshot['driverId'];

        // Save the session expiry time (30 minutes from now)
        int sessionExpiryTime =
            DateTime.now().add(Duration(minutes: 30)).millisecondsSinceEpoch;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('session_expiry', sessionExpiryTime);
        await prefs.setString('remembered_email', _emailController.text.trim());
        await prefs.setString('driver_id', driverId);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login successful: ${userCredential.user?.email}')),
        );

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DriverHomePage(driverId: driverId)),
        );
      } else {
        throw Exception('Driver not found');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      print('Error fetching driver details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch driver details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Driver Login'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C2120), // Custom color
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back arrow color to white
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bk1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white.withOpacity(0.9), // Slight transparency
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Driver Login',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1C2120), // Custom color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child:
                          const Text('Login', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
