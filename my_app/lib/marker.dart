import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: camel_case_types
class marker {
  Set<Marker> markers = {};
  Set<Marker> getMarker() {
    return markers;
  }

  void setMarker(Marker marker) {
    markers.add(marker);
  }

  void setMarker1(Marker marker) {
    markers.add(marker);
  }
}
