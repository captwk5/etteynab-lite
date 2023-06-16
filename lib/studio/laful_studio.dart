import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/studio/ar_studio_android.dart';
import 'package:the_banyette/studio/ar_studio_ios.dart';
import 'package:the_banyette/view/setting_home.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class LaFulStudio extends StatefulWidget {
  LaFulStudio({super.key, required this.userName, required this.dataMap});

  final String userName;

  List<MasterPiece> removedBgDatas = [];
  List<MasterPiece> pageDatas = [];
  int? pageCnt;
  int? selectedSubItemIdx;

  bool arFlag = false;
  bool noDataFlag = false;
  int? removeIdx;

  PageController pageController = PageController(initialPage: 0);

  // int selectedNavTapIdx = 1;

  final Future<Map<String, MasterPiece>>? dataMap;

  @override
  State<LaFulStudio> createState() => LaFulStudioProducts();
}

class LaFulStudioProducts extends State<LaFulStudio> {
  void removeCallbackStatus() {
    setState(() {
      int currentPage = widget.pageController.page!.toInt();
      var selectedIdx = widget.pageDatas[currentPage].selectedItemIndex;
      var selectedImageNum = widget.pageDatas[currentPage].imageUrl[selectedIdx]
          .split('.jpeg')[0]
          .split('_')[1];
      debugPrint("selectedIdx : $selectedIdx");
      debugPrint("selectedImageNum : $selectedImageNum");
      var i = 0;
      for (final imageName in widget.pageDatas[currentPage].removedImageUrl!) {
        var selectedRemovedImageNum = imageName.split('.png')[0].split('_')[1];
        //   debugPrint("removeImageSize : $selectedRemovedImageNum");
        if (selectedImageNum == selectedRemovedImageNum) {
          debugPrint("-->removeImageSize : $selectedRemovedImageNum");
          widget.arFlag = true;
          widget.removeIdx = i;
          break;
        } else {
          widget.arFlag = false;
          widget.removeIdx = null;
        }
        i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).cardColor,
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          FutureBuilder(
            future: widget.dataMap,
            builder: (builder, snapshot) {
              if (snapshot.hasData) {
                int? dataLen = snapshot.data?.length;

                if (dataLen == 0) {
                  widget.noDataFlag = true;
                  return Flexible(
                    fit: FlexFit.tight,
                    child: Center(
                      child: Text(
                          "There is no products of [${widget.userName}].\nPlease check artist name."),
                    ),
                  );
                } else {
                  widget.noDataFlag = false;
                  widget.pageDatas.clear();
                  widget.removedBgDatas.clear();

                  var keyArr = snapshot.data?.keys;
                  if (keyArr != null) {
                    for (var key in keyArr) {
                      if (snapshot.data?[key] != null) {
                        widget.pageDatas.add(snapshot.data![key]!);
                      }
                    }

                    widget.pageCnt = keyArr.length;

                    widget.pageDatas.sort((a, b) => a.idx!.compareTo(b.idx!));
                  }

                  return Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: widget.pageController,
                        itemCount: widget.pageCnt,
                        itemBuilder: (context, index) {
                          var ret = widget.pageDatas[index];
                          ret.removeCallback = removeCallbackStatus;
                          return ret;
                        },
                      ),
                    ),
                  );
                }
              } else {
                return const Flexible(
                  fit: FlexFit.tight,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          widget.arFlag
              ? const Text(
                  "ARStudio로 이동해보세요",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                )
              : const Text(""),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey, width: 1.0)), // 라인효과
            ),
          ),
          const SizedBox(
            height: 5,
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
            // currentIndex: widget.selectedNavTapIdx,
            onTap: navigateBottomTap,
            selectedItemColor: Theme.of(context).cardColor,
            unselectedItemColor: Theme.of(context).cardColor,
            backgroundColor: Theme.of(context).shadowColor,
          ),
        ],
      ),
    );
  }

  void navigateBottomTap(int idx) async {
    setState(() {
      switch (idx) {
        case 0:
          {
            // widget.selectedNavTapIdx = idx;
            if (!widget.noDataFlag) {
              int currentPage = widget.pageController.page!.toInt();
              launchURLBrowser(widget.pageDatas[currentPage].url);
            }
            break;
          }
        case 1:
          {
            // widget.selectedNavTapIdx = idx;
            if (Platform.isIOS) {
              if (widget.arFlag && widget.removeIdx != null) {
                int currentPage = widget.pageController.page!.toInt();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaneDetectionPage(
                      imageUrl: widget.pageDatas[currentPage]
                          .removedImageUrl![widget.removeIdx!],
                    ),
                  ),
                );
              }
            } else if (Platform.isAndroid) {
              if (widget.arFlag && widget.removeIdx != null) {
                int currentPage = widget.pageController.page!.toInt();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HelloWorld(
                      imageUrl: widget.pageDatas[currentPage]
                          .removedImageUrl![widget.removeIdx!],
                    ),
                  ),
                );
              }
            } else {}
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
}
