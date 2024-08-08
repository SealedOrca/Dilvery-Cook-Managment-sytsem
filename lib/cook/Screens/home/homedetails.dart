import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String title;

  const DetailsPage({super.key, required this.itemData, required this.title});

  Future<void> _launchMaps(String address) async {
    if (address.isEmpty) {
      print('Address is empty, cannot launch maps.');
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        final String googleMapsUrl =
            "https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}";
        // ignore: deprecated_member_use
        if (await canLaunch(googleMapsUrl)) {
          await launch(googleMapsUrl);
        } else {
          throw 'Could not launch Google Maps';
        }
      } else {
        throw 'No locations found';
      }
    } catch (e) {
      print('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTitle(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16.0),
            Text('Phone: ${itemData['phoneNo'] ?? 'Not provided'}'),
            const SizedBox(height: 12.0),
            if (itemData['address'] != null && itemData['address'].isNotEmpty)
              GestureDetector(
                onTap: () => _launchMaps(itemData['address']),
                child: Text(
                  'Address: ${itemData['address']}',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            const SizedBox(height: 12.0),
            if (itemData['assignedDriver'] != null &&
                itemData['assignedDriver']['driverName'] != null)
              Text(
                  'Assigned Driver: ${itemData['assignedDriver']['driverName'] ?? 'Not assigned'}'),
            const SizedBox(height: 12.0),
            Text(
                'Food of Choice: ${itemData['foodOfChoice'] ?? 'Not provided'}'),
            const SizedBox(height: 12.0),
            if (itemData['joinDate'] != null)
              Text('Join Date: ${_formatTimestamp(itemData['joinDate'])}'),
            const SizedBox(height: 12.0),
            if (itemData['monthlyBill'] != null)
              Text(
                  'Monthly Bill: ${itemData['monthlyBill'] ?? 'Not provided'}'),
            const SizedBox(height: 12.0),
            if (itemData['mealtime'] != null)
              Text(
                  'Mealtime Preferences: ${itemData['mealtime'].join(", ") ?? 'Not provided'}'),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    if (itemData['driverName'] != null) {
      return 'Driver Details for ${itemData['driverName']}';
    } else if (itemData['name'] != null) {
      return 'Customer Details for ${itemData['name']}';
    }
    return 'Details';
  }

  String _formatTimestamp(Timestamp timestamp) {
    return timestamp
        .toDate()
        .toString(); // Example formatting, adjust as needed
  }
}
