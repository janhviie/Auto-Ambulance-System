import 'dart:async';

import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:driver_app/AllWidgets/CollectFareDialog.dart';
import 'package:driver_app/AllWidgets/configMaps.dart';
import 'package:driver_app/AllWidgets/progressDialog.dart';
import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/Assistants/mapKitAssistant.dart';
import 'package:driver_app/Assistants/requestAssistant.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/models/rideDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails rideDetails;

  NewRideScreen({required this.rideDetails});

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  late GoogleMapController newRideGoogleMapController;

  Set<Marker> markerSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  double mapPaddingFromBottom = 0;
  String status = "accepted";
  String btntitle = "Arrived";
  Color btnColor = Colors.blueAccent;
  late RideDetails rd;
  var geoLocator = Geolocator();
  late StreamSubscription<Position> rideStreamSubscription;
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  late BitmapDescriptor animatingMarkerIcon;
  @override
  void initState() {
    acceptRideRequest();
    super.initState();
  }

  void createIconMaker() {
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: Size(0.5, 0.5));
    BitmapDescriptor.fromAssetImage(imageConfiguration, "images/auto_ios2.png")
        .then((value) {
      animatingMarkerIcon = value;
    });
  }

  void getRideLiveLocationUpdates() async {
    LatLng oldPos = LatLng(0, 0);
    User? user = FirebaseAuth.instance.currentUser;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      LatLng mPosition = LatLng(position.latitude, position.longitude);
      Position currPos = position;
      LatLng cp = LatLng(currPos.latitude, currPos.longitude);
      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, position.latitude, position.longitude);
      Marker animatingMarker = Marker(
          markerId: MarkerId("animating"),
          position: mPosition,
          rotation: rot,
          icon: animatingMarkerIcon,
          infoWindow: InfoWindow(title: "current location"));
      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        markerSet.removeWhere((marker) => marker.markerId.value == "animating");
        markerSet.add(animatingMarker);
      });
      oldPos = mPosition;
      Map locMap = {
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
      };
      String rideRequestId = widget.rideDetails.ride_request_id;
      newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMaker();
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: NewRideScreen._kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          polylines: polyLineSet,
          markers: markerSet,
          circles: circleSet,
          onMapCreated: (GoogleMapController controller) async {
            _controllerGoogleMap.complete(controller);
            newRideGoogleMapController = controller;
            setState(() {
              mapPaddingFromBottom = 265.0;
            });
            obtainPlaceDirectionDetails();

            getRideLiveLocationUpdates();
          },
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7))
                ]),
            height: 270.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Column(
                children: [
                  // Text(
                  //   "10 mins",
                  //   style: TextStyle(
                  //       fontSize: 14.0,
                  //       fontFamily: "Brand-Bold",
                  //       color: Colors.deepPurple),
                  // ),
                  // SizedBox(
                  //   height: 6.0,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.rideDetails.name,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontFamily: "Brand-Bold",
                        ),
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await launch('tel:${rd.phone}');
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.9),
                          child: Icon(Icons.call),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 26.0,
                  ),
                  Row(
                    children: [
                      Image.asset("images/pickicon.png",
                          height: 16.0, width: 16.0),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                          child: Container(
                        child: Text(
                          widget.rideDetails.pickupAdd,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Image.asset("images/desticon.png",
                          height: 16.0, width: 16.0),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                          child: Container(
                        child: Text(
                          widget.rideDetails.hospitalAdd,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 17.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: RaisedButton(
                      onPressed: () async {
                        if (status == "accepted") {
                          status = "Arrived";
                          String rideRequestId =
                              widget.rideDetails.ride_request_id;
                          newRequestRef
                              .child(rideRequestId)
                              .child("status")
                              .set(status);
                          setState(() {
                            btntitle = "Start Trip";
                            btnColor = Colors.purple;
                          });
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) => ProgressDialog(
                              message: "Please wait..",
                            ),
                          );
                          obtainDropOffPolyline();
                          Navigator.pop(context);
                        } else if (status == "Arrived") {
                          status = "onride";
                          String rideRequestId =
                              widget.rideDetails.ride_request_id;
                          newRequestRef
                              .child(rideRequestId)
                              .child("status")
                              .set(status);
                          setState(() {
                            btntitle = "End Trip";
                            btnColor = Colors.redAccent;
                          });
                        } else if (status == "onride") {
                          endTheTrip();
                        }
                      },
                      color: btnColor,
                      child: Padding(
                        padding: EdgeInsets.all(13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              btntitle,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(Icons.directions_car,
                                color: Colors.white, size: 26)
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }

// POLYLINE FROM VICTIM TO HOSPITAL

  void obtainDropOffPolyline() async {
    String pickupLat = widget.rideDetails.pickupLat;
    String pickupLng = widget.rideDetails.pickupLng;
    String dropOffLat = widget.rideDetails.dropOffLat;
    String dropOffLng = widget.rideDetails.dropOffLng;

    LatLng pickupLatLng =
        LatLng(double.parse(pickupLat), double.parse(pickupLng));
    LatLng dropOffLatLng =
        LatLng(double.parse(dropOffLat), double.parse(dropOffLng));

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..."));

    String url =
        "https://api.tomtom.com/routing/1/calculateRoute/${pickupLat},${pickupLng}:${dropOffLat},${dropOffLng}/json?key=FA47lPFSr8sXm97xNx6HDHyR2WKCmvST";

    var res = await RequestAssistant.getRequest(url);
    Navigator.pop(context);

    if (res != "failed") {
      print("DIRECTION::");
// LatLng lng = LatLng(latitude, longitude)

      polylineCoordinates.clear();
      List<dynamic> points = res["routes"][0]["legs"][0]["points"];
      for (dynamic point in points) {
        LatLng newPoint = LatLng(point["latitude"], point["longitude"]);
        polylineCoordinates.add(newPoint);
      }

      print("list of POLYPOINTS::");
      print(polylineCoordinates);
      // polyLineSet.clear();
      setState(() {
        Polyline polyline = Polyline(
            color: Colors.purple,
            polylineId: PolylineId("polylineID"),
            jointType: JointType.round,
            points: polylineCoordinates,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true);

        polyLineSet.add(polyline);
      });

      double victimLat = double.parse(pickupLat);
      double victimLng = double.parse(pickupLng);
      double destLat = double.parse(dropOffLat);
      double destLng = double.parse(dropOffLng);

      late LatLngBounds latLngBounds;
      LatLng userPos = LatLng(victimLat, victimLng);
      LatLng hospPos = LatLng(destLat, destLng);
      if (victimLat > destLat && victimLng > destLng) {
        LatLng hosp = LatLng(destLat, destLng);
        LatLng user = LatLng(victimLat, victimLng);
        latLngBounds = LatLngBounds(southwest: hosp, northeast: user);
      } else if (victimLng > destLng) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(victimLat, destLng),
            northeast: LatLng(destLat, victimLng));
      } else if (victimLat > destLat) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(destLat, victimLng),
            northeast: LatLng(victimLat, destLng));
      } else {
        LatLng hosp = LatLng(destLat, destLng);
        LatLng user = LatLng(victimLat, victimLng);
        latLngBounds = LatLngBounds(southwest: user, northeast: hosp);
      }
      newRideGoogleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      LatLng userPositionLatLng = LatLng(victimLat, victimLng);
// PICKUP LOCATION MARKER
      Marker pickupLocMarker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow:
              InfoWindow(title: "Your Location", snippet: "Your location"),
          position: userPositionLatLng,
          markerId: MarkerId("pickup"));

// DROP OFF LOCATION MARKER

      Marker dropOffLocMarker = Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: hospPos,
          markerId: MarkerId("dropOff"));

      setState(() {
        markerSet.add(pickupLocMarker);
        markerSet.add(dropOffLocMarker);
      });

// PICKUP LOCATION CIRCLE
      Circle pickupLocCircle = Circle(
          fillColor: Colors.blue,
          center: userPositionLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.blueAccent,
          circleId: CircleId("pickup"));

// DROP OFF LOCATION CIRCLE

      Circle dropOffLocCircle = Circle(
          fillColor: Colors.deepPurple,
          center: hospPos,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.deepPurple,
          circleId: CircleId("dropOff"));

      setState(() {
        circleSet.add(pickupLocCircle);
        circleSet.add(dropOffLocCircle);
      });
    } else {
      print("FAILED API");

      displayToastMessage("Error Occured, try again", context);
    }
  }

