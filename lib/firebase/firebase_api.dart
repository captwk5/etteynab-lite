import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_banyette/firebase/firebase_options.dart';
import 'package:the_banyette/model/masterpiece.dart';

class FirebaseApiService {
  FirebaseApiService.privateConstructor();
  late Reference storageRef;
  bool isInitialized = false;

  static final FirebaseApiService instance =
      FirebaseApiService.privateConstructor();

  factory FirebaseApiService() {
    return instance;
  }

  Future<void> initialization() async {
    await Firebase.initializeApp();
    FirebaseDatabase database = FirebaseDatabase.instance;

    DatabaseReference userInfo = database.ref('users');
    userInfo.onValue.listen((DatabaseEvent event) {
      // for (final child in event.snapshot.children) {
      // }
    });

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    storageRef = FirebaseStorage.instance.ref();
    isInitialized = true;
  }

  Future<Map<String, MasterPiece>> getImageList() async {
    Map<String, List<String>> imageUrlMap = HashMap();
    Map<String, List<String>> removeImageUrlMap = HashMap();
    Map<String, MasterPiece> dataMap = HashMap();
    ListResult results = await storageRef.listAll();

    for (var element in results.items) {
      String imageUrl =
          await instance.storageRef.child(element.name).getDownloadURL();
      // imageList.add();
      String key = element.name.split('_').first;
      if (imageUrlMap[key] == null) {
        imageUrlMap[key] = [];
      }

      if (!element.name.split('_').last.contains('r')) {
        imageUrlMap[key]?.add(imageUrl);
      } else {
        removeImageUrlMap[key]?.add(imageUrl);
      }
    }

    for (var key in imageUrlMap.keys) {
      dataMap[key] = MasterPiece(
          imageUrl: imageUrlMap[key]!,
          title: "",
          price: "price",
          description: "description");
    }

    debugPrint(dataMap['amy']?.imageUrl.length.toString());
    debugPrint(dataMap['rowan']?.imageUrl.length.toString());

    return dataMap;
  }
}
