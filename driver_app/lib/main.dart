import 'package:driver_app/AllScreens/carinfoscreen.dart';
import 'package:driver_app/AllScreens/currentUser.dart';
import 'package:driver_app/Assistants/AppData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/AllScreens/loginScreen.dart';
import 'package:driver_app/AllScreens/mainscreen.dart';
import 'package:provider/provider.dart';

import 'AllScreens/registrationScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

User? user = FirebaseAuth.instance.currentUser;

DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child("users");

DatabaseReference newRequestRef =
    FirebaseDatabase.instance.reference().child("Ride Requests");

DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child("drivers");

DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child("drivers")
    .child(user!.uid)
    .child("newRide");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Auto Ambulance App',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // initialRoute: LoginScreen.idScreen,
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idScreen
            : MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
          carInfoScreen.idScreen: (context) => carInfoScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
