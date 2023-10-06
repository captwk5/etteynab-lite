import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/studio/ar_studio_android.dart';
import 'package:the_banyette/studio/ar_studio_ios.dart';
import 'package:the_banyette/view/setting_home.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class LaFulStudio extends StatefulWidget {
  LaFulStudio({
    super.key,
    required this.userName,
    required this.dataMap,
    this.noDataMap,
  });

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

  Future<Map<String, MasterPiece>>? dataMap;

  Future<Map<String, MasterPiece>>? noDataMap;

  @override
  State<LaFulStudio> createState() => LaFulStudioProducts();
}

class LaFulStudioProducts extends State<LaFulStudio> {
  String currentDescription = "";
  Future<bool>? moveSimilarItem;

  void removeCallbackStatus() {
    // setState(() {
    // int currentPage = widget.pageController.page!.toInt();
    // var selectedIdx = widget.pageDatas[currentPage].selectedItemIndex;
    // var selectedImageNum = widget.pageDatas[currentPage].imageUrl[selectedIdx]
    //     .split('.jpeg')[0]
    //     .split('_')[1];
    // debugPrint("selectedIdx : $selectedIdx");
    // debugPrint("selectedImageNum : $selectedImageNum");
    // });
  }

  void refreshDescription(String desc) {
    Future.delayed(Duration.zero, () {
      setState(() {
        var descList = desc.split(",");
        currentDescription = "\n"
            "- 높이 : ${descList.first}cm"
            "\n"
            "\n"
            "- 넓이 : ${descList.last}cm";
        // currentDescription = desc;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "[${widget.userName}]님의 작품",
          style: TextStyle(
            color: Theme.of(context).cardColor,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingHome(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          )
        ],
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).shadowColor,
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
                  moveSimilarItem = Future.value(true);

                  return Flexible(
                    fit: FlexFit.tight,
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "There is no products of [${widget.userName}].\nPlease check artist name."),
                            const SizedBox(
                              height: 15,
                            ),
                            FutureBuilder(
                                future: widget.noDataMap,
                                builder: (builder, snapshot) {
                                  if (snapshot.hasData) {
                                    var masterPiece = snapshot
                                        .data![snapshot.data!.keys.first];
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: Image.network(
                                                          masterPiece!
                                                              .imageUrl.first)
                                                      .image,
                                                  fit: BoxFit.fill),
                                            ),
                                            width: 100,
                                            height: 100,
                                          ),
                                          onTap: () => {
                                            refresh(masterPiece.title!)
                                            // Navigator.pop(context, masterPiece.title!)
                                          },
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                            "[${masterPiece.title!}]님의 상품은 어떤 가요?"),
                                        const Text("이미지 클릭하고 구경해보세요"),
                                      ],
                                    );
                                  } else {
                                    return const Text("");
                                  }
                                })
                          ]),
                    ),
                  );
                } else {
                  widget.noDataFlag = false;
                  moveSimilarItem = Future.value(false);
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
                    fit: FlexFit.tight,
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: widget.pageController,
                      itemCount: widget.pageCnt,
                      itemBuilder: (context, index) {
                        var ret = widget.pageDatas[index];

                        // ret.removeCallback = removeCallbackStatus;
                        ret.descriptionCallback = refreshDescription;

                        return ret;
                      },
                    ),
                  );
                }
              } else {
                return const Flexible(
                  fit: FlexFit.tight,
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: "Searching...",
                    ),
                  ),
                );
              }
            },
          ),
          widget.pageCnt != null
              ? SmoothPageIndicator(
                  controller: widget.pageController,
                  count: widget.pageCnt!,
                  effect: WormEffect(
                    dotHeight: 9,
                    dotWidth: 9,
                    type: WormType.normal,
                    dotColor: Theme.of(context).shadowColor,
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).cardColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: SingleChildScrollView(
                      // padding: EdgeInsets.all(15.0),
                      scrollDirection: Axis.vertical,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text(
                              "\n< 상세 스펙 >",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontStyle: FontStyle.normal
                              ),
                            ),
                            Text(
                              currentDescription,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox.fromSize(
                        size: const Size(65, 65), // button width and height
                        child: ClipOval(
                          child: Material(
                            color: Colors.greenAccent, // button color
                            child: InkWell(
                              splashColor: Colors.green, // splash color
                              onTap: () {
                                navigateBottomTap(1);
                              }, // button pressed
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.video_camera_back_outlined),
                                  // icon
                                  Text("AR"),
                                  // text
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox.fromSize(
                        size: const Size(65, 65), // button width and height
                        child: ClipOval(
                          child: Material(
                            color: Colors.greenAccent, // button color
                            child: InkWell(
                              splashColor: Colors.green, // splash color
                              onTap: () {
                                navigateBottomTap(2);
                              }, // button pressed
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.search_outlined), // icon
                                  Text("Search"), // text
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // BottomNavigationBar(
          //   items: const <BottomNavigationBarItem>[
          //     // BottomNavigationBarItem(
          //     //   icon: Icon(Icons.shopping_cart_outlined),
          //     //   label: "Store",
          //     // ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.video_camera_back_outlined),
          //       label: "ARStudio",
          //     ),
          //     // BottomNavigationBarItem(
          //     //   icon: Icon(Icons.settings),
          //     //   label: "Setting",
          //     // ),
          //   ],
          //   // currentIndex: widget.selectedNavTapIdx,
          //   onTap: navigateBottomTap,
          //   selectedItemColor: Theme.of(context).cardColor,
          //   unselectedItemColor: Theme.of(context).cardColor,
          //   backgroundColor: Theme.of(context).shadowColor,
          // ),
        ],
      ),
    );
  }

  void refresh(String id) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaFulStudio(
          userName: id,
          dataMap: FirebaseApiService.instance.createMasterPieceInfo(id),
          noDataMap: FirebaseApiService.instance.getRandomMasterPieceInfo(),
        ),
      ),
    );
  }

  void navigateBottomTap(int idx) async {
    setState(() {
      switch (idx) {
        // case 0:
        //   {
        //     if (!widget.noDataFlag) {
        //       int currentPage = widget.pageController.page!.toInt();
        //       launchURLBrowser(widget.pageDatas[currentPage].url);
        //     }
        //     break;
        //   }
        case 1:
          {
            int currentPage = widget.pageController.page!.toInt();
            if (Platform.isAndroid) {
              String path = "";
              for (var element
              in widget.pageDatas[currentPage].removedImageUrl!) {
                if (element.contains("png")) {
                  path = element;
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ARStudioAndroid(
                    imageUrl: path,
                    width: widget.pageDatas[currentPage].width,
                    height: widget.pageDatas[currentPage].height,
                  ),
                ),
              );
            } else if (Platform.isIOS) {
              String path = "";
              for (var element
                  in widget.pageDatas[currentPage].removedImageUrl!) {
                if (element.contains("png")) {
                  path = element;
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ARStudioIos(
                    imageUrl: path,
                    width: widget.pageDatas[currentPage].width,
                    height: widget.pageDatas[currentPage].height,
                  ),
                ),
              );
            }
            break;
          }
        case 2:
          Navigator.pop(context, null);
          break;
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
