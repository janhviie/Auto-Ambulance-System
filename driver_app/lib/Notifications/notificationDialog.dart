import 'package:driver_app/AllScreens/newRideScreen.dart';
import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/models/rideDetails.dart';
import 'package:driver_app/tabPages/homeTabPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;
  NotificationDialog({required this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.0),
            Image.asset(
              "images/logo.jpg",
              width: 120.0,
            ),
            SizedBox(height: 18.0),
            Text("New Ride Request",
                style: TextStyle(fontFamily: "Brand-Bold", fontSize: 18.0)),
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/pickicon.png",
                          height: 16.0, width: 16.0),
                      SizedBox(height: 20.0),
                      Expanded(
                        child: Container(
                          child: Text(rideDetails.pickupAdd,
                              style: TextStyle(fontSize: 18.0)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/desticon.png",
                          height: 16.0, width: 16.0),
                      SizedBox(height: 20.0),
                      Expanded(
                        child: Container(
                          child: Text(rideDetails.hospitalAdd,
                              style: TextStyle(fontSize: 18.0)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.0),
                ],
              ),
            ),
            SizedBox(height: 2.0),
            Divider(height: 2.0, color: Colors.black, thickness: 3.0),
            SizedBox(height: 2.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    onPressed: () {
                      // DatabaseReference rideRequestRef = FirebaseDatabase
                      //     .instance
                      //     .reference()
                      //     .child("Ride Requests")
                      //     .child(rideDetails.ride_request_id);
                      // rideRequestRef.remove();

                      rideRequestReff.set("cancelled");

                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    color: Colors.white,
                    textColor: Colors.red,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  RaisedButton(
                    onPressed: () {
                      checkAvailabilityOfRide(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.green)),
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text("Accept".toUpperCase()),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestReff.once().then((DataSnapshot dataSnapShot) {
      Navigator.pop(context);
      String rideId = "";
      if (dataSnapShot.value != null) {
        rideId = dataSnapShot.value.toString();
      } else {
        displayToastMessage("Ride does not exist", context);
      }

      if (rideId == rideDetails.ride_request_id) {
        rideRequestReff.set("accepted");
        AssistantMethods.disablehomeTabLiveLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewRideScreen(rideDetails: rideDetails)));
      } else if (rideId == "cancelled") {
        displayToastMessage("Ride has been Cancelled", context);
      } else if (rideId == "timeout") {
        displayToastMessage("Ride has timed out", context);
      } else {
        displayToastMessage("Ride not exists", context);
      }
    });
  }
}
