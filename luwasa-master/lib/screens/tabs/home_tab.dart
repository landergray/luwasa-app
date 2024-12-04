import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:alert_system/widgets/touchable_opacity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 206, 235, 240),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 5),
                _buildWelcomeText(),
                const SizedBox(height: 20), // Space after the text
                _buildCurrentBillingCard(),
                const SizedBox(height: 10),
                _buildWaterUsed(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<Map<String, String>> _getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'name': '', 'meterid': ''}; 
    }

    // Fetch user details from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final name = userDoc.data()?['name'] ?? ''; 
      final meterid = userDoc.data()?['meterid'] ?? ''; 
      return {'name': name, 'meterid': meterid}; 
    }
    return {'name': '', 'meterid': ''}; 
  }

  // Welcome Text Widget
 Widget _buildWelcomeText() {
  return FutureBuilder<Map<String, String>>(
    future: _getUserDetails(), // Fetch user details from Firestore
    builder: (context, snapshot) {
      // Show a loading indicator while fetching data
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Handle error fetching data
      if (snapshot.hasError) {
        return const Text('Error fetching user details');
      }

      // Get the user details from the snapshot
      final details = snapshot.data ?? {'name': '', 'meterid': ''}; // Default values if data not found
      final name = details['name'] ?? '';
      final meterid = details['meterid'] ?? '';

      return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Start from the left
          children: [
            // Center the "Welcome to LUWASA Billing" text
            const Center(
              child: Text(
                'Welcome to LUWASA Billing',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Medium',
                  color: Color.fromARGB(255, 24, 23, 23),
                ),
              ),
            ),
            const SizedBox(height: 5), // Space between the texts
            Text(
              'Name: $name', // Display the fetched user name
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Medium',
                color: Color.fromARGB(255, 24, 23, 23),
              ),
            ),
            Text(
              'Meter ID: $meterid', // Display the fetched meter ID
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Medium',
                color: Color.fromARGB(255, 24, 23, 23),
              ),
            ),
            const SizedBox(height: 10), // Space before the divider
            const Divider( // Add a divider below the name and meter ID
              color: Colors.grey, // Divider color
              thickness: 2, // Divider thickness
              indent: 0, // Space from the left
              endIndent: 0, // Space from the right
            ),
          ],
        ),
      );
    },
  );
}




  // Current Billing Card
  Widget _buildCurrentBillingCard() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Payments')
        .where('uid', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _errorMessage();
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _loadingIndicator();
      }

      final data = snapshot.requireData;
      if (data.docs.isEmpty) {
        // Show P0.00 if no pending payments
        return Card(
          color: const Color.fromARGB(255, 247, 244, 244),
          elevation: 3,
          child: SizedBox(
            width: double.infinity,
            height: 125,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _billingDetailsWithNoData(),
                  _payNowButton(context, '', 0.0), // No payment button when no data
                ],
              ),
            ),
          ),
        );
      }

      final payment = data.docs.first;
      return Card(
        color: const Color.fromARGB(255, 247, 244, 244),
        elevation: 3,
        child: SizedBox(
          width: double.infinity,
          height: 125,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _billingDetails(payment),
                _payNowButton(context, payment.id, (payment['totalAmountDue'] as num).toDouble()),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  // Helper for error message
  Widget _errorMessage() {
    return const Center(child: Text('Error loading data'));
  }

  // Helper for loading indicator
  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 50),
      child: Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }
 
Widget _billingDetailsWithNoData() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      TextWidget(
        text: 'Current Billing',
        fontSize: 12,
        color: const Color.fromARGB(255, 5, 5, 5),
      ),
      TextWidget(
        text: '₱0.00',
        fontSize: 48,
        color: const Color.fromARGB(255, 39, 39, 39),
        fontFamily: 'Medium',
      ),
      TextWidget(
        text: 'No pending payment',
        fontSize: 12,
        color: const Color.fromARGB(255, 12, 12, 12),
      ),
    ],
  );
}
  // Billing Details Widget
  Widget _billingDetails(DocumentSnapshot payment) {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Current Billing',
          fontSize: 12,
          color: const Color.fromARGB(255, 5, 5, 5),
        ),
        TextWidget(
          text: '₱${payment['totalAmountDue']}.00',
          fontSize: 48,
          color: const Color.fromARGB(255, 39, 39, 39),
          fontFamily: 'Medium',
        ),
        TextWidget(
          text: DateFormat.yMMMd().format(payment['date'].toDate()),
          fontSize: 12,
          color: const Color.fromARGB(255, 12, 12, 12),
        ),
      ],
    );
  }

  // Pay Now Button
  Widget _payNowButton(BuildContext context, String id, double amount) {
    return TouchableOpacity(
      onTap: () {
        initiatePayment(context, id, amount);
      },
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(0, 255, 255, 255),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(
                'assets/images/gcashlogo.png', // Adjust to your logo's path
                width: 75,
                height: 75,
              ),
            ),
          ),
          TextWidget(
            text: 'Pay Gcash',
            fontSize: 15,
            color: const Color.fromARGB(255, 24, 23, 23),
          ),
        ],
      ),
    );
  }

  // Merged Water Used List and Last Transaction Card
