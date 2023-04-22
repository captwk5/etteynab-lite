import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/view/background_simulation.dart';

import '../view/camera_home.dart';

class LaFulStudio extends StatefulWidget {
  const LaFulStudio({super.key, this.backgroundImgPath});

  final String? backgroundImgPath;

  @override
  State<LaFulStudio> createState() => LaFulStudioProducts();
}

class LaFulStudioProducts extends State<LaFulStudio> {
  String? backgroundImgPath;

  Future<List<MasterPiece>> imageList =
      FirebaseApiService.instance.getImageList();
  List<MasterPiece> removedBgDatas = [];
  List<MasterPiece> pageDatas = [];

  PageController pageController = PageController(initialPage: 0);

  CameraDescription? _camera;

  Future<CameraDescription> getCamera() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    debugPrint("$cameras");

    // Get a specific camera from the list of available cameras.
    return cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_outlined),
              ),
            ],
          ),
          FutureBuilder(
            future: imageList,
            builder: (builder, snapshot) {
              if (snapshot.hasData) {
                pageDatas.clear();
                removedBgDatas.clear();
                for (var element in snapshot.data!) {
                  if (!element.title.contains("removebg")) {
                    pageDatas.add(element);
                  } else {
                    removedBgDatas.add(element);
                  }
                }
                return SizedBox(
                  height: 450,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: pageController,
                    children: pageDatas,
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          Container(
              child: backgroundImgPath == null
                  ? const Text("There is no background")
                  : Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: Image.file(File(backgroundImgPath!)).image,
                          fit: BoxFit.cover,
                        ),
                      ))),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  getCamera().then((value) => getBackgroundImg(value));
                },
                label: const Text(
                  "배경화면 촬영",
                  style: TextStyle(color: Color.fromARGB(255, 60, 113, 62)),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  if (backgroundImgPath == null) {
                    Fluttertoast.showToast(
                        msg: "상품을 올려놓을\n배경화면을 촬영해 보세요.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    launchBackgroundSimulation(
                      pageController.page!.toInt(),
                      Image.file(File(backgroundImgPath!)),
                    );
                  }
                },
                label: const Text("배경화면에 올려보기"),
                icon: const Icon(Icons.arrow_circle_down_outlined),
              )
            ],
          ),
        ],
      ),
    );
  }

  void getBackgroundImg(CameraDescription value) async {
    String backgroundImgPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TakePictureScreen(camera: value),
      ),
    );

    setState(() {
      this.backgroundImgPath = backgroundImgPath;
    });
  }

  void launchBackgroundSimulation(int pageIdx, Image background) {
    MasterPiece? selectedMP;
    if (pageController.page != null) {
      String selectedTitle = pageDatas[pageIdx].title.split('.')[0];

      for (var element in removedBgDatas) {
        if (element.title.split('_')[0] == selectedTitle) {
          debugPrint(selectedTitle);
          selectedMP = element;
          break;
        }
      }
    }

    if (selectedMP != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BackgroundSimulation(
            image: selectedMP!.image,
            background: background,
          ),
        ),
      );
    }
  }
}
