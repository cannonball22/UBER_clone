//t2 Core Packages Imports
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/screens/login_page.dart';
import 'package:uber_clone/screens/mainpage.dart';
import 'package:uber_clone/widgets/action_button.dart';

//t2 Dependancies Imports
//t3 Services
//t3 Models
//t1 Exports
class RegistrationPage extends StatefulWidget {
  //SECTION - Widget Arguments
  static const String id = "register";

  RegistrationPage({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  //SECTION - Stateless functions
  void registerUser() async {
    final user = (await _auth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .catchError((ex) {
      PlatformException thisEX = ex;
      print(thisEX.message);
    }));
    if (user != null) {
      print("Registration successfully");
      DatabaseReference newUserRef =
          FirebaseDatabase.instance.ref().child("user/${user}");

      Map userMap = {
        "fullName": fullNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
      };
      newUserRef.set(userMap);

      //Take user to mainPage
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }
  }

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //SECTION - Build Setup
    //t2 -Values
    //double w = MediaQuery.of(context).size.width;
    //double h = MediaQuery.of(context).size.height;
    //t2 -Values
    //
    //t2 -Widgets
    //t2 -Widgets
    //!SECTION

    //SECTION - Build Return
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 70,
                ),
                const Image(
                  image: AssetImage("assets/images/logo.png"),
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  "Create a Rider Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: "Brand-bold"),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.text,
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email address",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      TextField(
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ActionButton(
                        onPressed: () async {
                          // check network avaliablity
                          var connectivityResult =
                              await Connectivity().checkConnectivity();

                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar("Please provide a valid full name");

                            return;
                          }
                          if (fullNameController.text.length < 3) {
                            showSnackBar("Please provide a valid full name");

                            return;
                          }

                          if (phoneController.text.length < 10) {
                            showSnackBar("Please provide a valid phone number");

                            return;
                          }
                          if (!emailController.text.contains("@")) {
                            showSnackBar(
                                "Please provide a valid email address");

                            return;
                          }

                          if (phoneController.text.length < 8) {
                            showSnackBar(
                                "password must be at least a 8 character");

                            return;
                          }
                          registerUser();
                        },
                        buttonColor: BrandColors.colorGreen,
                        buttonTitle: "REGISTER",
                      )
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.id, (route) => false);
                    },
                    child: const Text("Already have a RIDER's account, Log in"))
              ],
            ),
          ),
        ),
      ),
    );
    //!SECTION
  }
}
