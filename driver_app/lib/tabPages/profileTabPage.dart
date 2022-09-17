import 'package:driver_app/AllScreens/loginScreen.dart';
import 'package:driver_app/AllWidgets/configMaps.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            driversInformation.name,
            style: TextStyle(
              fontSize: 65,
              color: Colors.black87,
              fontFamily: 'Signatra',
            ),
          ),
          SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              )),
          InfoCard(
            text: driversInformation.phone,
            icon: Icons.phone,
          ),
          InfoCard(
            text: driversInformation.email,
            icon: Icons.email,
          ),
          InfoCard(
            text: driversInformation.car_color +
                " " +
                driversInformation.car_model +
                " " +
                driversInformation.car_number,
            icon: Icons.electric_rickshaw,
          ),
          GestureDetector(
            onTap: () {
              rideRequestRef.onDisconnect();
              rideRequestRef.remove();
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Geofire.removeLocation(user.uid);
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              }
            },
            child: Card(
              color: Colors.red,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 100),
              child: ListTile(
                trailing:
                    Icon(Icons.follow_the_signs_outlined, color: Colors.white),
                title: Text("Sign Out",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Brand Bold')),
              ),
            ),
          )
        ],
      ),
    ));
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;

  InfoCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: ListTile(
            leading: Icon(
              icon,
              color: Colors.black87,
            ),
            title: Text(text,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontFamily: 'Brand Bold'))),
      ),
    );
  }
}
