import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:alert_system/widgets/touchable_opacity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Payments')
                      .where('uid', isEqualTo: userId)
                      .where('isPaid', isEqualTo: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(child: Text('Error'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        )),
                      );
                    }

                    // Get the documents and calculate the total amount
                    final data = snapshot.requireData;
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: 'Current Billing',
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  data.docs.isEmpty
                                      ? const SizedBox()
                                      : TextWidget(
                                          text:
                                              '₱${data.docs.first['amount']}.00',
                                          fontSize: 48,
                                          color: Colors.green,
                                          fontFamily: 'Bold',
                                        ),
                                  data.docs.isEmpty
                                      ? const SizedBox()
                                      : TextWidget(
                                          text: DateFormat.yMMMd().format(
                                              data.docs.first['date'].toDate()),
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                ],
                              ),
                              data.docs.isEmpty
                                  ? const SizedBox()
                                  : TouchableOpacity(
                                      onTap: () {
                                        pay(context, data.docs.first.id);
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle),
                                            child: const Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                                Icons.payment,
                                                size: 35,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          TextWidget(
                                            text: 'Pay now',
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              const SizedBox(
                height: 20,
              ),
              Card(
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
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )),
                            );
                          }

                          // Get the documents and calculate the total amount
                          final data = snapshot.requireData;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Last Transaction',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              data.docs.first['month'] - 1 !=
                                      DateTime.now().month
                                  ? const SizedBox()
                                  : TextWidget(
                                      text: '-₱${data.docs.first['amount']}.00',
                                      fontSize: 48,
                                      color: Colors.red,
                                      fontFamily: 'Bold',
                                    ),
                              data.docs.first['month'] - 1 !=
                                      DateTime.now().month
                                  ? const SizedBox()
                                  : TextWidget(
                                      text: DateFormat.yMMMd().format(
                                          data.docs.first['date'].toDate()),
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                            ],
                          );
                        }),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('Payments')
      .where('uid', isEqualTo: userId)
      .orderBy('date') // Ensure that the payments are ordered by date
      .snapshots(),
  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      print(snapshot.error);
      return const Center(child: Text('Error'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(
            child: CircularProgressIndicator(
          color: Colors.black,
        )),
      );
    }

    // Get the documents and calculate the total amount
    final data = snapshot.requireData;

    // Prepare data for the graph (Total Bill / 30 for each month's water usage)
    List<ChartData> chartData = [];
    for (var doc in data.docs) {
      double totalAmount = doc['amount'].toDouble(); // Get the total bill
      double waterUsage = totalAmount / 30; // Divide by 30 for cubic meters

      int month = doc['month']; // Assuming 'month' is the month number (e.g., 1 for January)

      chartData.add(ChartData(month, waterUsage));
    }

    return Card(
      color: Colors.white,
      child: SfCartesianChart(
        series: <CartesianSeries>[
          // Use LineSeries instead of SplineSeries
          LineSeries<ChartData, int>(
            dataSource: chartData, // Pass the calculated chart data
            xValueMapper: (ChartData data, _) => data.x, // Month number as x-axis
            yValueMapper: (ChartData data, _) => data.y, // Water usage as y-axis
            dataLabelSettings: DataLabelSettings(isVisible: true), // Show values on chart
            markerSettings: MarkerSettings(isVisible: true), // Show markers at each data point
          )
        ],
        primaryXAxis: NumericAxis(
          title: AxisTitle(text: 'Month'),
          majorGridLines: MajorGridLines(width: 0.5), // Add gridlines on X-axis
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Water Usage (m³)'),
          majorGridLines: MajorGridLines(width: 0.5), // Add gridlines on Y-axis
        ),
      ),
    );
  }
),

            ],
          ),
        ),
      ),
    );
  }

  pay(context, String id) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                'Payment Confirmation',
                style:
                    TextStyle(fontFamily: 'QBold', fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Are you sure you want to mark this billing as paid?',
                style: TextStyle(fontFamily: 'QRegular'),
              ),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('Payments')
                        .doc(id)
                        .update({
                      'isPaid': true,
                    });
                    Navigator.pop(context);
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(
                    //       builder: (context) => const LoginScreen()),
                    // );
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double? y;
}
