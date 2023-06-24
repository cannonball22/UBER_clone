import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/data_models/address.dart';
import 'package:uber_clone/data_models/prediction.dart';
import 'package:uber_clone/data_providers/app_data.dart';
import 'package:uber_clone/global_variables.dart';
import 'package:uber_clone/helpers/request_helper.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;

  const PredictionTile({
    required this.prediction,
    super.key,
  });

  getPlaceDetails(String? placeID, context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Please wait...'),
              //status:
            ));
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeID;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);
      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceDetails(prediction.placeId, context);
      },
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Icon(
                Icons.location_pin,
                color: BrandColors.colorDimText,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ((prediction.mainText != null)
                          ? (prediction.mainText as String)
                          : ""),
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      ((prediction.secondaryText != null)
                          ? (prediction.secondaryText as String)
                          : ""),
                      style: const TextStyle(
                          fontSize: 12, color: BrandColors.colorDimText),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
