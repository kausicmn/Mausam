import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';

class DisplayImage extends StatefulWidget {
  const DisplayImage(
      {super.key, required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
      ),
      body: Center(
        child: FutureBuilder<List<Widget>>(
          future: images_list(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data!,
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Widget>> images_list() async {
    List<Widget> widgets = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('photos').get();
    List<DocumentSnapshot> docs = querySnapshot.docs;
    Geodesy geodesy = Geodesy();
    List<DocumentSnapshot> matchingDocs = [];
    for (DocumentSnapshot d in docs) {
      GeoPoint g = d.get('geopoint');
      num distance = geodesy.distanceBetweenTwoGeoPoints(
          LatLng(g.latitude, g.longitude),
          LatLng(widget.latitude, widget.longitude));
      if (distance <= 5000) {
        matchingDocs.add(d);
      }
    }
    widgets.add(Expanded(
        child: Scrollbar(
            child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        DocumentSnapshot item = matchingDocs[index];
        return photoWidget(item);
      },
      itemCount: matchingDocs.length,
      shrinkWrap: true,
    ))));
    return widgets;
  }

  List<Widget> tap(double latitude, double longitude) {
    List<Widget> widgets = [];
    var minLat = latitude - 0.009; // approx 10km south
    var maxLat = latitude + 0.009; // approx 10km north
    var minLong = longitude - 0.009; // approx 10km west
    var maxLong = longitude + 0.009; // approx 10km east
    GeoPoint min = GeoPoint(minLat, minLong);
    GeoPoint max = GeoPoint(maxLat, maxLong);
    Geodesy geodesy = Geodesy();
    num distance = geodesy.distanceBetweenTwoGeoPoints(
        LatLng(minLat, minLong), LatLng(maxLat, maxLong));
    // GeoPoint x = GeoPoint(latitude, longitude);
    print(distance);
    widgets.add(StreamBuilder(
        stream: FirebaseFirestore.instance.collection("photos").snapshots(),
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
          return Expanded(
              child: Scrollbar(
                  child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              DocumentSnapshot item = snapshot.data!.docs[index];
              return photoWidget(item);
            },
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
          )));
        }));
    return widgets;
  }

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
}
