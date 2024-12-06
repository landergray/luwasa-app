import 'dart:typed_data';
import 'package:alert_system/utils/colors.dart';
import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/button_widget.dart';
import 'package:alert_system/widgets/text_widget.dart';
import 'package:alert_system/widgets/touchable_opacity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:alert_system/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String userProfileUrl = ''; // To store the profile image URL

  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker instance

  // Function to pick an image from the gallery or camera
  Future<void> pickImage() async {
    // Pick image from the gallery
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Convert the picked image to Uint8List for uploading to Firebase Storage
      Uint8List imageData = await pickedFile.readAsBytes();

      // Upload image to Firebase Storage
      String? imageUrl = await uploadImageToStorage(imageData, pickedFile.name);

      if (imageUrl != null) {
        // Update the user's profile URL in Firestore
        await updateUserProfile(imageUrl);
      }
    }
  }

  // Function to upload image to Firebase Storage
  Future<String?> uploadImageToStorage(
      Uint8List imageData, String fileName) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String filePath =
          'user_profiles/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = storage.ref(filePath);

      await ref.putData(imageData); // Upload the image data

      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Function to update the user profile image URL in Firestore
 Future<void> updateUserProfile(String profileUrl) async {
  try {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Ensure the userId is not empty (no logged-in user)
    if (userId.isEmpty) {
      print("No user logged in, cannot update profile.");
      return;
    }

    // Update the 'profile' field in the document of the logged-in user
    DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    
    await userDoc.update({
      'profile': profileUrl,  // Update the profile field
    });

    setState(() {
      userProfileUrl = profileUrl;  // Update the local state with the new profile URL
    });
    print("Profile updated successfully.");
  } catch (e) {
    print("Error updating profile: $e");  // Log error if any
  }
}

  void logout() {
    FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user ID
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Ensure that userId is not null or empty
    if (userId.isEmpty) {
      return Center(child: Text("No user logged in"));
    }

    final Stream<DocumentSnapshot> userData =
        FirebaseFirestore.instance.collection('Users').doc(userId).snapshots();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 235, 240),
      body: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic data = snapshot.data;

            // If profile URL is available, use it; otherwise, use a default avatar
            String avatarUrl =
                userProfileUrl.isNotEmpty ? userProfileUrl : data['profile'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: pickImage, // Open image picker on avatar tap
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secondary,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CircleAvatar(
                                backgroundColor: primary,
                                minRadius: 75,
                                maxRadius: 75,
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null, // Display user's avatar if available
                                child: avatarUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: TextWidget(
                      text: data['name'],
                      fontSize: 28,
                      color: secondary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TouchableOpacity(
                    child: Center(
                      child: Container(
                        width: 350,
                        height: 40,
                        decoration: BoxDecoration(
                          color: secondary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: 'Personal Information',
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: 'Medium',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'EMAIL ADDRESS',
                          fontSize: 10,
                          color: secondary,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: data['email'],
                          fontSize: 14,
                          color: secondary,
                          fontFamily: 'Medium',
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Divider(
                      color: secondary, // Divider color, you can customize
                    ),
                  ),
                  const SizedBox(
                    height: 10, // Adds space between email and mobile number
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'MOBILE NUMBER',
                          fontSize: 10,
                          color: secondary,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: data['number'],
                          fontSize: 14,
                          color: secondary,
                          fontFamily: 'Medium',
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Divider(
                      color: secondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: TextWidget(
                      text: 'Meter',
                      fontSize: 10,
                      color: secondary,
                      fontFamily: 'Regular',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: TextWidget(
                      text: data['meterid'],
                      fontSize: 14,
                      color: secondary,
                      fontFamily: 'Medium',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Divider(
                      color: secondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: TextWidget(
                      text: 'Baranggay',
                      fontSize: 10,
                      color: secondary,
                      fontFamily: 'Regular',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: TextWidget(
                      text: data['brgy'],
                      fontSize: 14,
                      color: secondary,
                      fontFamily: 'Medium',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Divider(
                      color: secondary,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 30),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Privacy Policy'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Types of Data Collected\n'
                                      'Among the types of Personal Data that this Application collects, by itself or through third parties, there are: email address, Camera permission, Precise location permission (continuous), Approximate location permission (continuous), Microphone permission and Phone permission.\n\n'
                                      'Complete details on each type of Personal Data collected are provided in the dedicated sections of this privacy policy or by specific explanation texts displayed prior to the Data collection.\n\n'
                                      'The Personal Data may be freely provided by the User, or, in case of Usage Data, collected automatically when using this Application.\n\n'
                                      'All Data requested by this Application is mandatory and failure to provide this Data may make it impossible for this Application to provide its services. In cases where this Application specifically states that some Data is not mandatory, Users are free not to communicate this Data without any consequences on the availability or the functioning of the service.\n\n'
                                      'Users who are uncertain about which Personal Data is mandatory are welcome to contact us.\n\n'
                                      'Any use of Cookies – or of other tracking tools – by this Application or by the owners of third party services used by this Application serves the purpose of providing the service required by the User, in addition to any other purposes described in the present document and in the Cookie Policy, if available.\n\n'
                                      'Users are responsible for any third party Personal Data obtained, published or shared through this Application and confirm that they have the third party\'s consent to provide the Data to the Owner.\n\n'
                                      'Mode and place of processing the Data\n'
                                      'Methods of processing\n'
                                      'The Data Controller processes the Data of Users in a proper manner and shall take appropriate security measures to prevent unauthorized access, disclosure, modification, or unauthorized destruction of the Data.\n\n'
                                      // Add more sections of the privacy policy here as needed
                                      'The Data is processed at the Data Controller\'s operating offices and in any other places where the parties involved with the processing are located. For further information, please contact the Data Controller.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              Colors.blue, // Color of the Privacy Policy button
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: TextWidget(
                            text: 'Privacy Policy',
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ),
                    ),
                  ),

// Logout tile
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 30),
                    child: GestureDetector(
                      onTap: logout, // Your logout function
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red, // Color of the Logout button
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: TextWidget(
                            text: 'Logout',
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
