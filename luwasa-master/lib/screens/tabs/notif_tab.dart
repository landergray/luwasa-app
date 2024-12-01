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
    return Container(
      color: const Color.fromARGB(255, 206, 235, 240),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications title
            TextWidget(
              text: 'Notifications',
              fontSize: 22,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 10),
            // Pending Notifications Section
            _buildSectionTitle('Pending'),
            const SizedBox(height: 10),
            _buildNotificationList(
              query: FirebaseFirestore.instance
                  .collection('Payments')
                  .where('uid', isEqualTo: userId)
                  .where('isPaid', isEqualTo: false)
                  .snapshots(),
              iconColor: Colors.red,
              emptyMessage: 'No pending notifications.',
            ),
            const SizedBox(height: 10),
            // Past Notifications Section
            _buildSectionTitle('Past'),
            const SizedBox(height: 10),
            _buildNotificationList(
              query: FirebaseFirestore.instance
                  .collection('Payments')
                  .where('uid', isEqualTo: userId)
                  .where('isPaid', isEqualTo: true)
                  .snapshots(),
              iconColor: Colors.green,
              emptyMessage: 'No past notifications.',
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section title widget.
  Widget _buildSectionTitle(String title) {
    return Container(
      width: 75,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primary,
      ),
      child: Center(
        child: TextWidget(
          text: title,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds a list of notifications based on the provided Firestore query.
  Widget _buildNotificationList({
    required Stream<QuerySnapshot> query,
    required Color iconColor,
    required String emptyMessage,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(child: Text('Error fetching data.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        // Get the documents
        final data = snapshot.requireData;

        if (data.docs.isEmpty) {
          return Center(
            child: TextWidget(
              text: emptyMessage,
              fontSize: 16,
              color: Colors.black54,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true, // Allows the list to take only the needed space
          physics: const NeverScrollableScrollPhysics(), // Prevents inner scrolling
          itemCount: data.docs.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showNotificationDetails(context, data.docs[index]),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: iconColor,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                          text: 'Payment: ₱${data.docs[index]['totalAmountDue']}',
                          fontSize: 18,
                        ),
                        TextWidget(
                          text: DateFormat.yMMMd()
                              .format(data.docs[index]['date'].toDate()),
                          fontSize: 12,
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.circle,
                      color: iconColor,
                      size: 10,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Shows the details of a notification in a dialog.
 void _showNotificationDetails(
    BuildContext context, QueryDocumentSnapshot doc) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Get the month from the date field
      final DateTime date = doc['date'].toDate();
      final String month = DateFormat('MMMM').format(date);

      return AlertDialog(
        contentPadding: const EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your Bill Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Updated Subtext with dynamic month
                 Center(
  child: Text(
    'We have fetched your bill details for the month of $month.',
    style: const TextStyle(fontSize: 14, color: Colors.grey),
    textAlign: TextAlign.center,  // Ensures the text itself is centered
  ),
)
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            _buildDetailRow('Meter ID', '${doc['meterid']}'),
            _buildDetailRow(
              'Bill Date',
              DateFormat.yMMMd().add_jm().format(doc['date'].toDate()),
            ),
            _buildDetailRow(
  'Due Date',
  // Calculate the due date: 22nd of the current month
  DateFormat.yMMMd().format(DateTime(DateTime.now().year, DateTime.now().month + 1, 30)),
),
_buildDetailRow('Penalty', '₱${doc['penalty']}'),
            _buildDetailRow('Total Amount', '₱${(doc['totalAmountDue'] is int ? (doc['totalAmountDue'] as int).toDouble() : doc['totalAmountDue']).toStringAsFixed(2)}'),

            const Divider(color: Colors.grey),
            _buildDetailRow('Company', 'LUWASA INC.'),
            _buildDetailRow('Name', '${doc['name']}'.toUpperCase()),
          ],
        ),
      );
    },
  );
}

  /// Builds a row for displaying details in the dialog.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
