import 'package:driver_app/AllWidgets/configMaps.dart';
import 'package:driver_app/Assistants/AppData.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/models/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static void disablehomeTabLiveLocationUpdates() async {
    homeTabPageStreamSubscription.pause();
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      Geofire.removeLocation(user.uid);
    }
  }

  static void enablehomeTabLiveLocationUpdates() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    homeTabPageStreamSubscription.resume();
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      Geofire.setLocation(user.uid, position.latitude, position.longitude);
    }
  }

  static void retrieveHistoryInfo(context) {
    // RETRIEVE AND DISPLAY EARNINGS
    DatabaseReference dref =
        FirebaseDatabase.instance.reference().child("drivers");
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      dref
          .child(uid)
          .child("earnings")
          .once()
          .then((DataSnapshot datasnapshot) {
        if (datasnapshot.value != null) {
          String earnings = datasnapshot.value.toString();
          Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
        }
      });

      // RETRIEVE AND DISPLAY drive history
      DatabaseReference drefhis =
          FirebaseDatabase.instance.reference().child("drivers");
      User? userr = FirebaseAuth.instance.currentUser;
      if (userr != null) {
        String uid = userr.uid;
        drefhis
            .child(uid)
            .child("history")
            .once()
            .then((DataSnapshot datasnapshot) {
          if (datasnapshot.value != null) {
            Map<dynamic, dynamic> keys = datasnapshot.value;
            int tripCounter = keys.length;
            Provider.of<AppData>(context, listen: false)
                .updateTripsCounter(tripCounter);

            // update trip keys to provder
            List<String> tripHistoryKeys = [];

            keys.forEach((key, value) {
              tripHistoryKeys.add(key);
            });
            Provider.of<AppData>(context, listen: false)
                .updateTripKeys(tripHistoryKeys);
            obtainTripRequestHistoryData(context);
          }
        });
      }
    }
  }

  static void obtainTripRequestHistoryData(
    context,
  ) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for (String key in keys) {
      // History history;
      History history;
      newRequestRef.child(key).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          history = History.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false)
              .updateTripHistoryData(history);
        }
      });
    }
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }
}
