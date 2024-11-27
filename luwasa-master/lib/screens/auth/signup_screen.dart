import 'package:alert_system/screens/auth/login_screen.dart';
import 'package:alert_system/services/add_user.dart';
import 'package:alert_system/utils/colors.dart';
import 'package:alert_system/widgets/button_widget.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:alert_system/widgets/textfield_widget.dart';
import 'package:alert_system/widgets/toast_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final number = TextEditingController();
  final houseno = TextEditingController();
  final brgy = TextEditingController();
  final meterid = TextEditingController();
   bool _agreeToTerms = false;

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: Text(
              '''Terms and Conditions for LUWASA Mobile Water Billing Application

Last Updated: November 27, 2024

1. Acceptance of Terms

By using the LUWASA mobile water billing application, you agree to comply with and be bound by the following Terms and Conditions. If you do not agree with these terms, you should not access or use the App.

2. Use of the App

The App is provided for managing your water billing and payment needs. You may use the App to view your water usage, receive bills, make payments, track past transactions, and interact with customer service. You agree to use the App for lawful purposes only and in accordance with all applicable local, state, and national laws.

3. Account Registration

To access certain features of the App, you must create an account. You agree to provide accurate, current, and complete information during the registration process and to update such information as necessary to maintain its accuracy. You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account.

4. Billing and Payments

By using the App, you agree to pay all charges related to your water consumption as determined by the utility provider. The App may allow you to make payments through various methods, such as credit/debit cards, online payment systems, or other payment options. You are responsible for ensuring that all payment information is accurate and up to date.

5. Data Privacy and Security

We value your privacy and are committed to protecting your personal information. Our collection, storage, and use of your data will be in accordance with our Privacy Policy. You agree to our collection of personal data as necessary for providing the App's services, including your billing details, payment information, and contact information.

6. Fees and Charges

The App may charge fees for certain premium services or features. These fees will be clearly disclosed before any transactions are processed. You are responsible for all charges, taxes, and fees associated with your use of the App.

7. Accuracy of Information

While we strive to provide accurate billing and payment information, we cannot guarantee the accuracy, completeness, or timeliness of data displayed in the App. You are responsible for verifying the accuracy of your bill and notifying us immediately of any discrepancies.

8. Prohibited Use

You agree not to use the App for any illegal, harmful, or fraudulent activities, including but not limited to:

Violating any applicable laws or regulations.
Transmitting malware or harmful code.
Engaging in fraudulent transactions or actions.
Interfering with or disrupting the operation of the App or its services.

9. Suspension and Termination

We reserve the right to suspend or terminate your access to the App at any time if you violate these Terms and Conditions or engage in any behavior that disrupts the operation of the App or its services.

10. Limitation of Liability

The App is provided "as is," and we do not warrant that it will be error-free, secure, or uninterrupted. We are not liable for any indirect, incidental, or consequential damages arising from the use of the App, including but not limited to billing errors, payment processing failures, or data loss.

11. Modifications to the Terms

We reserve the right to modify these Terms and Conditions at any time. Changes will be posted in the App or on our website, and your continued use of the App after such changes will constitute your acceptance of the updated terms.

12. Contact Information

For any questions, concerns, or feedback regarding these Terms and Conditions, please contact us at:

LUWASA Inc.
luwasinc00@gmail.com
              ''',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  'Signup',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  hasValidator: false,
                  hint: 'Enter fullname',
                  borderColor: Colors.grey,
                  label: 'Fullname',
                  controller: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  inputType: TextInputType.number,
                  hasValidator: false,
                  hint: 'Enter contact number',
                  borderColor: Colors.grey,
                  label: 'Contact Number',
                  controller: number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  hasValidator: false,
                  hint: 'Enter House Number',
                  borderColor: Colors.grey,
                  label: 'House Number',
                  controller: houseno,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a house number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  hasValidator: false,
                  hint: 'Enter Baranggay',
                  borderColor: Colors.grey,
                  label: 'Baranggay',
                  controller: brgy,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Baranggay';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  hasValidator: false,
                  hint: 'Enter Meter ID',
                  borderColor: Colors.grey,
                  label: 'Meter ID',
                  controller: meterid,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Meter ID';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  hasValidator: false,
                  hint: 'Enter email',
                  borderColor: Colors.grey,
                  label: 'Email',
                  controller: email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    TextFieldWidget(
                      hasValidator: false,
                      hint: 'Enter password',
                      showEye: true,
                      borderColor: Colors.grey,
                      label: 'Password',
                      isObscure: true,
                      controller: password,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
  children: [
    Checkbox(
      value: _agreeToTerms,
      onChanged: (bool? newValue) {
        setState(() {
          _agreeToTerms = newValue!;
        });
      },
    ),
    const Expanded(
      child: Text(
        'I agree to the Terms and Conditions.',
        style: TextStyle(fontSize: 14),
      ),
    ),
    TextButton(
      onPressed: _showTermsDialog,  // Show terms in a dialog when clicked
      child: const Text(
        'View Terms',
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue,  // Change color to blue for a clickable link style
        ),
      ),
    ),
  ],
),
                const SizedBox(height: 30),
                ButtonWidget(
                  label: 'Register',
                  onPressed: () {
                    if (!_agreeToTerms) {
                      showToast("Please agree to the Terms and Conditions.");
                    } else {
                      register(context);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "Already have an account?",
                      fontSize: 12,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: TextWidget(
                        color: primary,
                        fontFamily: 'Bold',
                        text: "Login",
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      addUser(name.text, email.text, number.text, houseno.text, meterid.text,
          brgy.text);

      // signup(nameController.text, numberController.text, addressController.text,
      //     emailController.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      showToast("Registered Successfully!");

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}