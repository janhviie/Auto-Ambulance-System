import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:victim_app/Assistants/assistantMethods.dart';

class CollectFareDialog extends StatelessWidget {
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
              "Rs. " + AssistantMethods.cash.toString(),
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
                  print('AMOUNTTTTT TO BE PAID: ' +
                      AssistantMethods.cash.toString());
                  Navigator.pop(context, "close");
                  Navigator.pop(context, "close");
                  Navigator.pop(context, "close");
                },
                color: Colors.deepPurpleAccent,
                child: Padding(
                    padding: EdgeInsets.all(17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pay Cash",
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
