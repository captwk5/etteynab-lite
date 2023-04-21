import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/view/background_simulation.dart';

import '../view/camera_home.dart';

class LaFulStudio extends StatefulWidget {
  const LaFulStudio({super.key});

  @override
  State<LaFulStudio> createState() => LaFulStudioProducts();
}

class LaFulStudioProducts extends State<LaFulStudio> {
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
                return Expanded(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // launchBackgroundSimulation(pageController.page!.toInt());

                  getCamera().then((value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TakePictureScreen(camera: value),
                        ),
                      ));
                },
                label: const Text(
                  "배경화면 촬영하고 상품 올려보기",
                  style: TextStyle(color: Color.fromARGB(255, 60, 113, 62)),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void launchBackgroundSimulation(int pageIdx) {
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
          ),
        ),
      );
    } else {
      debugPrint("No");
    }
  }
}