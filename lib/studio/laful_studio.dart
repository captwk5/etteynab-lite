import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/view/setting_home.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ar_studio_ios.dart';

class LaFulStudio extends StatefulWidget {
  const LaFulStudio({super.key, required this.userName});

  final String userName;

  @override
  State<LaFulStudio> createState() => LaFulStudioProducts();
}

class LaFulStudioProducts extends State<LaFulStudio> {
  Future<Map<String, MasterPiece>>? dataMap;
  List<MasterPiece> removedBgDatas = [];
  List<MasterPiece> pageDatas = [];
  int? pageCnt;

  PageController pageController = PageController(initialPage: 0);

  int selectedNavTapIdx = 1;

  // CameraDescription? _camera;

  // Future<CameraDescription> getCamera() async {
  //   // Obtain a list of the available cameras on the device.
  //   final cameras = await availableCameras();

  //   debugPrint("$cameras");

  //   // Get a specific camera from the list of available cameras.
  //   return cameras.first;
  // }

  @override
  Widget build(BuildContext context) {
    dataMap =
        FirebaseApiService.instance.createMasterPieceInfo(widget.userName);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).cardColor,
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // const SizedBox(
          //   height: 20,
          // ),
          FutureBuilder(
            future: dataMap,
            builder: (builder, snapshot) {
              if (snapshot.hasData) {
                pageDatas.clear();
                removedBgDatas.clear();

                var keyArr = snapshot.data?.keys;
                if (keyArr != null) {
                  for (var key in keyArr) {
                    if (snapshot.data?[key] != null) {
                      pageDatas.add(snapshot.data![key]!);
                    }
                  }

                  pageCnt = keyArr.length;

                  pageDatas.sort((a, b) => a.idx!.compareTo(b.idx!));
                }

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
          const SizedBox(
            height: 10,
          ),
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                label: "Store",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_camera_back_outlined),
                label: "ARStudio",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Setting",
              ),
            ],
            currentIndex: selectedNavTapIdx,
            onTap: navigateBottomTap,
          ),
        ],
      ),
    );
  }

  void navigateBottomTap(int idx) {
    setState(() {
      selectedNavTapIdx = idx;
      int currentPage = pageController.page!.toInt();

      switch (selectedNavTapIdx) {
        case 0:
          {
            launchURLBrowser(pageDatas[currentPage].url);
            break;
          }
        case 1:
          {
            if (Platform.isIOS) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaneDetectionPage(
                    imageUrl: pageDatas[currentPage].removedImageUrl!.first,
                  ),
                ),
              );
            } else if (Platform.isAndroid) {
            } else {}
            debugPrint(pageDatas[currentPage].removedImageUrl!.first);
            break;
          }
        case 2:
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingHome(),
              ),
            );
            break;
          }
      }
    });
  }

  Future<void> launchURLBrowser(String? storeUrl) async {
    if (storeUrl != null) {
      Uri url = Uri.parse(storeUrl);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  // void getBackgroundImg(CameraDescription value) async {
  //   String backgroundImgPath = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => CameraHome(camera: value),
  //     ),
  //   );

  //   setState(() {
  //     this.backgroundImgPath = backgroundImgPath;
  //   });
  // }

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

  // Future<void> _askedToLead() async {
  //   switch (await showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SimpleDialog(
  //         title: const Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text("이미지 가져오기"),
  //           ],
  //         ),
  //         children: <Widget>[
  //           SimpleDialogOption(
  //             child: IconButton(
  //               onPressed: () {
  //                 getCamera().then((value) => getBackgroundImg(value));
  //               },
  //               icon: const Icon(Icons.camera_alt_outlined),
  //             ),
  //           ),
  //           SimpleDialogOption(
  //             child: IconButton(
  //               onPressed: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => const AlbumHome(),
  //                     fullscreenDialog: true,
  //                   ),
  //                 );
  //               },
  //               icon: const Icon(Icons.photo_album_outlined),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   )) {
  //     case "Department.treasury":
  //       break;
  //     case "Department.state":
  //       break;
  //     case null:
  //       // dialog dismissed
  //       break;
  //   }
  // }
}
