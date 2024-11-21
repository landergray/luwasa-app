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
                ButtonWidget(
                  label: 'Register',
                  onPressed: () {
                    register(context);
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
