import 'dart:convert';

import 'package:victim_app/AllWidgets/configMaps.dart';
import 'package:victim_app/AllWidgets/hospitalInfo.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {
  static double cash = 0;
  static void sendNotificationToDriver(
      String token, context, String ride_request_id) async {
    Map<String, String> headermap = {
      'content-type': 'application/json',
      'Authorization': serverToken,
    };

    Map notificationMap = {
      'body': 'Drop Off Address,',
      'title': 'New Ride Request'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_request_id': ride_request_id
    };

    Map sendNotification = {
      "notification": notificationMap,
      "data": dataMap,
      "priority": "high",
      "to": token
    };

    final res = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headermap,
        body: jsonEncode(sendNotification));

    if (res.statusCode == 200) {
      print("SUCCESS SENDING NOTIGICTION");
    } else
      print("ERROR SENDING PUSH NOTIFICATION");
  }

  static void FareAmount(double fare) {
    cash = fare;
  }
}
