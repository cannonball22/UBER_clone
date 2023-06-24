import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/data_models/address.dart';
import 'package:uber_clone/data_models/direction_detatils.dart';
import 'package:uber_clone/data_providers/app_data.dart';
import 'package:uber_clone/global_variables.dart';
import 'package:uber_clone/helpers/request_helper.dart';

class HelperMethods {
  static Future<String> findCoordinatesAddress(
      Position position, context) async {
    String placeAddress = '';

    // check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if (response != 'Failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = Address();

      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);

    if (response == "Failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details) {
    // per km = 0.3$
    // per min == 0.2$
    // base fare == 3$
    double baseFare = 3;
    double distanceFare = (details.distanceValue! / 1000) * 0.3;
    double timeFare = (details.durationValue! / 60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

/*
  static void getCurrentUserInfo() async {
    User? currentUser = await FirebaseAuth.instance.currentUser;
    String? userId = currentUser?.uid;
    // DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users/$userId");
  }*/

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);
    return randInt.toDouble();
  }
}
