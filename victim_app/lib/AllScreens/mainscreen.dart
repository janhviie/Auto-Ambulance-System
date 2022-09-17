import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:victim_app/AllScreens/loginScreen.dart';
import 'package:victim_app/AllScreens/registrationScreen.dart';
import 'package:victim_app/AllWidgets/CollectFareDialog.dart';
import 'package:victim_app/AllWidgets/Divider.dart';
import 'package:victim_app/AllWidgets/configMaps.dart';
import 'package:victim_app/AllWidgets/hospitalInfo.dart';
import 'package:victim_app/AllWidgets/loading.dart';
import 'package:victim_app/AllWidgets/noDriverAvailableDialog.dart';
import 'package:victim_app/AllWidgets/progressDialog.dart';
import 'package:victim_app/Assistants/assistantMethods.dart';
import 'package:victim_app/main.dart';
import 'package:victim_app/models/nearbyAvailableDrivers.dart';
import 'package:victim_app/Assistants/geoFireAssistant.dart';
import 'package:victim_app/Assistants/requestAssistant.dart';
import 'package:victim_app/models/nearbyAvailableDrivers.dart';
import 'package:victim_app/models/directionDetails.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String encoded = "";
  DatabaseReference userinf =
      FirebaseDatabase.instance.reference().child("Ride Requests");
  User? user;
  DatabaseReference rideRequestRef =
      FirebaseDatabase.instance.reference().child("Ride Requests").push();
  late String hospitalName = "";
  late double hospitalLat = 0;
  late double hospitalLng = 0;
  List<LatLng> polyPoints = [];
  Set<Polyline> polylineset = {};
  late Position currentPosition;
  late double userLat = 0;
  late double userLng = 0;
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  late BitmapDescriptor nearbyicon;
  late List<NearbyAvailableDrivers> availableDrivers;
  bool polylineErrOccured = true;
  String state = "normal";
  double driverDetailsContainerHeight = 0;
  double searchRideHeight = 0;
  double requestRideheight = 260.0;
  // ignore: cancel_subscriptions
  late StreamSubscription<Event> rideStreamSubscription;

  void cancelRide() {
    rideRequestRef.remove();
    setState(() {
      state = "normal";
      polylineset.clear();
    });
  }

  void driverDetailsContainer() {
    setState(() {
      requestRideheight = 0;
      searchRideHeight = 0;
      bottomPaddingOfMap = 280.0;
      driverDetailsContainerHeight = 280;
    });
  }

  void getCurrUser(
      String hospitalName, double hospitalLat, double hospitalLng) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    userLat = position.latitude;
    userLng = position.longitude;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference ref =
          FirebaseDatabase.instance.reference().child("users").child(uid);
      ref.once().then((DataSnapshot datasnapshot) {
        if (datasnapshot.value != null) {
          String id = datasnapshot.key.toString();
          String email = datasnapshot.value["email"];
          String name = datasnapshot.value["name"];
          String phone = datasnapshot.value["phone"];

          // save info to database

          Map Userrideinfo = {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "user_name": name,
            "user_phone": phone,
            "user_email": email,
            "user_id": id,
            "date": DateTime.now().toString(),
            "hospitalName": hospitalName,
            "hospitalLat": hospitalLat,
            "hospitalLng": hospitalLng,
          };

          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            uid = user.uid;
            DatabaseReference rf = FirebaseDatabase.instance
                .reference()
                .child("Ride Requests")
                .child(uid);
            rf.set(Userrideinfo);
            rideStreamSubscription = rf.onValue.listen((event) async {
              if (event.snapshot.value == null) {
                return;
              }
              if (event.snapshot.value["car_details"] != null) {
                setState(() {
                  carDetailsDriver =
                      event.snapshot.value["car_details"].toString();
                });
              }
              if (event.snapshot.value["driver_name"] != null) {
                setState(() {
                  carDrivername =
                      event.snapshot.value["driver_name"].toString();
                });
              }
              if (event.snapshot.value["driver_phone"] != null) {
                setState(() {
                  driverPhone = event.snapshot.value["driver_phone"].toString();
                });
              }
              if (event.snapshot.value["driver_location"] != null) {
                setState(() {
                  double driverlat = double.parse(event
                      .snapshot.value["driver_location"]["latitude"]
                      .toString());
                  double driverlng = double.parse(event
                      .snapshot.value["driver_location"]["longitude"]
                      .toString());
                  LatLng driverCurrentLocation = LatLng(driverlng, driverlng);
                });
              }

              if (event.snapshot.value["status"] != null) {
                statusRide = event.snapshot.value["status"].toString();
                if (statusRide == "accepted") {
                  rideStatus = "Driver has accepted your request";
                } else if (statusRide == "onride") {
                  rideStatus = "Going to the hospital...";
                } else if (statusRide == "Arrived") {
                  rideStatus = "Driver has arrived at your location";
                } else if (statusRide == "ended") {
                  rideStatus = "You have arrived at your location";

                  var res = await showDialog(
                      context: context,
                      builder: (BuildContext context) => CollectFareDialog());
                  if (res == 'close') {
                    rideRequestRef.onDisconnect();

                    rideStreamSubscription.cancel();
                    setState(() {
                      driverDetailsContainerHeight = 0;
                      requestRideheight = 260;
                      searchRideHeight = 0;
                      polylineset.clear();
                      markersSet.clear();
                      polyPoints.clear();
                      statusRide = "";
                      carDrivername = "";
                      carDetailsDriver = "";
                      rideStatus = "Driver is arriving";
                      driverPhone = "";
                    });
                  }
                }
              }
              if (statusRide == "accepted") {
                driverDetailsContainer();
                Geofire.stopListener();
                deleteGeofireMarkers();
              }
            });
            // cuser = user;
          }
        }
      });
    } else {
      print('ERRORR');
    }
  }

  void deleteGeofireMarkers() {
    setState(() {
      markersSet
          .removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }
  // void updateRideTime(LatLng driverCurrentLocation) async {
  //   var positionuserLatLng =
  //       LatLng(currentPosition.latitude, currentPosition.longitude);
  //   var details = await directionDetails()
  // }

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var geoLocator = Geolocator();

  double bottomPaddingOfMap = 0;
  bool nearbyAvailableDriverKeysLoaded = false;

  // to get current user position
  void locatePosition() async {
    initGeoFireListener();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // try {
    //   Geofire.queryAtLocation(position.latitude, position.longitude, 5)!
    //       .listen((map) {
    //     print("AVAILABLE DRIVERS");
    //     print(map);
    //   });
    // } catch (e) {
    //   print("ERROR IN GEOFIRE");
    //   print(e);
    // }

    // initGeoFireListener();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    createIconMaker();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand Bold"),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text("Visit Profile"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),
              SizedBox(
                height: 12.0,
              ),
              //drawer body controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    "Log Out",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineset,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition();
            },
          ),

          //HamburgerButton for drawer
          Positioned(
            top: 36.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: requestRideheight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 6.0),

                    Text(
                      "Hi there! Ask for help!",
                      style:
                          TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                    ),
                    SizedBox(height: 12.0),

                    SizedBox(
                      height: 20.0,
                    ),
                    // ignore: deprecated_member_use

                    RaisedButton(
                      color: Colors.orange,
                      textColor: Colors.black,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Help! Emergency!",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () async {
                        //
                        setState(() {
                          state = "requesting";
                        });
                        availableDrivers =
                            GeoFireAssistant.nearByAvailableDriversList;
                        searchNearestDriver();
                      },
                    ),

                    SizedBox(
                      height: 12.0,
                    ),
                    // ignore: deprecated_member_use
                    RaisedButton(
                      color: Colors.white54,
                      textColor: Colors.black,
                      child: Container(
                        height: 30.0,
                        width: 134.0,
                        child: Center(
                          child: Text(
                            "How it works?",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        //
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RIDE CANCEL, FIND DRIVER CONTAINER
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: searchRideHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 6.0),

                    Text(
                      " Searching for ride..\n Finding Nearby Drivers..",
                      style:
                          TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                    ),
                    SizedBox(height: 12.0),

                    // ignore: deprecated_member_use

                    SizedBox(
                      height: 12.0,
                    ),
                    // ignore: deprecated_member_use
                    RaisedButton(
                      color: Colors.white54,
                      textColor: Colors.black,
                      child: Container(
                        height: 30.0,
                        width: 134.0,
                        child: Center(
                          child: Text(
                            "Cancel Ride",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        //TO CANCEL THE RIDE, DELETE THE REQUEST FROM DATABASE
                        cancelRide();
                        setState(() {
                          searchRideHeight = 0;
                          requestRideheight = 260.0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // DISPLAY ASSIGNED DRIVER INFO
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: driverDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            rideStatus,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Brand-Bold",
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(height: 2.0, thickness: 2.0),
                      Text(
                        carDetailsDriver,
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        carDrivername,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Divider(height: 2.0, thickness: 2.0),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: RaisedButton(
                              onPressed: () async {
                                await launch('tel:${driverPhone}');
                              },
                              color: Colors.pink,
                              child: Padding(
                                padding: EdgeInsets.all(17),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('Call Driver',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        )),
                                    Icon(Icons.call,
                                        color: Colors.white, size: 26),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  void initGeoFireListener() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Geofire.initialize("availableDrivers");
    Geofire.queryAtLocation(position.latitude, position.longitude, 8000)!
        .listen((map) {
      if (map != null) {
        print("AVAILABLE DRIVERS");
        print(map);
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                new NearbyAvailableDrivers(
                    key: map['key'],
                    latitude: map['latitude'],
                    longitude: map['longitude']);
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            print("LISTTTTTTTTTTT");
            print(GeoFireAssistant.nearByAvailableDriversList);

            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                new NearbyAvailableDrivers(
                    key: map['key'],
                    latitude: map['latitude'],
                    longitude: map['longitude']);
            GeoFireAssistant.updateDriverNearByLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude, driver.longitude);

      Marker marker = Marker(
        markerId: MarkerId('driver'),
        position: driverAvailablePosition,
        //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
        icon: nearbyicon,
        rotation: 360.0,
      );
      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMaker() {
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: Size(0.5, 0.5));
    BitmapDescriptor.fromAssetImage(imageConfiguration, "images/auto_ios2.png")
        .then((value) {
      nearbyicon = value;
    });
  }

  void findNearbyHospital() async {
    String url =
        "https://api.foursquare.com/v2/venues/search?client_id=SLJZCERSJQQHQXHCGDYIJKXCLHBFTS1EBWH3ZSSOHIWV4CJ1&client_secret=GKJTSBDOXLEFBEZMAFLIQ2APLF4UNWUHMLKMOJITU1O0SSO5&v=20180323&limit=1&ll=${currentPosition.latitude},${currentPosition.longitude}&radius=5000&query=hospital";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      print("HOSPITAL INFO");
      hospitalName = response["response"]["venues"][0]["name"];

      hospitalLat = response["response"]["venues"][0]["location"]["lat"];
      hospitalLng = response["response"]["venues"][0]["location"]["lng"];

      hospitalInfo(
          name: hospitalName,
          hospitalLat: hospitalLat,
          hospitalLng: hospitalLng);

      print(response["response"]["venues"][0]["name"]);
      print(response["response"]["venues"][0]["location"]["lat"]);
      print(response["response"]["venues"][0]["location"]["lng"]);

      getCurrUser(hospitalName, hospitalLat, hospitalLng);
      // response["response"]["venues"][0].name
    } else {
      print("ERROR FINDING NEARBY HOSPITAL:::::");
    }
  }

  // GET DIRECTION FROM PICKUP TO DROP OFF

  void obtainPlaceDirectionDetails() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..."));

    String url =
        "https://api.tomtom.com/routing/1/calculateRoute/${currentPosition.latitude},${currentPosition.longitude}:${hospitalLat},${hospitalLng}/json?key=FA47lPFSr8sXm97xNx6HDHyR2WKCmvST";

    var res = await RequestAssistant.getRequest(url);
    Navigator.pop(context);

    if (res != "failed") {
      print("DIRECTION::");
// LatLng lng = LatLng(latitude, longitude)

      polyPoints.clear();
      List<dynamic> points = res["routes"][0]["legs"][0]["points"];
      for (dynamic point in points) {
        LatLng newPoint = LatLng(point["latitude"], point["longitude"]);
        polyPoints.add(newPoint);
      }

      print("list of POLYPOINTS::");
      print(polyPoints);
      polylineset.clear();
      setState(() {
        polylineErrOccured = false;
        Polyline polyline = Polyline(
            color: Colors.purple,
            polylineId: PolylineId("polylineID"),
            jointType: JointType.round,
            points: polyPoints,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true);

        polylineset.add(polyline);
      });

      late LatLngBounds latLngBounds;
      LatLng userPos = LatLng(userLat, userLng);
      LatLng hospPos = LatLng(hospitalLat, hospitalLng);

      // find distance between
      double PI = 3.141592653589793238;
      double rlat1 = userLat * PI / 180;
      double rlng1 = userLng * PI / 180;

      double rlat2 = hospitalLat * PI / 180;
      double rlng2 = hospitalLng * PI / 180;
      double dlong = rlng2 - rlng1;
      double dlat = rlat2 - rlat1;
      double ans = pow(sin(dlat / 2), 2) +
          cos(userLat) * cos(hospitalLat) * pow(sin(dlong / 2), 2);
      ans = 2 * asin(sqrt(ans));
      double R = 6371;
      ans = ans * R;
      ans = double.parse((ans).toStringAsFixed(0));
      AssistantMethods.FareAmount(ans * 16);

      if (userLat > hospitalLat && userLng > hospitalLng) {
        LatLng hosp = LatLng(hospitalLat, hospitalLng);
        LatLng user = LatLng(userLat, userLng);
        latLngBounds = LatLngBounds(southwest: hosp, northeast: user);
      } else if (userLng > hospitalLng) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(userLat, hospitalLng),
            northeast: LatLng(hospitalLat, userLng));
      } else if (userLat > hospitalLat) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(hospitalLat, userLng),
            northeast: LatLng(userLat, hospitalLng));
      } else {
        LatLng hosp = LatLng(hospitalLat, hospitalLng);
        LatLng user = LatLng(userLat, userLng);
        latLngBounds = LatLngBounds(southwest: user, northeast: hosp);
      }
      newGoogleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng userPositionLatLng =
          LatLng(userPosition.latitude, userPosition.longitude);
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
          infoWindow:
              InfoWindow(title: hospitalName, snippet: "Hospital location"),
          position: hospPos,
          markerId: MarkerId("dropOff"));

      setState(() {
        markersSet.add(pickupLocMarker);
        markersSet.add(dropOffLocMarker);
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
        circlesSet.add(pickupLocCircle);
        circlesSet.add(dropOffLocCircle);
      });
    } else {
      print("FAILED API");
      cancelRide();
      setState(() {
        searchRideHeight = 0;
        requestRideheight = 260.0;
        polylineErrOccured = true;
      });
      displayToastMessage("Error Occured, try again", context);
    }
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverAvailableDialog());
  }

  void searchNearestDriver() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (availableDrivers.length != 0) {
      var driver = availableDrivers[0];
      findNearbyHospital();

      obtainPlaceDirectionDetails();

      if (polylineErrOccured == false) {
        notifyDriver(driver);
        availableDrivers.removeAt(0);
        setState(() {
          searchRideHeight = 260.0;
          requestRideheight = 0;
        });
      } else
        displayToastMessage("Can't connect to drivers", context);

      return;
    } else {
      setState(() {
        searchRideHeight = 0;
        requestRideheight = 260.0;
      });
      noDriverFound();
    }
  }

  void notifyDriver(NearbyAvailableDrivers driver) {
    DatabaseReference driversReff =
        FirebaseDatabase.instance.reference().child("drivers");
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      driversReff.child(driver.key).child("newRide").set(uid);
      driversReff
          .child(driver.key)
          .child("token")
          .once()
          .then((DataSnapshot snap) {
        if (snap.value != null) {
          String token = snap.value.toString();
          print("INSIDEEEEEEEE NOTIFY DRIVER");
          AssistantMethods.sendNotificationToDriver(token, context, uid);
        } else {
          // noDriverFound();
          return;
        }
        const oneSecondPassed = Duration(seconds: 1);
        var timer = Timer.periodic(oneSecondPassed, (timer) {
          DatabaseReference dRef =
              FirebaseDatabase.instance.reference().child("drivers");
          if (state != "requesting") {
            dRef.child(driver.key).child("newRide").set("cancelled");
            dRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 30;
            timer.cancel();
          }

          driverRequestTimeOut = driverRequestTimeOut - 1;

          dRef.child(driver.key).child("newRide").onValue.listen((event) {
            if (event.snapshot.value.toString() == "accepted") {
              dRef.child(driver.key).child("newRide").onDisconnect();
              driverRequestTimeOut = 30;
              timer.cancel();
            }
          });
          if (driverRequestTimeOut == 0) {
            dRef.child(driver.key).child("newRide").set("timeout");
            dRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 30;
            timer.cancel();
            searchNearestDriver();
          }
        });
      });
      // cuser = user;
    }
  }
}
