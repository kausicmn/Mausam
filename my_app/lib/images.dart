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
  Geodesy geodesy = Geodesy();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tap(),
        ),
      ),
    );
  }

  List<Widget> tap() {
    List<Widget> widgets = [];
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
          List<DocumentSnapshot> matchingDocs = [];
          for (DocumentSnapshot d in snapshot.data!.docs) {
            GeoPoint g = d.get('geopoint');
            num distance = geodesy.distanceBetweenTwoGeoPoints(
                LatLng(g.latitude, g.longitude),
                LatLng(widget.latitude, widget.longitude));
            if (distance <= 5000) {
              matchingDocs.add(d);
            }
          }
          return Expanded(
              child: Scrollbar(
                  child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              DocumentSnapshot item = matchingDocs[index];
              return photoWidget(item);
            },
            itemCount: matchingDocs.length,
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
