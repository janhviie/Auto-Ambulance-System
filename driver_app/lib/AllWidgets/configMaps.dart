import 'dart:async';

import 'package:driver_app/models/drivers.dart';
import 'package:geolocator/geolocator.dart';

String mapKey = "AIzaSyCO1QoDF2cYJBLIezJ4XtiCOZuNU0UPCkE";
late Drivers driversInformation;

late StreamSubscription<Position> homeTabPageStreamSubscription;
// late StreamSubscription<Position> rideStreamSubscription;
