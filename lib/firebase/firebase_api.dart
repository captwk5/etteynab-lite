import 'package:firebase_core/firebase_core.dart';
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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    storageRef = FirebaseStorage.instance.ref();
    isInitialized = true;
  }

  Future<List<MasterPiece>> getImageList() async {
    ListResult results = await storageRef.listAll();
    List<MasterPiece> imageList = [];

    for (var element in results.items) {
      String imageUrl =
          await instance.storageRef.child(element.name).getDownloadURL();
      imageList.add(MasterPiece(
        image: Image.network(imageUrl),
        title: element.name,
        price: "10000",
      ));
    }

    return imageList;
  }
}