// POLYLINE FROM DRIVER LOCATION TO VICTIM LOCATION
  void obtainPlaceDirectionDetails() async {
    Position driverPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var currentLatLng = LatLng(driverPos.latitude, driverPos.longitude);
    var pickupLatLng = LatLng(double.parse(widget.rideDetails.pickupLat),
        double.parse(widget.rideDetails.pickupLng));
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..."));

    String url =
        "https://api.tomtom.com/routing/1/calculateRoute/${currentLatLng.latitude},${currentLatLng.longitude}:${pickupLatLng.latitude},${pickupLatLng.longitude}/json?key=FA47lPFSr8sXm97xNx6HDHyR2WKCmvST";

    var res = await RequestAssistant.getRequest(url);
    Navigator.pop(context);

    if (res != "failed") {
      print("DIRECTION::");
// LatLng lng = LatLng(latitude, longitude)

      polylineCoordinates.clear();
      List<dynamic> points = res["routes"][0]["legs"][0]["points"];
      for (dynamic point in points) {
        LatLng newPoint = LatLng(point["latitude"], point["longitude"]);
        polylineCoordinates.add(newPoint);
      }

      print("list of POLYPOINTS::");
      print(polylineCoordinates);
      // polylineCoordinates.clear();
      setState(() {
        Polyline polyline = Polyline(
            color: Colors.red,
            polylineId: PolylineId("polylineID"),
            jointType: JointType.round,
            points: polylineCoordinates,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true);

        polyLineSet.add(polyline);
      });

      late LatLngBounds latLngBounds;

      if (currentLatLng.latitude > pickupLatLng.latitude &&
          currentLatLng.longitude > pickupLatLng.longitude) {
        LatLng pickupPos =
            LatLng(pickupLatLng.latitude, pickupLatLng.longitude);
        LatLng driverPos =
            LatLng(currentLatLng.latitude, currentLatLng.longitude);
        latLngBounds = LatLngBounds(southwest: pickupPos, northeast: driverPos);
      } else if (currentLatLng.longitude > pickupLatLng.longitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(currentLatLng.latitude, pickupLatLng.longitude),
            northeast: LatLng(pickupLatLng.latitude, currentLatLng.longitude));
      } else if (currentLatLng.latitude > pickupLatLng.latitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(pickupLatLng.latitude, currentLatLng.longitude),
            northeast: LatLng(currentLatLng.latitude, pickupLatLng.longitude));
      } else {
        LatLng pickupPos =
            LatLng(pickupLatLng.latitude, pickupLatLng.longitude);
        LatLng driverPos =
            LatLng(currentLatLng.latitude, currentLatLng.longitude);
        latLngBounds = LatLngBounds(southwest: driverPos, northeast: pickupPos);
      }
      newRideGoogleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

