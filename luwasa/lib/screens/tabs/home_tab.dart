import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:alert_system/widgets/touchable_opacity.dart';
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
                const SizedBox(height: 20),
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

    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final name = userDoc.data()?['name'] ?? '';
      final meterid = userDoc.data()?['meterid'] ?? '';
      return {'name': name, 'meterid': meterid};
    }
    return {'name': '', 'meterid': ''};
  }

  Widget _buildWelcomeText() {
    return FutureBuilder<Map<String, String>>(
      future: _getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Error fetching user details');
        }

        final details = snapshot.data ?? {'name': '', 'meterid': ''};
        final name = details['name'] ?? '';
        final meterid = details['meterid'] ?? '';

        return Container(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 5),
              Text(
                'Name: $name',
                style: const TextStyle(fontSize: 18, fontFamily: 'Medium', color: Color.fromARGB(255, 24, 23, 23)),
              ),
              Text(
                'Meter ID: $meterid',
                style: const TextStyle(fontSize: 18, fontFamily: 'Medium', color: Color.fromARGB(255, 24, 23, 23)),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 2),
            ],
          ),
        );
      },
    );
  }

Widget _buildCurrentBillingCard() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const Center(child: Text('No user logged in'));
  }

  final userId = user.uid; // User ID to compare with the 'uid'

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Payments')
        .where('uid', isEqualTo: userId)  // Match the logged-in user ID
        .where('isPaid', isEqualTo: false) // Check for unpaid bills
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
                  _payNowButton(context, '', 0.0),
                ],
              ),
            ),
          ),
        );
      }

      // Assuming the first payment document is the correct one
      final payment = data.docs.first;
      final paymentUid = payment['uid']; // Get the uid from payment

      // Check if the uid matches the logged-in user's uid
      if (paymentUid != userId) {
        return const Center(child: Text('No matching payment for this user'));
      }

      // Safely handle totalAmountDue value
      final totalAmountDue = payment['totalAmountDue'];
      double totalAmount = 0.0;
      if (totalAmountDue is int) {
        totalAmount = totalAmountDue.toDouble(); // Convert int to double
      } else if (totalAmountDue is double) {
        totalAmount = totalAmountDue; // It's already a double
      }

      final paymentId = payment.id;

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
                _billingDetails(payment, totalAmount),
                _payNowButton(context, paymentId, totalAmount),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget _errorMessage() {
    return const Center(child: Text('Error loading data'));
  }

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 50),
      child: Center(child: CircularProgressIndicator(color: Colors.black)),
    );
  }

  Widget _billingDetailsWithNoData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text: 'Current Billing', fontSize: 12, color: const Color.fromARGB(255, 5, 5, 5)),
        TextWidget(text: '₱0.00', fontSize: 48, color: const Color.fromARGB(255, 39, 39, 39), fontFamily: 'Medium'),
        TextWidget(text: 'No pending payment', fontSize: 12, color: const Color.fromARGB(255, 12, 12, 12)),
      ],
    );
  }

  Widget _billingDetails(DocumentSnapshot payment, double totalAmountDue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text: 'Current Billing', fontSize: 12, color: const Color.fromARGB(255, 5, 5, 5)),
        TextWidget(
          text: '₱${totalAmountDue.toStringAsFixed(2)}',
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
              child: Image.asset('assets/images/gcashlogo.png', width: 75, height: 75),
            ),
          ),
          const SizedBox(height: 4),
          TextWidget(text: 'Pay Now', fontSize: 10, color: Color.fromARGB(255, 12, 12, 12)),
        ],
      ),
    );
  }

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
      final paymentDoc = await FirebaseFirestore.instance.collection('Payments').doc(paymentId).get();
      if (paymentDoc.exists) {
        final checkoutUrl = paymentDoc.data()?['checkoutUrl'];
        return checkoutUrl ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  void attachPaymentMethod(BuildContext context, String checkoutUrl) {
    if (checkoutUrl.isNotEmpty) {
      // Open the checkout URL for payment (mock example)
      print('Redirecting to: $checkoutUrl');
      // TODO: Implement actual redirect logic for payment gateway (e.g., WebView or Browser)
    }
  }

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

}