// Merged Water Used List and Last Transaction Card
Widget _buildWaterUsed() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const Center(child: Text('No user logged in'));
  }
  
  final userId = user.uid; // Get the current user's UID

  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('Payments')
        .where('uid', isEqualTo: userId) // Filter by user ID
        .orderBy('date', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _errorMessage();
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _loadingIndicator();
      }

      final data = snapshot.requireData;
      if (data.docs.isEmpty) {
        return const Center(child: Text('No data found.'));
      }

      // Fetch the most recent reading
      final latestReading = data.docs.first;
      final currentReading = latestReading['currentReading'];
      final previousReading = latestReading['previousReading'];
      final date = latestReading['date']; // Assuming 'date' is a Timestamp field
      final isPaid = latestReading['isPaid'];

      // Safely cast the values to double
      final double currentReadingValue = (currentReading is int)
          ? currentReading.toDouble()
          : currentReading as double? ?? 0.0;
      final double previousReadingValue = (previousReading is int)
          ? previousReading.toDouble()
          : previousReading as double? ?? 0.0;

      final waterUsed = currentReadingValue - previousReadingValue;

      // Convert 'date' to DateTime and extract month & year
      DateTime dateTime = date.toDate();
      String monthYear = DateFormat('MMMM yyyy').format(dateTime);

      return Card(
        elevation: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: GestureDetector(
                onTap: () {
                  // Display water usage details when tapped
                  _showWaterUsageDialog(context, monthYear, currentReadingValue, previousReadingValue, waterUsed);
                },
                child: TextWidget(
                  text: 'Reading Month: $monthYear',
                  fontSize: 15,
                  fontFamily: 'Medium',
                ),
              ),
              subtitle: GestureDetector(
                onTap: () {
                  // Display water usage details when tapped
                  _showWaterUsageDialog(context, monthYear, currentReadingValue, previousReadingValue, waterUsed);
                },
                child: TextWidget(
                  text: 'Total Reading: ${waterUsed.toStringAsFixed(2)}m³\n'
                      'Current: ${currentReadingValue.toStringAsFixed(2)}m³, '
                      'Previous: ${previousReadingValue.toStringAsFixed(2)}m³',
                  fontSize: 18,
                  color: const Color.fromARGB(255, 36, 36, 36),
                ),
              ),
              leading: const Icon(
                Icons.water_damage,
                color: Colors.blue,
                size: 50,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),

            // Last Transaction Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Display transaction details when tapped
                          _showTransactionDialog(context, latestReading, isPaid);
                        },
                        child: TextWidget(
                          text: 'Last Transaction:\n',
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: const Color.fromARGB(255, 70, 70, 70),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Display transaction details when tapped
                            _showTransactionDialog(context, latestReading, isPaid);
                          },
                          child: TextWidget(
                            text: isPaid
                                ? 'Payment to LUWASA Inc.\nAmount: ₱${(latestReading['totalAmountDue'] as num).toDouble().toStringAsFixed(2)}'
                                : 'No transactions found.',
                            fontSize: 16,
                            fontFamily: 'Medium',
                            color: const Color.fromARGB(255, 70, 70, 70),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Notification Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        TextWidget(
                          text: 'Notification: ',
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: const Color.fromARGB(255, 70, 70, 70),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Show the text message when clicked (dialog or bottom sheet)
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Notification'),
                                    content: Text(
                                      isPaid
                                          ? 'No notifications found.'
                                          : 'You have a pending ₱${(latestReading['totalAmountDue'] as num).toDouble().toStringAsFixed(2)} for this month. Please settle this to avoid penalty fees.',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: TextWidget(
                              text: isPaid
                                  ? 'No notifications found.'
                                  : 'You have a pending ₱${(latestReading['totalAmountDue'] as num).toDouble().toStringAsFixed(2)} for this month. Please settle this to avoid penalty fees.',
                              fontSize: 16,
                              fontFamily: 'Medium',
                              color: const Color.fromARGB(255, 70, 70, 70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Show dialog for water usage details
void _showWaterUsageDialog(BuildContext context, String monthYear, double currentReading, double previousReading, double waterUsed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Water Usage Details'),
        content: Text(
          'Reading Month: $monthYear\n'
          'Current Reading: ${currentReading.toStringAsFixed(2)} m³\n'
          'Previous Reading: ${previousReading.toStringAsFixed(2)} m³\n'
          'Water Used: ${waterUsed.toStringAsFixed(2)} m³',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

// Show dialog for transaction details
void _showTransactionDialog(BuildContext context, DocumentSnapshot latestReading, bool isPaid) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Transaction Details'),
        content: Text(
          isPaid
              ? 'Payment to LUWASA Inc.\nAmount: ₱${(latestReading['totalAmountDue'] as num).toDouble().toStringAsFixed(2)}'
              : 'No transactions found.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}



  // Payment Integration with PayMongo
  void initiatePayment(BuildContext context, String id, double amount) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initiating payment...')),
      );

      String checkoutUrl = await _getCheckoutUrlFromFirestore(id);

      if (checkoutUrl.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirecting to payment gateway for ₱$amount')),
        );
        attachPaymentMethod(context, checkoutUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout URL not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String> _getCheckoutUrlFromFirestore(String paymentId) async {
    try {
      DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
          .collection('Payments')
          .doc(paymentId)
          .get();

      if (paymentDoc.exists) {
        return paymentDoc['curl'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      debugPrint('Error fetching checkout URL: $e');
      return '';
    }
  }

  Future<void> attachPaymentMethod(BuildContext context, String checkoutUrl) async {
    if (Uri.tryParse(checkoutUrl)?.isAbsolute ?? false) {
      if (await canLaunch(checkoutUrl)) {
        await launch(checkoutUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open payment page')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid payment URL')),
      );
    }
  }
}
