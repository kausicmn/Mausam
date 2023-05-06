import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/position.dart';
import 'package:uuid/uuid.dart';
import 'add_photos.dart';

import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  late CameraPosition _kLake;
  late Set<Marker> markers;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late Marker _currentLocationMarker;
  late GeoPoint userLocation;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Future<Position> returnPosition(Position? position) async {
    if (position == null) {
      return Future.error("No position");
    }
    return position;
  }

  // Future signInWithGoogle() async {
  //   // Trigger the authentication flow
  // }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _position = PositionHelper().determinePosition();
    markers = <Marker>{};

    // setState(() {
    //   PhotoStorage().initializeDefault();
    // });
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
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
                    userLocation = GeoPoint(
                        snapshot.data!.latitude, snapshot.data!.longitude);
                    _currentLocationMarker = Marker(
                        markerId: MarkerId(const Uuid().v4()),
                        position: LatLng(
                            snapshot.data!.latitude, snapshot.data!.longitude),
                        infoWindow: const InfoWindow(title: 'Current Location'),
                        // onTap: () {
                        //   _onMarkerTapped(MarkerId(markerIdVal))
                        //   print('lat $snapshot.data!.latitude');
                        //   print('long $snapshot.data!.longitude');
                        //   userLocation = GeoPoint(
                        //       _currentLocationMarker.position.latitude,
                        //       _currentLocationMarker.position.longitude);
                        //   final photos = getBody();
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => Scaffold(
                        //         appBar: AppBar(
                        //           title: const Text('Photos'),
                        //         ),
                        //         body: ListView.builder(
                        //           itemCount: photos.length,
                        //           itemBuilder: (BuildContext context, int index) {
                        //             return photos[index];
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   );
                        // },
                        onTap: () => _onMarkerTapped());
                    markers.add(_currentLocationMarker);
                    return GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            snapshot.data!.latitude, snapshot.data!.longitude),
                        zoom: 14.4746,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: markers,
                    );
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
      // body: GoogleMap(
      //   mapType: MapType.normal,
      //   initialCameraPosition: _kGooglePlex,
      //   onMapCreated: (GoogleMapController controller) {
      //     _controller.complete(controller);
      //   },
      // ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Future<void> _goToTheLake(Position position) async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //     target: LatLng(position.latitude, position.longitude),
  //     zoom: 14.4746,
  //   )));
  // }

  List<Widget> getBody() {
    List<Widget> widgets = [];
    widgets.add(StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("photos")
            .where("geopoint", isGreaterThanOrEqualTo: userLocation)
            .where("geopoint", isLessThanOrEqualTo: userLocation)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error.toString());
            }
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Text("Loading Photos");
          }
          return Scrollbar(
              child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              DocumentSnapshot item = snapshot.data!.docs[index];
              return photoWidget(item);
            },
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
          ));
        }));
    return widgets;
  }

  // Widget getBody() {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance
  //         .collection("photos")
  //         .where("geopoint", isGreaterThanOrEqualTo: userLocation)
  //         .where("geopoint", isLessThanOrEqualTo: userLocation)
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         if (kDebugMode) {
  //           print(snapshot.error.toString());
  //         }
  //         return Text(snapshot.error.toString());
  //       }
  //       if (!snapshot.hasData) {
  //         return const Text("Loading Photos");
  //       }
  //       return Expanded(
  //         child: Scrollbar(
  //           child: ListView.builder(
  //             physics: const AlwaysScrollableScrollPhysics(),
  //             itemBuilder: (context, index) {
  //               DocumentSnapshot item = snapshot.data!.docs[index];
  //               return photoWidget(item);
  //             },
  //             itemCount: snapshot.data!.docs.length,
  //             shrinkWrap: true,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget photoWidget(DocumentSnapshot snapshot) {
    try {
      return Column(
        children: [
          ListTile(
            title: Text(snapshot["title"]),
            subtitle: Text(snapshot["uid"]),
          ),
          Image.network(snapshot["downloadURL"])
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return ListTile(title: Text(e.toString()));
    }
  }
  // List<Widget> getUnsignedBody() {
  //   List<Widget> widgets = [];
  //   widgets.add(const Text("You are not currently signed in"));
  //   widgets.add(ElevatedButton(
  //       onPressed: signInWithGoogle, child: const Text("Sign In")));
  //   return widgets;
  // }
}
