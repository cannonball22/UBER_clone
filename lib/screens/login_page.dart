//t2 Core Packages Imports
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/screens/registration_page.dart';
import 'package:uber_clone/widgets/action_button.dart';

//t2 Dependancies Imports
//t3 Services
//t3 Models
//t1 Exports
class LoginPage extends StatelessWidget {
  //SECTION - Widget Arguments
  static const String id = "login";

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login() {}

  //!SECTION
  //
  LoginPage({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    //SECTION - Build Setup
    void showSnackBar(String title) {
      final snackbar = SnackBar(
        content: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      );
    }
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
                  "Sign In as a Rider",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: "Brand-bold"),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email address",
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
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
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

                          if (!emailController.text.contains("@")) {
                            showSnackBar(
                                "Please provide a valid email address");

                            return;
                          }

                          login();
                        },
                        buttonColor: BrandColors.colorGreen,
                        buttonTitle: "LOGIN",
                      )
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RegistrationPage.id, (route) => false);
                    },
                    child: Text("Don't have and account, sign up here"))
              ],
            ),
          ),
        ),
      ),
    );

    //!SECTION
  }
}
