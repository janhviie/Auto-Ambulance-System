import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class currentUser {
// var obj=: Got a message whilst in the foreground!
// I/flutter (14421): Message data: {ride_request_id: -Mbg5F6GPy9aqzsqrLwE, id: 1, click_action: FLUTTER_NOTIFICATION_CLICK, status: done}

  static late String uid = "";
  // static late Position currpos;
  // static late User cuser;
  void location() async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      // cuser = user;
    }
  }

  // void currloc() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   currpos = position;
  // }
}
