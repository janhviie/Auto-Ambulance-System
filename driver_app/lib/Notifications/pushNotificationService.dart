import 'dart:io';

import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:driver_app/AllWidgets/progressDialog.dart';
import 'package:driver_app/Assistants/requestAssistant.dart';
import 'package:driver_app/Notifications/notificationDialog.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/models/rideDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  getRideRequestId(message);
  print("BG HNDLER");

  // retrieveRideRequestinfo(getRideRequestId(message), context);
}

void retrieveRideRequestinfo(String rideRequestId, BuildContext context) {
  DatabaseReference newRequestReff =
      FirebaseDatabase.instance.reference().child("Ride Requests");
  newRequestReff
      .child(rideRequestId)
      .once()
      .then((DataSnapshot dataSnapshot) async {
    if (dataSnapshot.value != null) {
      String url =
          "https://us1.locationiq.com/v1/reverse.php?key=pk.87233f93316ccecba5000e79629db42f&lat=${dataSnapshot.value["latitude"]}&lon=${dataSnapshot.value["longitude"]}&format=json";
      var response = await RequestAssistant.getRequest(url);

      String pickupAdd = (response["display_name"]);

      print("DISPLAY NAME");
      print(pickupAdd);
      String pickupLat = (dataSnapshot.value["latitude"]).toString();
      String pickupLng = (dataSnapshot.value["longitude"]).toString();
      String dropOffLat = (dataSnapshot.value["hospitalLat"]).toString();
      String dropOffLng = (dataSnapshot.value["hospitalLng"]).toString();
      String hospitalAdd = (dataSnapshot.value["hospitalName"]).toString();
      String name = (dataSnapshot.value["user_name"]).toString();
      String phone = (dataSnapshot.value["user_phone"]).toString();

      RideDetails rideDetails = new RideDetails(
          pickupLat: pickupLat,
          pickupLng: pickupLng,
          dropOffLat: dropOffLat,
          dropOffLng: dropOffLng,
          hospitalAdd: hospitalAdd,
          name: name,
          phone: phone,
          pickupAdd: pickupAdd,
          ride_request_id: rideRequestId);
      print("MY ADDRESSS");
      print(rideDetails.pickupAdd);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(
                rideDetails: rideDetails,
              ));
    } else {
      displayToastMessage("Error in retrieving ride request info", context);
    }
  });
}

String getRideRequestId(RemoteMessage message) {
  if (Platform.isAndroid) {
    String params = message.data["ride_request_id"];
    print("PARAAAMSSSSSSSSSSSSSSSSSSSSSSSSSSS::::::::");
    print(params);
    return params;
  } else {
    print("ERRORRR");
    return "error";
  }
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future initialize(BuildContext context) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      getRideRequestId(message);
      retrieveRideRequestinfo(getRideRequestId(message), context);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      getRideRequestId(message);
      retrieveRideRequestinfo(getRideRequestId(message), context);

      if (message.notification != null) {
        retrieveRideRequestinfo(getRideRequestId(message), context);
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void gettoken() async {
    firebaseMessaging.getToken().then((String? val) => setToken(val));
  }

  void setToken(String? token) async {
    print("TOKEN::");
    print(token);
    User? user = await FirebaseAuth.instance.currentUser;
    driverRef.child(user!.uid).child("token").set(token);
    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }
}
