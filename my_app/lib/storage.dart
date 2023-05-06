import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';

class PhotoStorage {
  bool _initialized = false;

  PhotoStorage();

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print('Initialized default app $app');
    }
  }

  bool get isInitialized => _initialized;
}
