import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/images.dart';
import 'package:my_app/position.dart';
import 'package:uuid/uuid.dart';
import 'add_photos.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Future<Position> _position;
  late Set<Marker> markers;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Future<Position> returnPosition(Position? position) async {
    if (position == null) {
      return Future.error("No position");
    }
    return position;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _position = PositionHelper().determinePosition();
    markers = <Marker>{};
    setState(() {
      getMarkers();
    });
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      setState(() {
        _position = returnPosition(position);
      });
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
            future: _position,
            builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                default:
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (snapshot.hasData) {
                    return GoogleMap(
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(snapshot.data!.latitude,
                              snapshot.data!.longitude),
                          zoom: 14.4746,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: markers,
                        onTap: _handleTap);
                  }
                  return Text("Error: ${snapshot.error}");
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddPhoto(
                        title: "Add a Photo",
                      )));
        },
        tooltip: 'Add a Photo',
        child: const Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _handleTap(LatLng point) {
    final marker = Marker(
      markerId: MarkerId(const Uuid().v4()),
      position: point,
    );
    FirebaseFirestore.instance.collection('marker').add({
      'id': marker.markerId.toString(),
      'latitude': marker.position.latitude,
      'longitude': marker.position.longitude,
    });
    setState(() {
      getMarkers();
    });
  }

  Future<void> getMarkers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('marker').get();
    for (DocumentSnapshot doc in snapshot.docs) {
      double latitude = doc.get('latitude');
      double longitude = doc.get('longitude');
      Marker marker = Marker(
        markerId: MarkerId(doc.get('id')),
        position: LatLng(latitude, longitude),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayImage(
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          );
        },
      );
      setState(() {
        markers.add(marker);
      });
    }
  }
}
