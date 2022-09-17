import 'package:driver_app/AllWidgets/historyItem.dart';
import 'package:driver_app/Assistants/AppData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip History'),
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return HistoryItem(
              history: Provider.of<AppData>(context, listen: false)
                  .tripHistorydatalist[index]);
        },
        separatorBuilder: (BuildContext context, int index) => Divider(
          thickness: 2.0,
          height: 3.0,
        ),
        itemCount: Provider.of<AppData>(context, listen: false)
            .tripHistorydatalist
            .length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
