import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/models/history.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final History history;
  HistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Image.asset("images/desticon.png", height: 16, width: 16),
                    SizedBox(height: 18),
                    Expanded(
                        child: Container(
                            child: Text(
                      history.dropoff,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Brand-Bold',
                          fontSize: 16,
                          color: Colors.black),
                    ))),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text(AssistantMethods.formatTripDate(history.createdAt),
                  style: TextStyle(color: Colors.grey))
            ],
          )
        ],
      ),
    );
  }
}
