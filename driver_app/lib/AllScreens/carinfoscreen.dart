import 'package:driver_app/AllScreens/mainscreen.dart';
import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class carInfoScreen extends StatelessWidget {
  static const idScreen = "carinfo";
  TextEditingController carModel = TextEditingController();
  TextEditingController carNum = TextEditingController();
  TextEditingController carColor = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 22.0,
            ),
            Image.asset(
              "images/logo.jpg",
              width: 390.0,
              height: 250.0,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
              child: Column(
                children: [
                  SizedBox(height: 12.0),
                  Text(
                    "Enter Auto Details",
                    style: TextStyle(fontFamily: "Brand-bold", fontSize: 24.0),
                  ),
                  SizedBox(height: 12.0),

                  // car model
                  TextField(
                    controller: carModel,
                    decoration: InputDecoration(
                        labelText: "Auto Model",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0)),
                    style: TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(height: 10.0),
                  // car number
                  TextField(
                    controller: carNum,
                    decoration: InputDecoration(
                        labelText: "Auto Number",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0)),
                    style: TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(height: 10.0),

                  // car color
                  TextField(
                    controller: carColor,
                    decoration: InputDecoration(
                        labelText: "Auto Colour",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0)),
                    style: TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(height: 42.0),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (carModel.text.isEmpty) {
                          displayToastMessage(
                              "Please enter car model", context);
                        } else if (carNum.text.isEmpty) {
                          displayToastMessage(
                              "Please enter car number", context);
                        } else if (carColor.text.isEmpty) {
                          displayToastMessage(
                              "Please enter car colour", context);
                        } else {
                          saveDriverCarInfo(context);
                        }
                      },
                      color: Theme.of(context).accentColor,
                      child: Padding(
                        padding: EdgeInsets.all(17.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "NEXT",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 26.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  void saveDriverCarInfo(context) async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      Map carInfoMap = {
        "car_color": carColor.text,
        "car_number": carNum.text,
        "car_model": carModel.text,
      };

      driverRef.child(uid).child("car_details").set(carInfoMap);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    }
  }
}
