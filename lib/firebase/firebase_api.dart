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

  Future<Map<String, MasterPiece>>? createMasterPieceInfo(String userId) async {
    // Display Image URL Map
    Map<String, List<String>> imageUrlMap = HashMap();

    // Backgronud removed Image URL Map
    Map<String, List<String>> removeImageUrlMap = HashMap();

    // MasterPiece Model Map
    Map<String, MasterPiece> dataMap = HashMap();

    DatabaseReference userInfo = database.ref('users');

    /* TODO : Set time-out */
    DatabaseEvent event = await userInfo.once();

    ListResult results = await storageRef.listAll();

    for (final child in event.snapshot.children) {
      var key = child.key;

      if (key == userId) {
        for (var element in child.children) {
          var data = element.value as Map;

          var id = data['id'];
          var url = data['url'];
          var desc = data['description'];
          var idx = data['idx'];

          for (var element in results.items) {
            if (element.name.contains(id)) {
              debugPrint(element.name);
              String imageUrl = await instance.storageRef
                  .child(element.name)
                  .getDownloadURL();
              if (imageUrlMap[id] == null) {
                imageUrlMap[id] = [];
              }

              if (removeImageUrlMap[id] == null) {
                removeImageUrlMap[id] = [];
              }

              if (!element.name.split('_').last.contains('r')) {
                imageUrlMap[id]?.add(imageUrl);
              } else {
                removeImageUrlMap[id]?.add(imageUrl);
              }
            }
          }

          dataMap[id] = MasterPiece(
              idx: idx,
              imageUrl: imageUrlMap[id]!,
              removedImageUrl: removeImageUrlMap[id],
              description: desc,
              url: url);
        }
      } else {
        debugPrint('$userId has no database');
      }
    }
    return dataMap;
  }
}
