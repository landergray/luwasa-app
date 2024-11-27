import 'package:alert_system/utils/colors.dart';
import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTab extends StatelessWidget {
  const TransactionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Transaction History',
                fontSize: 22,
                fontFamily: 'Bold',
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 75,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: secondary,
                ),
                child: Center(
                  child: TextWidget(
                    text: 'Today',
                    fontSize: 14,
                    color: Colors.white,
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
                    return Column(
                      children: [
                        for (int i = 0; i < data.docs.length; i++)
                          data.docs[i]['month'] == DateTime.now().month &&
                                  data.docs[i]['day'] == DateTime.now().day
                              ? Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Card(
                                    elevation: 3,
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextWidget(
                                            text: 'Payment to LUWASA Inc.',
                                            fontSize: 18,
                                          ),
                                          TextWidget(
                                            text: DateFormat.yMMMd().format(data
                                                .docs.first['date']
                                                .toDate()),
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                      trailing: TextWidget(
                                        text: '-₱${data.docs[i]['amount']}.00',
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                      ],
                    );
                  }),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 75,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: secondary,
                ),
                child: Center(
                  child: TextWidget(
                    text: 'Past',
                    fontSize: 14,
                    color: Colors.white,
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
                    return Column(
                      children: [
                        for (int i = 0; i < data.docs.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextWidget(
                                      text: 'Payment to LUWASA Inc.',
                                      fontSize: 18,
                                    ),
                                    TextWidget(
                                      text: DateFormat.yMMMd().format(
                                          data.docs.first['date'].toDate()),
                                      fontSize: 12,
                                    ),
                                  ],
                                ),
                                trailing: TextWidget(
                                  text: '-₱${data.docs[i]['amount']}.00',
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
