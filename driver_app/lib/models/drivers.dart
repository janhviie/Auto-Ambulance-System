import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String email = "";
  String name = "";
  String phone = "";
  String? id = "";
  String car_model = "";
  String car_number = "";
  String car_color = "";

  Drivers({
    required this.email,
    required this.name,
    required this.phone,
    required this.id,
    required this.car_model,
    required this.car_number,
    required this.car_color,
  });
  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    phone = dataSnapshot.value["phone"];
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    car_model = dataSnapshot.value["car_details"]["car_model"];
    car_color = dataSnapshot.value["car_details"]["car_color"];
    car_number = dataSnapshot.value["car_details"]["car_number"];
  }
}
