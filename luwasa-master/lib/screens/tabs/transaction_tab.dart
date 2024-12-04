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
      backgroundColor: const Color.fromARGB(255, 206, 235, 240),
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
              const SizedBox(height: 10),
              _buildSectionTitle('Today'),
              const SizedBox(height: 10),
              _buildTransactionList(isToday: true, emptyMessage: 'No transactions for today.'),
              const SizedBox(height: 10),
              _buildSectionTitle('History'),
              const SizedBox(height: 10),
              _buildTransactionList(isToday: false, emptyMessage: 'No past transactions.'),
            ],
          ),
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
        color: secondary,
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

  /// Fetches the transaction list based on whether it's for today or past.
  Widget _buildTransactionList({
    required bool isToday,
    required String emptyMessage,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Payments')
          .where('uid', isEqualTo: userId)
          .where('isPaid', isEqualTo: true) // Only show paid transactions
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(child: Text('Error fetching transactions.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        final data = snapshot.requireData;
        final filteredTransactions = data.docs
            .where((doc) => _isDateMatching(doc['date'], isToday))
            .toList();

        if (filteredTransactions.isEmpty) {
          return Center(
            child: TextWidget(
              text: emptyMessage,
              fontSize: 16,
              color: Colors.black54,
            ),
          );
        }

        return Column(
          children: [
            for (final doc in filteredTransactions)
              GestureDetector(
                onTap: () => _showTransactionDetails(context, doc),
                child: _buildTransactionCard(doc),
              ),
          ],
        );
      },
    );
  }

  /// Checks if the given date is today or matches the "past" condition.
  bool _isDateMatching(dynamic dateField, bool isToday) {
    if (dateField is Timestamp) {
      final DateTime date = dateField.toDate();
      final DateTime now = DateTime.now();
      return isToday
          ? date.year == now.year && date.month == now.month && date.day == now.day
          : date.isBefore(now);
    }
    return false;
  }

  /// Builds a transaction card widget.
  Widget _buildTransactionCard(QueryDocumentSnapshot doc) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 3,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Payment to LUWASA Inc.',
                fontSize: 18,
              ),
              TextWidget(
                text: DateFormat.yMMMd().format(doc['date'].toDate()),
                fontSize: 12,
              ),
            ],
          ),
          trailing: TextWidget(
            text: '-₱${doc['totalAmountDue']}.00',
            fontSize: 12,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  /// Displays transaction details in a dialog.
  void _showTransactionDetails(BuildContext context, QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Payment to LUWASA Inc.',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              _buildDetailRow('Meter', '${doc['meterid']}'),
              _buildDetailRow('Penalty', '₱${doc['penalty']}'),
              _buildDetailRow('Total Amount', '-₱${doc['totalAmountDue']}.00'),
              _buildDetailRow('Usage', '${doc['waterUsed']} m³'),
              _buildDetailRow('Invoice #', doc['invoiceNumber'].toString()),
               const Divider(color: Colors.grey),
              _buildDetailRow(
                'Date',
                DateFormat.yMMMd().add_jm().format(doc['date'].toDate()),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a row for transaction details.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
