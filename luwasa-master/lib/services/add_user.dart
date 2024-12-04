import 'package:alert_system/utils/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future addUser(
  String name,
  String email,
  String number,
  String houseno,
  String meterid,
  String brgy,
  String userId,
  DateTime dob, // Add dob parameter
  [String profileUrl = ''] // Optional parameter for profile image URL
) async {
  // Capitalize the first letter of the name and make the rest lowercase
  String formattedName = name.isNotEmpty
      ? name[0].toUpperCase() + name.substring(1).toLowerCase()
      : name;

  final docUser = FirebaseFirestore.instance.collection('Users').doc(userId);

  final json = {
    'name': formattedName, // Use the formatted name
    'number': number,
    'email': email,
    'houseno': houseno,
    'meterid': meterid,
    'brgy': brgy,
    'id': docUser.id,
    'isVerified': false,
    'profile': profileUrl, // Store profile image URL, default is empty
    'isPaid': false, // Payment status for this user
    'isActive': false, // Active status of the user
    'uid': userId,
    'dob': Timestamp.fromDate(dob), // Store dob as a Firestore timestamp
    'dateCreated': FieldValue.serverTimestamp(), // Automatically set server timestamp
  };

  await docUser.set(json);
}
