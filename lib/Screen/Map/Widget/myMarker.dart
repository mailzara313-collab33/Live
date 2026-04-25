import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Set<Marker> myMarker(
  Set<Marker> markers,
  LatLng latlong,
  StateSetter stateSetter,
  TextEditingController locationController,
) {
  markers.add(
    Marker(
      markerId: MarkerId(
        Random().nextInt(10000).toString(),
      ),
      position: LatLng(
        latlong.latitude,
        latlong.longitude,
      ),
    ),
  );

  getLocation(latlong, stateSetter, locationController);

  return markers;
}

Future<void> getLocation(LatLng latlong, StateSetter stateSetter,
    TextEditingController locationController) async {
  List<Placemark> placemark = await placemarkFromCoordinates(
    latlong.latitude,
    latlong.longitude,
  );

  var placemarkItem = placemark[0];

  String address = [
    placemarkItem.name,
    placemarkItem.subLocality,
    placemarkItem.locality,
    placemarkItem.administrativeArea,
    placemarkItem.country,
    placemarkItem.postalCode
  ].where((element) => element != null && element.isNotEmpty).join(', ');

  locationController.text = address;
  stateSetter(() {});
}
