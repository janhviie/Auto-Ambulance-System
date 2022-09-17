class RideDetails {
  late String pickupLat = "";
  late String pickupLng = "";
  late String dropOffLat = "";
  late String dropOffLng = "";
  late String hospitalAdd = "";
  late String name = "";
  late String phone = "";
  late String url = "";
  late String pickupAdd = "";
  late String ride_request_id = "";

  RideDetails(
      {required this.pickupLat,
      required this.pickupLng,
      required this.dropOffLat,
      required this.dropOffLng,
      required this.hospitalAdd,
      required this.name,
      required this.phone,
      required this.pickupAdd,
      required this.ride_request_id});
}
