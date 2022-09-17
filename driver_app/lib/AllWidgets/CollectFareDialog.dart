import 'dart:math';

import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/models/rideDetails.dart';
import 'package:flutter/material.dart';

class CollectFareDialog extends StatelessWidget {
  late final RideDetails rideDetails;
  CollectFareDialog({required this.rideDetails});
  totalFare() {
    double PI = 3.141592653589793238;
    double lat1 = double.parse(rideDetails.pickupLat);
    double long1 = double.parse(rideDetails.pickupLng);
    double lat2 = double.parse(rideDetails.dropOffLat);
    double long2 = double.parse(rideDetails.dropOffLng);

    double rlat1 = lat1 * PI / 180;
    double rlng1 = long1 * PI / 180;

    double rlat2 = lat2 * PI / 180;
    double rlng2 = long2 * PI / 180;
    double dlong = rlng2 - rlng1;
    double dlat = rlat2 - rlat1;

    double ans =
        pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlong / 2), 2);
    ans = 2 * asin(sqrt(ans));
    double R = 6371;
    ans = ans * R;
    ans = double.parse((ans).toStringAsFixed(0));
    return (ans * 16);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22),
            Text('Trip Fare'),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 9),
            Text(
              "Rs. " + totalFare().toString(),
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Brand-Bold",
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'This is the total trip amount, it has been charged to the rider',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RaisedButton(
                onPressed: () async {
                  print('AMOUNTTTTT TO BE PAID: ' + totalFare().toString());
                  Navigator.pop(context);
                  Navigator.pop(context);
                  AssistantMethods.enablehomeTabLiveLocationUpdates();
                },
                color: Colors.deepPurpleAccent,
                child: Padding(
                    padding: EdgeInsets.all(17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Collect Cash",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.attach_money, color: Colors.white, size: 26),
                      ],
                    )),
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}
