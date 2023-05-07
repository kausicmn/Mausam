import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tap(widget.latitude, widget.longitude),
        ),
      ),
    );
  }
}

List<Widget> tap(double latitude, double longitude) {
  List<Widget> widgets = [];
  GeoPoint markerLocation = GeoPoint(latitude, longitude);
  widgets.add(StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("photos")
          .where("geopoint", isGreaterThanOrEqualTo: markerLocation)
          .where("geopoint", isLessThanOrEqualTo: markerLocation)
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
