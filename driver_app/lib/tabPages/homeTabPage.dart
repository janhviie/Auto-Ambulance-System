import 'dart:async';

import 'package:driver_app/AllScreens/currentUser.dart';
import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:driver_app/AllWidgets/configMaps.dart';
import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/Notifications/pushNotificationService.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/models/drivers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

User? user = FirebaseAuth.instance.currentUser;
DatabaseReference rideRequestReff = FirebaseDatabase.instance
    .reference()
    .child("drivers")
    .child(user!.uid)
    .child("newRide");

class HomeTabPage extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  late GoogleMapController newGoogleMapController;

  late Position currentPosition;

  var geoLocator = Geolocator();

  String driverStatus = "Go Online  ";

  Color driverstatuscolor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void getCurrentDriverInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    driverRef.child(user!.uid).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.gettoken();
    AssistantMethods.retrieveHistoryInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          myLocationEnabled: true,
          // zoomGesturesEnabled: true,
          // zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            locatePosition();
          },
        ),

        // online offline container '

        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (isDriverAvailable != true) {
                      // call make driver online function to store live location
                      makeDriverOnlineNow();
                      getLocationLiveUpdates();

                      setState(() {
                        driverstatuscolor = Colors.green;
                        driverStatus = "Online Now";
                        isDriverAvailable = true;
                      });
                      displayToastMessage("You are Online now", context);
                    } else {
                      // call make driver offline function
                      setState(() {
                        driverstatuscolor = Colors.black;
                        driverStatus = "Go Online";
                        isDriverAvailable = false;
                      });
                      makeDriverOfflineNow();
                      displayToastMessage("You are Offline now", context);

                      // rideRequestRef = null;
                    }
                  },
                  color: driverstatuscolor,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          driverStatus,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 26.0,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(currentUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
  }

  void makeDriverOnlineNow() async {
    User? user = await FirebaseAuth.instance.currentUser;

    Geofire.initialize("availableDrivers");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Geofire.setLocation(user!.uid, position.latitude, position.longitude);

    rideRequestReff.set("searching");
    rideRequestReff.onValue.listen((event) {});
  }

  void getLocationLiveUpdates() async {
    User? user = FirebaseAuth.instance.currentUser;
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(user!.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void getdrivers() async {
    print("FROM DRIVERS APP");
    // Map<String, dynamic> response =
    //     await Geofire.getLocation("DaY0hgljbgZM0nQYGGrSEL8XyXt2");

    // print(response);

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Geofire.queryAtLocation(position.latitude, position.longitude, 8000)!
        .listen((map) {
      print("AVAILABLE DRIVERS");
      print(map);
    });
  }
}
