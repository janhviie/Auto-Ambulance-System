import 'package:driver_app/models/history.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  late String earnings = "";
  late int countTrips = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistorydatalist = [];
  void updateEarnings(String updatedEarnings) {
    earnings = updatedEarnings;
    notifyListeners();
  }

  void updateTripsCounter(int tripCounter) {
    countTrips = tripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistoryData(History eachHistory) {
    tripHistorydatalist.add(eachHistory);
    notifyListeners();
  }
}
