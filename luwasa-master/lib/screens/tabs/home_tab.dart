import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:alert_system/widgets/touchable_opacity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF89CFF0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCurrentBillingCard(),
                const SizedBox(height: 20),
                _buildLastTransactionCard(),
                const SizedBox(height: 10),
                _buildUsageChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the Current Billing Card
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
          return const SizedBox.shrink();
        }

        final payment = data.docs.first;
        return Card(
          color: Colors.white,
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
                  _payNowButton(context, payment.id, (payment['amount'] as num).toDouble()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build the Last Transaction Card
  Widget _buildLastTransactionCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: SizedBox(
        width: double.infinity,
        height: 125,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Payments')
                .where('uid', isEqualTo: userId)
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
                return const SizedBox.shrink();
              }

              final lastTransaction = data.docs.first;
              final lastMonth = DateTime.now().month - 1;

              if (lastTransaction['month'] != lastMonth) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Last Transaction',
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  TextWidget(
                    text: '-₱${lastTransaction['amount']}.00',
                    fontSize: 48,
                    color: Colors.red,
                    fontFamily: 'Bold',
                  ),
                  TextWidget(
                    text: DateFormat.yMMMd().format(lastTransaction['date'].toDate()),
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Build the Usage Chart
  Widget _buildUsageChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Payments')
          .where('uid', isEqualTo: userId)
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorMessage();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingIndicator();
        }

        final data = snapshot.requireData;
        final chartData = data.docs.map((doc) {
          double totalAmount = doc['amount'].toDouble();
          double waterUsage = totalAmount / 30; // Divide by 30 for usage
          return ChartData(doc['month'], waterUsage);
        }).toList();

        return Card(
          color: Colors.white,
          child: SfCartesianChart(
            series: <CartesianSeries>[
              LineSeries<ChartData, int>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
            primaryXAxis: const NumericAxis(
              title: AxisTitle(text: 'Month'),
              majorGridLines: MajorGridLines(width: 0.5),
            ),
            primaryYAxis: const NumericAxis(
              title: AxisTitle(text: 'Water Usage (m³)'),
              majorGridLines: MajorGridLines(width: 0.5),
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

  // Billing Details Widget
  Widget _billingDetails(DocumentSnapshot payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Current Billing',
          fontSize: 12,
          color: Colors.black,
        ),
        TextWidget(
          text: '₱${payment['amount']}.00',
          fontSize: 48,
          color: Colors.green,
          fontFamily: 'Bold',
        ),
        TextWidget(
          text: DateFormat.yMMMd().format(payment['date'].toDate()),
          fontSize: 12,
          color: Colors.black,
        ),
      ],
    );
  }

  // Pay Now Button
  Widget _payNowButton(BuildContext context, String id, double amount) {
  return TouchableOpacity(
    onTap: () {
      // Show dialog informing the user about the redirection
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Redirecting to Paymongo'),
            content: const Text(
              'You are about to be redirected to Paymongo for payment processing. Please complete the payment there.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  initiatePayment(context, id, amount); // Proceed with payment
                },
                child: const Text('Proceed'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog without proceeding
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
    child: Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.payment, size: 35, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        TextWidget(
          text: 'Pay Gcash',
          fontSize: 12,
          color: Colors.grey,
        ),
      ],
    ),
  );
}


  // Payment Integration with PayMongo
  void initiatePayment(BuildContext context, String id, double amount) async {
  const String paymongoPublicKey = 'pk_test_s5LVDMHS9hKR4Rbx9FFpNMiN';
  const String paymongoSecretKey = 'sk_test_kc5c7FA3yPbEMXdj2TK8uQ1r';
  
  try {
    // Create payment intent (initial API call)
    var headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$paymongoSecretKey:'))}',
      'Content-Type': 'application/json'
    };
    
    var body = jsonEncode({
      "data": {
        "attributes": {
          "amount": (amount * 100).toInt(), // Convert to centavos
          "payment_method_allowed": ["card", "gcash", "paymaya"],
          "payment_method_options": {"card": {"request_three_d_secure": "any"}},
          "currency": "PHP",
        }
      }
    });

    var response = await http.post(
      Uri.parse('https://api.paymongo.com/v1/payment_intents'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonResponse = json.decode(response.body);
      var paymentIntentId = jsonResponse['data']['id'];

      // Fetch the checkout URL from Firestore based on user's payment record
      String checkoutUrl = await _getCheckoutUrlFromFirestore(id);

      if (checkoutUrl.isNotEmpty) {
        // Redirect user to payment gateway
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirecting to payment gateway for ₱$amount')),
        );

        // Call a function to attach payment method (e.g., show payment page)
        attachPaymentMethod(context, checkoutUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout URL not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create payment intent')),
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
    // Query the Payments collection to get the 'curl' field for the given paymentId
    DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
        .collection('Payments')
        .doc(paymentId)
        .get();
    
    if (paymentDoc.exists) {
      // Get the 'curl' field (assuming 'curl' is the field name in the Firestore document)
      return paymentDoc['curl'] ?? '';
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
}


  // Attach payment method (open PayMongo checkout URL)
  // Attach payment method (open PayMongo checkout URL)
Future<void> attachPaymentMethod(
    BuildContext context, String checkoutUrl) async {
  // Attempt to launch the URL
  if (await canLaunch(checkoutUrl)) {
    await launch(checkoutUrl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open payment page')),
    );
  }
}
}

// Chart Data Class
class ChartData {
  final int x;
  final double y;
  ChartData(this.x, this.y);
}
