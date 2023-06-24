import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/data_providers/app_data.dart';
import 'package:uber_clone/screens/login_page.dart';
import 'package:uber_clone/screens/mainpage.dart';
import 'package:uber_clone/screens/registration_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDbWT0BSsPWkk3x2YOOALMkzn4rQiw6e5w",
      appId: "1:1030842345335:android:446be3e43a36e1e9ad6372",
      databaseURL:
          "https://uber-clone-5bd2a-default-rtdb.europe-west1.firebasedatabase.app",
      messagingSenderId: '1030842345335',
      projectId: 'uber-clone-5bd2a',
    ),
  );
  runApp(MyApp());
}
//t2 Core Packages Imports

//t2 Dependancies Imports
//t3 Services
//t3 Models
//t1 Exports
class MyApp extends StatelessWidget {
  //SECTION - Widget Arguments
  //!SECTION
  //
  const MyApp({
    Key? key,
  }) : super(
          key: key,
        );

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
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
          theme: ThemeData(
            fontFamily: "Brand-Regular",
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          initialRoute: MainPage.id,
          routes: {
            RegistrationPage.id: (context) => RegistrationPage(),
            LoginPage.id: (context) => LoginPage(),
            MainPage.id: (context) => MainPage(),
          }),
    );
    //!SECTION
  }
}
