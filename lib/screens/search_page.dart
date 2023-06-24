//t2 Core Packages Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/data_models/prediction.dart';
import 'package:uber_clone/data_providers/app_data.dart';
import 'package:uber_clone/global_variables.dart';
import 'package:uber_clone/helpers/request_helper.dart';
import 'package:uber_clone/widgets/brand_divider.dart';
import 'package:uber_clone/widgets/prediction_tile.dart';

//t2 Dependancies Imports
//t3 Services
//t3 Models
//t1 Exports
class SearchPage extends StatefulWidget {
  //SECTION - Widget Arguments
  //!SECTION
  //
  const SearchPage({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //
  //SECTION - State Variables
  //t2 --Controllers
  late TextEditingController pickupController;
  late TextEditingController destinationController;
  FocusNode focusDestination = FocusNode();
  bool focused = false;

  List<Prediction> destinationPredictionList = [];

  //t2 --Controllers
  //
  //t2 --State
  //t2 --State
  //
  //t2 --Constants
  //t2 --Constants
  //!SECTION

  @override
  void initState() {
    super.initState();
    //
    //SECTION - State Variables initializations & Listeners
    //t2 --Controllers & Listeners
    pickupController = TextEditingController();
    destinationController = TextEditingController();
    //t2 --Controllers & Listeners
    //
    //t2 --State
    //t2 --State
    //
    //t2 --Late & Async Initializers
    //t2 --Late & Async Initializers
    //!SECTION
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //
    //SECTION - State Variables initializations & Listeners
    //t2 --State
    //t2 --State
    //!SECTION
  }

  //SECTION - Stateless functions
  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:eg';
      var response = await RequestHelper.getRequest(url);
      if (response == 'failed') {
        return;
      }
      if (response["status"] == "OK") {
        var predictionsJson = response["predictions"];
        var thisList = (predictionsJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  //!SECTION

  //SECTION - Action Callbacks
  //!SECTION

  @override
  Widget build(BuildContext context) {
    //SECTION - Build Setup
    //t2 -Values
    //double w = MediaQuery.of(context).size.width;
    //double h = MediaQuery.of(context).size.height;
    String address =
        Provider.of<AppData>(context).pickupAddress?.placeName ?? "";
    pickupController.text = address;
    setFocus();
    //t2 -Values
    //
    //t2 -Widgets
    //t2 -Widgets
    //!SECTION

    //SECTION - Build Return
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  //height: 230,
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    )
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24, top: 48, right: 24, bottom: 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Stack(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(Icons.arrow_back)),
                            const Center(
                              child: Text(
                                "Set Destination",
                                style: TextStyle(
                                    fontSize: 20, fontFamily: "Brand-Bold"),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/pickIcon.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: BrandColors.colorLightGray,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: TextField(
                                    controller: pickupController,
                                    decoration: const InputDecoration(
                                        hintText: "Pickup location",
                                        fillColor:
                                            BrandColors.colorLightGrayFair,
                                        filled: true,
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 8, bottom: 8)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/destination.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: BrandColors.colorLightGray,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: TextField(
                                    onChanged: (val) {
                                      searchPlace(val);
                                    },
                                    focusNode: focusDestination,
                                    controller: destinationController,
                                    decoration: const InputDecoration(
                                        hintText: "Where to?",
                                        fillColor:
                                            BrandColors.colorLightGrayFair,
                                        filled: true,
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 8, bottom: 8)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            (destinationPredictionList.isNotEmpty)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          prediction: destinationPredictionList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
    //!SECTION
  }

  @override
  void dispose() {
    //SECTION - Disposable variables
    destinationController.dispose();
    pickupController.dispose();
    //!SECTION
    super.dispose();
  }
}
