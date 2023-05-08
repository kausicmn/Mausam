import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'position.dart';

class AddPhoto extends StatefulWidget {
  const AddPhoto({super.key, required this.title});

  final String title;

  @override
  State<AddPhoto> createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  File? _image;
  Position? _position;
  final myController = TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    PositionHelper().determinePosition().then((value) => setState(() {
          _position = value;
        }));
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Capture a photo
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        if (kDebugMode) {
          print("No image picked");
        }
      }
    });
  }

  void _upload() async {
    if (_image == null) {
      return;
    }
    if (myController.text == "") {
      return;
    }
    if (_position == null) {
      return;
    }
    var uuid = const Uuid();
    final String uuidString = uuid.v4();
    final String downloadUrl = await uploadFile(uuidString);
    await _addItem(downloadUrl, myController.text, uuidString);
    if (kDebugMode) {
      print(uuidString);
    }
    Navigator.pop(context);
  }

  Future<String> uploadFile(String filename) async {
    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/jpeg', contentLanguage: 'en');

    // Upload the file to firebase
    UploadTask uploadTask = ref.putFile(_image!, metadata);

    // Waits till the file is uploaded then stores the download url
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    if (kDebugMode) {
      print(downloadUrl);
    }
    return downloadUrl;
  }

  Future<void> _addItem(String downloadURL, String title, String uid) async {
    await FirebaseFirestore.instance.collection('photos').add({
      'downloadURL': downloadURL,
      'title': title,
      'geopoint': GeoPoint(_position!.latitude, _position!.longitude),
      'uid': uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
          child: Column(
        children: [
          _image != null
              ? Image.file(_image!)
              : const Text("No image selected"),
          TextField(
            controller: myController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Title of the photo"),
          ),
          ElevatedButton(
            onPressed: _upload,
            child: const Text("Submit"),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Take Photo',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
