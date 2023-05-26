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
  late FirebaseDatabase database;
  bool isInitialized = false;

  static final FirebaseApiService instance =
      FirebaseApiService.privateConstructor();

  factory FirebaseApiService() {
    return instance;
  }

  Future<void> initialization() async {
    await Firebase.initializeApp();
    database = FirebaseDatabase.instance;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    storageRef = FirebaseStorage.instance.ref();
    isInitialized = true;
  }

  Future<Map<String, MasterPiece>> getImageList() async {
    // Display Image URL Map
    Map<String, List<String>> imageUrlMap = HashMap();

    // Backgronud removed Image URL Map
    Map<String, List<String>> removeImageUrlMap = HashMap();

    // MasterPiece Model Map
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
      dataMap[key] =
          MasterPiece(imageUrl: imageUrlMap[key]!, title: "", price: "price");
    }

    debugPrint(dataMap['amy']?.imageUrl.length.toString());
    debugPrint(dataMap['rowan']?.imageUrl.length.toString());

    DatabaseReference userInfo = database.ref('users');
    userInfo.onValue.listen((DatabaseEvent event) {
      for (final child in event.snapshot.children) {
        var key = child.key;
        if (key != null) {
          if (key.contains("amy")) {
            for (final child2 in child.children) {
              var secondKey = child2.key!;
              debugPrint(secondKey);
              if (secondKey == "description") {
                String desc = child2
                    .child(secondKey)
                    .value
                    .toString()
                    .replaceAll("^", "\n");
                debugPrint(desc);
                dataMap[key]?.description = desc;
              }
            }
          }
        }
      }
    });

    return dataMap;
  }
}
