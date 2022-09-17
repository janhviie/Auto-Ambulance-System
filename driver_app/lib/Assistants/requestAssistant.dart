import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

var obj = {
  "place_id": "236737697",
  "licence": "https:\/\/locationiq.com\/attribution",
  "osm_type": "relation",
  "osm_id": "5367420",
  "lat": "18.44016905",
  "lon": "73.7994928463743",
  "display_name":
      "Saptasur, DSK Vishwa Road, Shivane, Dhayari, Haveli, Pune District, Maharashtra, 411041, India",
  "address": {
    "address29": "Saptasur",
    "road": "DSK Vishwa Road",
    "suburb": "Shivane",
    "town": "Dhayari",
    "county": "Haveli",
    "state_district": "Pune District",
    "state": "Maharashtra",
    "postcode": "411041",
    "country": "India",
    "country_code": "in"
  },
  "boundingbox": ["18.4391398", "18.4411", "73.7991836", "73.8005659"]
};

// String url =
//     "https://us1.locationiq.com/v1/reverse.php?key=pk.87233f93316ccecba5000e79629db42f&lat=18.4396262&lon=73.8003138&format=json";

class RequestAssistant {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));
    try {
      if (response.statusCode == 200) {
        String jsondata = response.body;
        var decodeData = jsonDecode(jsondata);
        return decodeData;
      } else {
        return "failed";
      }
    } catch (exp) {
      return "failed";
    }
  }
}