// PICKUP LOCATION MARKER
      Marker pickupLocMarker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          position: currentLatLng,
          markerId: MarkerId("pickup"));

// DROP OFF LOCATION MARKER

      Marker dropOffLocMarker = Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pickupLatLng,
          markerId: MarkerId("dropOff"));

      setState(() {
        markerSet.add(pickupLocMarker);
        markerSet.add(dropOffLocMarker);
      });

// PICKUP LOCATION CIRCLE
      Circle pickupLocCircle = Circle(
          fillColor: Colors.blue,
          center: currentLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.blueAccent,
          circleId: CircleId("pickup"));

// DROP OFF LOCATION CIRCLE

      Circle dropOffLocCircle = Circle(
          fillColor: Colors.deepPurple,
          center: pickupLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.deepPurple,
          circleId: CircleId("dropOff"));

      setState(() {
        circleSet.add(pickupLocCircle);
        circleSet.add(dropOffLocCircle);
      });
    } else {
      print("FAILED API");
      // cancelRide();
      // setState(() {
      //   searchRideHeight = 0;
      //   requestRideheight = 260.0;
      // });
      displayToastMessage("Error Occured, try again", context);
    }
  }

  void acceptRideRequest() async {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation.phone);
    newRequestRef
        .child(rideRequestId)
        .child("driver_id")
        .set(driversInformation.id);
    newRequestRef.child(rideRequestId).child("car_details").set(
        "${driversInformation.car_color}-${driversInformation.car_model}-${driversInformation.car_number}");

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Map locMap = {
      "latitude": position.latitude.toString(),
      "longitude": position.longitude.toString(),
    };

    newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    DatabaseReference dReff =
        FirebaseDatabase.instance.reference().child("drivers");
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      dReff.child(uid).child("history").child(rideRequestId).set(true);
    }
  }

  void updateRideDetails() async {
    LatLng destinationLatLng;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var posLatLng = LatLng(position.latitude, position.longitude);
    if (status == "accepted") {
      LatLng pickup = LatLng(double.parse(widget.rideDetails.pickupLat),
          double.parse(widget.rideDetails.pickupLng));
      destinationLatLng = pickup;
    } else {
      LatLng dropOff = LatLng(double.parse(widget.rideDetails.dropOffLat),
          double.parse(widget.rideDetails.dropOffLng));
      destinationLatLng = dropOff;
    }
  }

  endTheTrip() {
    print("trip ended");
    User? user = FirebaseAuth.instance.currentUser;
    String rideRequestId = widget.rideDetails.ride_request_id;
    rideStreamSubscription.cancel();
    Geofire.removeLocation(user!.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    newRequestRef.child(rideRequestId).child("status").set("ended");

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CollectFareDialog(
              rideDetails: widget.rideDetails,
            ));
    saveEarnings();

    // DatabaseReference av = FirebaseDatabase.instance
    //     .reference()
    //     .child("availableDrivers")
    //     .child(user!.uid);
    // av.remove();
  }

  void saveEarnings() async {
    DatabaseReference drf =
        FirebaseDatabase.instance.reference().child("drivers");

    CollectFareDialog collectFareDialog =
        new CollectFareDialog(rideDetails: widget.rideDetails);
    double fareAmount = collectFareDialog.totalFare();

    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      drf.child(uid).child("earnings").once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          double oldEarnings = double.parse(snapshot.value.toString());
          double totalEarnings = fareAmount + oldEarnings;
          drf.child(uid).child("earnings").set(totalEarnings.toString());
        } else {
          drf.child(uid).child("earnings").set(fareAmount.toString());
        }
      });
      // cuser = user;
    }
  }
}
