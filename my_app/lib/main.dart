import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/images.dart';
import 'package:my_app/position.dart';
import 'package:uuid/uuid.dart';
import 'add_photos.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'
          // storage: PhotoStorage(),
          ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  // final PhotoStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      getMarkersFromFirebase();
    });
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      setState(() {
        _position = returnPosition(position);
        // _goToTheLake(position!);
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
    // Create a new marker
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
      getMarkersFromFirebase();
    });
  }

  Future<void> getMarkersFromFirebase() async {
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
