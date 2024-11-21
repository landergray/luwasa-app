import 'package:alert_system/utils/colors.dart';
import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotifTab extends StatelessWidget {
  const NotifTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add "Notifications" text at the top
          TextWidget(
            text: 'Notifications',
            fontSize: 22,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          // StreamBuilder for pending payments
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Payments')
                  .where('uid', isEqualTo: userId)
                  .where('isPaid', isEqualTo: false)
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
                      ),
                    ),
                  );
                }

                // Get the documents
                final data = snapshot.requireData;
                return ListView.builder(
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(
                            Icons.notifications,
                            color: primary,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWidget(
                                text:
                                    'Pending Payment: ₱${data.docs[index]['amount']}',
                                fontSize: 18,
                              ),
                              TextWidget(
                                text: DateFormat.yMMMd()
                                    .format(data.docs[index]['date'].toDate()),
                                fontSize: 12,
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 10,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
