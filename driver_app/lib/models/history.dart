import 'package:firebase_database/firebase_database.dart';

class History {
  late String createdAt;
  late String status;

  late String dropoff;

  History({
    required this.createdAt,
    required this.status,
    required this.dropoff,
  });
  History.fromSnapshot(DataSnapshot snapshot) {
    createdAt = snapshot.value["date"];
    status = snapshot.value["status"];
    print("DATEE $createdAt");
    dropoff = snapshot.value["hospitalName"];
    print("DROP OFFFF $dropoff");
  }
}
