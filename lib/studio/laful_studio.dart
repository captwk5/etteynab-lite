import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/view/album_home.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view/camera_home.dart';

class LaFulStudio extends StatefulWidget {
  const LaFulStudio({super.key, this.backgroundImgPath});

  final String? backgroundImgPath;

  @override
  State<LaFulStudio> createState() => LaFulStudioProducts();
}

class LaFulStudioProducts extends State<LaFulStudio> {
  String? backgroundImgPath;

  Future<Map<String, MasterPiece>> dataMap =
      FirebaseApiService.instance.getImageList();
  List<MasterPiece> removedBgDatas = [];
  List<MasterPiece> pageDatas = [];
  int? pageCnt;

  PageController pageController = PageController(initialPage: 0);

  // CameraDescription? _camera;

  Future<CameraDescription> getCamera() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    debugPrint("$cameras");

    // Get a specific camera from the list of available cameras.
    return cameras.first;
  }

  void renewMainPicture(int selectedIndex) async {
    debugPrint("gogo $selectedIndex");
    // setState(() {
    // pageController.jumpToPage(selectedIndex);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).cardColor,
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          FutureBuilder(
            future: dataMap,
            builder: (builder, snapshot) {
              if (snapshot.hasData) {
                pageDatas.clear();
                removedBgDatas.clear();
                pageCnt = snapshot.data?.keys.length;

                for (var key in snapshot.data!.keys) {
                  if (snapshot.data?[key] != null) {
                    pageDatas.add(snapshot.data![key]!);
                  }
                }

                debugPrint("total page : $pageCnt");
                return Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: SizedBox(
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      itemCount: pageCnt,
                      itemBuilder: (context, index) {
                        return pageDatas[index];
                      },
                    ),
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          OutlinedButton.icon(
            onPressed: () {
              // getCamera().then((value) => getBackgroundImg(value));
              _askedToLead();
            },
            label: Text(
              "시뮬레이션",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: launchURLBrowser,
            label: Text(
              "스토어링크",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  void getBackgroundImg(CameraDescription value) async {
    String backgroundImgPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraHome(camera: value),
      ),
    );

    setState(() {
      this.backgroundImgPath = backgroundImgPath;
    });
  }

  // void launchBackgroundSimulation(int pageIdx, Image background) {
  //   MasterPiece? selectedMP;
  //   if (pageController.page != null) {
  //     String selectedTitle = pageDatas[pageIdx].title.split('.')[0];

  //     for (var element in removedBgDatas) {
  //       if (element.title.split('_')[0] == selectedTitle) {
  //         debugPrint(selectedTitle);
  //         selectedMP = element;
  //         break;
  //       }
  //     }
  //   }

  //   if (selectedMP != null) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => BackgroundSimulation(
  //           image: selectedMP!.image,
  //           background: background,
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<void> launchURLBrowser() async {
    Uri url = Uri.parse('https://ohou.se/productions/1247067/selling');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _askedToLead() async {
    switch (await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("이미지 가져오기"),
            ],
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: IconButton(
                onPressed: () {
                  getCamera().then((value) => getBackgroundImg(value));
                },
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ),
            SimpleDialogOption(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AlbumHome(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: const Icon(Icons.photo_album_outlined),
              ),
            ),
          ],
        );
      },
    )) {
      case "Department.treasury":
        break;
      case "Department.state":
        break;
      case null:
        // dialog dismissed
        break;
    }
  }
}
