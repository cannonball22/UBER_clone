import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/data_models/direction_detatils.dart';
import 'package:uber_clone/data_models/nearby_driver.dart';
import 'package:uber_clone/data_providers/app_data.dart';
import 'package:uber_clone/global_variables.dart';
import 'package:uber_clone/helpers/fire_helper.dart';
import 'package:uber_clone/helpers/helpermethods.dart';
import 'package:uber_clone/screens/search_page.dart';
import 'package:uber_clone/styles/styles.dart';
import 'package:uber_clone/widgets/action_button.dart';
import 'package:uber_clone/widgets/brand_divider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static const String id = "main";

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double mapBottomPadding = 0;

  //double searchSheetHeight = (Platform.isIOS) ? 300 : 400;
  //double rideDetailSheetHeight = (Platform.isAndroid) ? 235 : 260;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool rideDetailSheetVisibility = false;
  bool searchSheetVisibility = true;
  bool drawerVisibility = true;
  bool requestSheetVisibility = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;

  Position? currentPosition;

  DirectionDetails? tripDirectionDetails;

  bool nearbyDriversKeysLoaded = false;
  BitmapDescriptor? nearbyIcon;

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              ((Platform.isIOS)
                  ? "assets/images/car_ios.png"
                  : "assets/images/car_android.png"))
          .then((icon) {
        nearbyIcon = icon;
      });
    }
  }

  void setupPositionLocator() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController?.animateCamera(CameraUpdate.newCameraPosition(cp));

    startGeofireListener();
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    LatLng pickupLatLng =
        LatLng(pickup?.latitude as double, pickup?.longitude as double);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const AlertDialog(
        title: Text("Please wait..."),
      ),
    );
    LatLng destinationLatLng = LatLng(
        destination?.latitude as double, destination?.longitude as double);

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetails = thisDetails;
    });
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails?.encodedPoints as String);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polyid"),
        color: Colors.blue,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
      );
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast: LatLng(
            pickupLatLng.latitude,
            destinationLatLng.longitude,
          ));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    Marker pickupMarker = Marker(
      markerId: const MarkerId("pickup"),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup?.placeName, snippet: "My Location"),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destination"),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination?.placeName, snippet: "Destination"),
    );
    Circle pickupCircle = Circle(
      circleId: const CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void showRideDetailSheet() async {
    await getDirection();
    setState(() {
      searchSheetVisibility = false;
      drawerVisibility = false;
      requestSheetVisibility = false;
      rideDetailSheetVisibility = true;
    });
  }

  void showRequestRideSheet() async {
    await getDirection();
    setState(() {
      rideDetailSheetVisibility = false;
      searchSheetVisibility = false;
      drawerVisibility = true;
      requestSheetVisibility = true;
    });
  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailSheetVisibility = false;
      requestSheetVisibility = false;
      drawerVisibility = true;
      searchSheetVisibility = true;
      setupPositionLocator();
    });
  }

  void startGeofireListener() {
    print("RETREVING DRIVERS");
    Geofire.initialize("driversAvailable");
    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 20)
        ?.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map["key"];
            nearbyDriver.latitude = map["latitude"];
            nearbyDriver.longitude = map["longitude"];

            FireHelper.nearbyDriverList.add(nearbyDriver);
            if (nearbyDriversKeysLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map["key"]);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map["key"];
            nearbyDriver.latitude = map["latitude"];
            nearbyDriver.longitude = map["longitude"];

            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyDriversKeysLoaded = true;
            updateDriversOnMap();

            break;
        }
      }

      setState(() {});
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _markers.clear();
    });
    Set<Marker> tempMarkers = <Marker>{};
    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude!, driver.longitude!);
      Marker thisMarker = Marker(
        markerId: MarkerId("driver${driver.key}"),
        position: driverPosition,
        icon: nearbyIcon!,
        rotation: HelperMethods.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _markers = tempMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        width: 250,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  height: 160,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/user_icon.png",
                          height: 60,
                          width: 60,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Adham",
                              style: TextStyle(
                                  fontSize: 20, fontFamily: "Brand-Bold"),
                            ),
                            Text("View Profile"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const BrandDivider(),
                const SizedBox(
                  height: 10,
                ),
                const ListTile(
                  leading: Icon(Icons.card_giftcard),
                  title: Text(
                    "Free Rides",
                    style: kDrawerItemStyle,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text(
                    "Payments",
                    style: kDrawerItemStyle,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "Ride History",
                    style: kDrawerItemStyle,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.support_agent),
                  title: Text(
                    "Support",
                    style: kDrawerItemStyle,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    "About",
                    style: kDrawerItemStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            initialCameraPosition: googlePlex,
            mapType: MapType.normal,
            padding: EdgeInsets.only(
              bottom: mapBottomPadding,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setupPositionLocator();
              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });
            },
          ),
          //Menu Button
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (drawerVisibility == false) {
                  resetApp();
                } else
                  scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerVisibility) ? Icons.menu : Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // Search Sheet
          if (searchSheetVisibility)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                duration: const Duration(microseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  //height: searchSheetHeight,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        const Text("Nice to see you!",
                            style: TextStyle(
                              fontSize: 10,
                            )),
                        const Text(
                          "Where are you going?",
                          style:
                              TextStyle(fontSize: 18, fontFamily: "Brand-Bold"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var response = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                            if (response == "getDirection") {
                              showRideDetailSheet();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 0.5,
                                    offset: Offset(0.7, 0.7)),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.blueAccent),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Search Destination")
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.home,
                                color: BrandColors.colorDimText),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (Provider.of<AppData>(context)
                                                .pickupAddress !=
                                            null)
                                        ? Provider.of<AppData>(context)
                                            .pickupAddress
                                            ?.placeName as String
                                        : "Add Home",
                                    //textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  const Text(
                                    "Your residential address",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.colorDimText,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const BrandDivider(),
                        const SizedBox(
                          height: 16,
                        ),
                        const Row(
                          children: [
                            Icon(Icons.work, color: BrandColors.colorDimText),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Add Work"),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    "Your office address",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.colorDimText,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // RideDetails Sheet
          if (rideDetailSheetVisibility)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                duration: const Duration(microseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  //height: 300,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: BrandColors.colorAccent1,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset(
                                  "assets/images/taxi.png",
                                  height: 70,
                                  width: 70,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Taxi",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Brand-Bold",
                                      ),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? "${tripDirectionDetails?.distanceText}"
                                          : ""),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: BrandColors.colorTextLight),
                                    ),
                                  ],
                                ),
                                //Expanded(child: Container()),
                                Text(
                                  ((tripDirectionDetails != null)
                                      ? "\$ ${HelperMethods.estimateFares(tripDirectionDetails!)}"
                                      : ""),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Brand-Bold",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyBillAlt,
                                size: 18,
                                color: BrandColors.colorTextLight,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text("Cash"),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: BrandColors.colorText,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ActionButton(
                            buttonTitle: "Request Cab",
                            buttonColor: BrandColors.colorGreen,
                            onPressed: showRequestRideSheet,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // request Cab
          if (requestSheetVisibility)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  //height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: Center(
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                fontSize: 22.0,
                                color: Colors.black,
                                fontFamily: "Brand-Bold",
                                fontWeight: FontWeight.bold,
                              ),
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  FadeAnimatedText('Requesting a Ride...'),
                                ],
                                isRepeatingAnimation: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  width: 1,
                                  color: BrandColors.colorLightGrayFair)),
                          child: const Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Cancel ride",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
