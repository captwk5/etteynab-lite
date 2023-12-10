import 'dart:collection';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> reportMessage(String message) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("report");

    String systemTime = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint(systemTime + message);
    await ref.update({
      systemTime: message,
    }).whenComplete(() => debugPrint("report complete"));
  }

  Future<Map<String, MasterPiece>>? createMasterPieceInfo(String userId) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

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

    // prefs.clear();

    for (final child in event.snapshot.children) {
      for (var element in child.children) {
        if (element.key == "same_name") {
          List<dynamic> nameList = element.value as List;
          for (var id in nameList) {
            if (id == userId) {
              if (child.key != null) {
                // debugPrint("rowan $id ${child.key}");
                userId = child.key!;
                break;
              }
            }
          }
          // debugPrint("rowan ${element.value as List} ${nameList}");
        }
      }
    }

    for (final child in event.snapshot.children) {
      var key = child.key; // userId

      // debugPrint("rowanDebug key : $key");
      List<String> prefList = [];
      if (key == userId) {
        for (var element in child.children) {
          if (element.key == "same_name") continue; // product name

          var data = element.value as Map;

          var id = data['id'];
          var url = data['url'];
          var desc = data['description'];
          var idx = data['idx'];
          var width = data['width']; // cm
          var height = data['height']; // cm

          if (!prefs.containsKey(userId + id)) {
            for (var element in results.items) {
              if (element.name.contains(id)) {
                String imageUrl = await instance.storageRef
                    .child(element.name)
                    .getDownloadURL();
                debugPrint("id is added : ${element.name} $imageUrl");
                prefList.add("${element.name},$imageUrl");

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
            prefs.setStringList(userId + id, prefList);
          } else {
            debugPrint("$id list : ${prefs.getStringList(userId + id)}");
            prefs.getStringList(userId + id)?.forEach((url) {
              var imageId = url.split(',').first;
              bool checkFlag = false;
              for (var element in results.items) {
                if (imageId == element.name) {
                  checkFlag = true;
                  // debugPrint("rowanDebug ${imageId} is checked!");
                  break;
                }
              }
              if (checkFlag) {
                var imageUrl = url.split(',').last;

                debugPrint("$imageId is exist $imageUrl");
                if (imageId.contains(id)) {
                  if (imageUrlMap[id] == null) {
                    imageUrlMap[id] = [];
                  }

                  if (removeImageUrlMap[id] == null) {
                    removeImageUrlMap[id] = [];
                  }

                  if (!imageId.split('_').last.contains('r')) {
                    imageUrlMap[id]?.add(imageUrl);
                  } else {
                    removeImageUrlMap[id]?.add(imageUrl);
                  }
                }
              } else {
                debugPrint("$imageId is gone");
                List<String> prefList = prefs.getStringList(userId + id)!;
                List<int> removeIdx = [];
                int idx = 0;
                for (var element in prefList) {
                  if (element.contains(imageId)) removeIdx.add(idx);
                  idx++;
                }
                for (var element in removeIdx.reversed) {
                  prefList.removeAt(element);
                }
                prefs.setStringList(userId + id, prefList);
              }
            });

            for (var element in results.items) {
              if (element.name.contains(id)) {
                bool checkFlag = false;
                prefs.getStringList(userId + id)?.forEach((url) {
                  var imageId = url.split(',').first;
                  if (element.name == imageId) {
                    checkFlag = true;
                  }
                });

                if (!checkFlag) {
                  String imageUrl = await instance.storageRef
                      .child(element.name)
                      .getDownloadURL();
                  debugPrint(
                      "$id is second added : ${element.name} $imageUrl ${prefs.getStringList(userId + id)}");
                  List<String> prefList = prefs.getStringList(userId + id)!;
                  prefList.add("${element.name},$imageUrl");
                  prefs.setStringList(userId + id, prefList);

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
            }
          }

          dataMap[id] = MasterPiece(
            idx: idx,
            imageUrl: imageUrlMap[id]!,
            removedImageUrl: removeImageUrlMap[id],
            description: desc,
            url: url,
            width: width,
            height: height,
            title: element.key,
          );
        }
      } else {
        debugPrint('$key has no database');
      }
    }
    return dataMap;
  }

  Future<Map<String, MasterPiece>>? getRandomMasterPieceInfo() async {
    Map<String, MasterPiece> dataMap = HashMap();

    // Display Image URL Map
    Map<String, List<String>> imageUrlMap = HashMap();

    // Backgronud removed Image URL Map
    Map<String, List<String>> removeImageUrlMap = HashMap();

    DatabaseReference userInfo = database.ref('users');

    DatabaseEvent event = await userInfo.once();

    ListResult results = await storageRef.listAll();

    var randomIdx1 = Random()
        .nextInt(event.snapshot.children.length); // Value is >= 0 and < 10.
    var checkIdx1 = 0;
    for (final child in event.snapshot.children) {
      if (checkIdx1 == randomIdx1) {
        var key = child.key;
        var randomIdx2 = Random()
            .nextInt(child.children.length - 1); // Value is >= 0 and < 10.
        int checkIdx2 = 0;
        for (var element in child.children) {
          if (element.key == "same_name") continue;
          if (checkIdx2 == randomIdx2) {
            var data = element.value as Map;

            var id = data['id'];
            var url = data['url'];
            var desc = data['description'];
            var idx = data['idx'];
            var width = data['width']; // cm
            var height = data['height']; // cm

            for (var element in results.items) {
              if (element.name.contains(id) && !element.name.contains("_r")) {
                String imageUrl = await instance.storageRef
                    .child(element.name)
                    .getDownloadURL();

                imageUrlMap[id] = [];
                removeImageUrlMap[id] = [];
                imageUrlMap[id]?.add(imageUrl);
                removeImageUrlMap[id]?.add(imageUrl);

                dataMap[id] = MasterPiece(
                  idx: idx,
                  imageUrl: imageUrlMap[id]!,
                  removedImageUrl: removeImageUrlMap[id],
                  description: desc,
                  url: url,
                  width: width,
                  height: height,
                  title: key,
                );
                break;
              }
            }
          }
          checkIdx2++;
        }
        break;
      }
      checkIdx1++;
    }

    return dataMap;
  }

  Future<List<String>>? getNextIdList(String exceptId) async {
    Map<String, MasterPiece> dataMap = HashMap();

    // Display Image URL Map
    Map<String, List<String>> imageUrlMap = HashMap();

    // Backgronud removed Image URL Map
    Map<String, List<String>> removeImageUrlMap = HashMap();

    DatabaseReference userInfo = database.ref('users');

    DatabaseEvent event = await userInfo.once();

    // ListResult results = await storageRef.listAll();

    List<String> idList = [];

    for (final child in event.snapshot.children) {
      if (child.key != null && child.key != exceptId) {
        bool flag = true;
        for (var element in child.children) {
          if (element.key == "same_name") {
            List<dynamic> nameList = element.value as List;
            for (var id in nameList) {
              if (id == exceptId) {
                if (child.key != null) {
                  flag = false;
                }
              }
            }
          }
        }
        if (flag) idList.add(child.key!);
      }
    }

    return idList;
  }
}
