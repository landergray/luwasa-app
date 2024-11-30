import 'package:alert_system/utils/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future addUser(name, email, number, houseno, meterid, brgy) async {
  final docUser = FirebaseFirestore.instance.collection('Users').doc(userId);

  final json = {
    'name': name,
    'number': number,
    'email': email,
    'houseno': houseno,
    'meterid': meterid,
    'brgy': brgy,
    'id': docUser.id,
    'isVerified': false,
    'profile': '',
    'isPaid': false,
    'isActive': false,
    'uid': userId,
  };

  await docUser.set(json);
}
