import 'package:alert_system/screens/auth/login_screen.dart';
import 'package:alert_system/utils/const.dart';
import 'package:alert_system/widgets/button_widget.dart';
import 'package:alert_system/widgets/logout_widget.dart';
import 'package:alert_system/widgets/touchable_opacity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../widgets/text_widget.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData =
        FirebaseFirestore.instance.collection('Users').doc(userId).snapshots();
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Drawer();
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Drawer();
            }
            dynamic data = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: secondary,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: CircleAvatar(
                              backgroundColor: primary,
                              minRadius: 75,
                              maxRadius: 75,
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
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
                        const SizedBox(
                          width: 120,
                        ),
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
                          text: data['email'],
                          fontSize: 14,
                          color: secondary,
                          fontFamily: 'Medium',
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        TextWidget(
                          text:
                              '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t${data['number']}',
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
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'House Number',
                              fontSize: 10,
                              color: secondary,
                              fontFamily: 'Regular',
                            ),
                            TextWidget(
                              text: data['houseno'],
                              fontSize: 14,
                              color: secondary,
                              fontFamily: 'Medium',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TouchableOpacity(
                    onTap: () {
                      showPrivacy(context, 'Privacy Policy', '''
          Types of Data Collected
          Among the types of Personal Data that this Application collects, by itself or through third parties, there are: email address, Camera permission, Precise location permission (continuous), Approximate location permission (continuous), Microphone permission and Phone permission.
          Complete details on each type of Personal Data collected are provided in the dedicated sections of this privacy policy or by specific explanation texts displayed prior to the Data collection.
          The Personal Data may be freely provided by the User, or, in case of Usage Data, collected automatically when using this Application.
          All Data requested by this Application is mandatory and failure to provide this Data may make it impossible for this Application to provide its services. In cases where this Application specifically states that some Data is not mandatory, Users are free not to communicate this Data without any consequences on the availability or the functioning of the service.
          Users who are uncertain about which Personal Data is mandatory are welcome to contact us.
          Any use of Cookies – or of other tracking tools – by this Application or by the owners of third party services used by this Application serves the purpose of providing the service required by the User, in addition to any other purposes described in the present document and in the Cookie Policy, if available.
          Users are responsible for any third party Personal Data obtained, published or shared through this Application and confirm that they have the third party's consent to provide the Data to the Owner.
           
          Mode and place of processing the Data
          Methods of processing
          The Data Controller processes the Data of Users in a proper manner and shall take appropriate security measures to prevent unauthorized access, disclosure, modification, or unauthorized destruction of the Data.
          The Data processing is carried out using computers and/or IT enabled tools, following organizational procedures and modes strictly related to the purposes indicated. In addition to the Data Controller, in some cases, the Data may be accessible to certain types of persons in charge, involved with the operation of the site (administration, sales, marketing, legal, system administration) or external parties (such as third party technical service providers, mail carriers, hosting providers, IT companies, communications agencies) appointed, if necessary, as Data Processors by the company. The updated list of these parties may be requested from the Data Controller at any time.
           
           
           
          Place
          The Data is processed at the Data Controller's operating offices and in any other places where the parties involved with the processing are located. For further information, please contact the Data Controller.
           
          Retention time
          The Data is kept for the time necessary to provide the service requested by the User, or stated by the purposes outlined in this document, and the User can always request that the Data Controller suspend or remove the data.
           
          The use of the collected Data
          The Data concerning the User is collected to allow the Owner to provide its services, as well as for the following purposes: Access to third party accounts, Managing contacts and sending messages and Device permissions for Personal Data access.
          The Personal Data used for each purpose is outlined in the specific sections of this document.
           
          Facebook permissions asked by this Application
          This Application may ask for some Facebook permissions allowing it to perform actions with the User's Facebook account and to retrieve information, including Personal Data, from it. This service allows this Application to connect with the User's account on the Facebook social network, provided by Facebook Inc.
          For more information about the following permissions, refer to the Facebook permissions documentation and to the Facebook privacy policy.
           
          The permissions asked are the following:
          Basic information
          By default, this includes certain User’s Data such as id, name, picture, gender, and their locale. Certain connections of the User, such as the Friends, are also available. If the User has made more of their Data public, more information will be available.
           
          Email
          Provides access to the User's primary email address.
           
          Device permissions for Personal Data access
          Depending on the User's specific device, this Application may request certain permissions that allow it to access the User's device Data as described below.
          By default, these permissions must be granted by the User before the respective information can be accessed. Once the permission has been given, it can be revoked by the User at any time. In order to revoke these permissions, Users may refer to the device settings or contact the Owner for support at the contact details provided in the present document.
          The exact procedure for controlling app permissions may be dependent on the User's device and software.
          Please note that the revoking of such permissions might impact the proper functioning of this Application.
          If User grants any of the permissions listed below, the respective Personal Data may be processed (i.e accessed to, modified or removed) by this Application.
           
          Approximate location permission (continuous)
          Used for accessing the User's approximate device location. This Application may collect, use, and share User location Data in order to provide location-based services.
           
          Camera permission
          Used for accessing the camera or capturing images and video from the device.
           
          Microphone permission
          Used for accessing and recording microphone audio from the User's device.
           
          Phone permission
          Used for accessing a host of typical features associated with telephony. This enables, for instance, read-only access to the “phone state”, which means it enables access to the phone number of the device, current mobile network information, make calls and send SMS.
           
          Precise location permission (continuous)
          Used for accessing the User's precise device location. This Application may collect, use, and share User location Data in order to provide location-based services.
           
          Detailed information on the processing of Personal Data
          Personal Data is collected for the following purposes and using the following services:
          Access to third party accounts
          Device permissions for Personal Data access
          Managing contacts and sending messages
           
          Additional information about Data collection and processing
          Legal action
          The User's Personal Data may be used for legal purposes by the Data Controller, in Court or in the stages leading to possible legal action arising from improper use of this Application or the related services.
          The User declares to be aware that the Data Controller may be required to reveal personal data upon request of public authorities.
           
          Additional information about User's Personal Data
          In addition to the information contained in this privacy policy, this Application may provide the User with additional and contextual information concerning particular services or the collection and processing of Personal Data upon request. 
          System logs and maintenance
          For operation and maintenance purposes, this Application and any third party services may collect files that record interaction with this Application (System logs) or use for this purpose other Personal Data (such as IP Address).
           
          Information not contained in this policy
          More details concerning the collection or processing of Personal Data may be requested from the Data Controller at any time. Please see the contact information at the beginning of this document.
           
          The rights of Users
          Users have the right, at any time, to know whether their Personal Data has been stored and can consult the Data Controller to learn about their contents and origin, to verify their accuracy or to ask for them to be supplemented, cancelled, updated or corrected, or for their transformation into anonymous format or to block any data held in violation of the law, as well as to oppose their treatment for any and all legitimate reasons. Requests should be sent to the Data Controller at the contact information set out above.
          This Application does not support “Do Not Track” requests.
          To determine whether any of the third party services it uses honor the “Do Not Track” requests, please read their privacy policies.
           
          Changes to this privacy policy
          The Data Controller reserves the right to make changes to this privacy policy at any time by giving notice to its Users on this page. It is strongly recommended to check this page often, referring to the date of the last modification listed at the bottom. If a User objects to any of the changes to the Policy, the User must cease using this Application and can request that the Data Controller remove the Personal Data. Unless stated otherwise, the then-current privacy policy applies to all Personal Data the Data Controller has about Users.
          
          
          ''');
                    },
                    child: tileWidget(
                        'Privacy Policy',
                        const Icon(
                          Icons.privacy_tip_outlined,
                          color: Colors.white,
                        ),
                        secondary),
                  ),
                  TouchableOpacity(
                    onTap: () {
                      logout(context, const LoginScreen());
                    },
                    child: tileWidget(
                        'Logout',
                        const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        Colors.red),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget tileWidget(String title, Widget suffix, Color tileColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Center(
        child: Container(
          width: 350,
          height: 40,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: title,
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: 'Medium',
                ),
                suffix
              ],
            ),
          ),
        ),
      ),
    );
  }

  showPrivacy(context, String label, String caption) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 500,
          width: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: secondary,
                    size: 50,
                  ),
                  TextWidget(
                    text: label,
                    fontSize: 24,
                    color: secondary,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 300,
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secondary,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextWidget(
                          align: TextAlign.start,
                          maxLines: 500,
                          text: caption,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ButtonWidget(
                    width: 320,
                    label: 'OKAY',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  showFavorites(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 500,
          width: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: secondary,
                    size: 50,
                  ),
                  TextWidget(
                    text: 'Favorites',
                    fontSize: 24,
                    color: secondary,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextWidget(
                    text: 'click on the heart to remove from favorites',
                    fontSize: 15,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // SizedBox(
                  //   height: 375,
                  //   child: SingleChildScrollView(
                  //     child: Column(
                  //       children: [
                  //         for (int i = 0; i < 10; i++)
                  //           Padding(
                  //             padding: const EdgeInsets.only(bottom: 15),
                  //             child: Container(
                  //               width: 320,
                  //               height: 65,
                  //               decoration: BoxDecoration(
                  //                 color: secondary,
                  //                 borderRadius: BorderRadius.circular(
                  //                   20,
                  //                 ),
                  //               ),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.start,
                  //                 children: [
                  //                   Image.asset(
                  //                     'assets/images/Rectangle 40.png',
                  //                     height: double.infinity,
                  //                     width: 120,
                  //                   ),
                  //                   const SizedBox(
                  //                     width: 10,
                  //                   ),
                  //                   TextWidget(
                  //                     text: 'Bluebird Coffee',
                  //                     fontSize: 20,
                  //                     color: Colors.white,
                  //                     fontFamily: 'Bold',
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
