import 'package:driver_app/AllScreens/historyScreen.dart';
import 'package:driver_app/Assistants/AppData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningTabPage extends StatelessWidget {
  const EarningTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black87,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text(
                  "Total Earnings",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                    "Rs ${Provider.of<AppData>(context, listen: false).earnings}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: "Brand-Bold"))
              ],
            ),
          ),
        ),
        FlatButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: Row(
                children: [
                  Image.asset("images/auto_ios.png", width: 70),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    "Total Trips",
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        Provider.of<AppData>(context, listen: false)
                            .countTrips
                            .toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            )),
        Divider(
          height: 2.0,
          thickness: 2.0,
        )
      ],
    );
  }
}
