import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/view/studio/ar_studio_android.dart';
import 'package:the_banyette/view/studio/ar_studio_ios.dart';
import 'package:the_banyette/view/home/setting_home.dart';

// ignore: must_be_immutable
class EtteynabArStudio extends StatefulWidget {
  EtteynabArStudio({
    super.key,
    required this.userName,
    required this.dataMap,
    required this.noDataMap,
  });

  String userName;

  List<MasterPiece> pageDatas = [];
  int? pageCnt;
  int? selectedSubItemIdx;

  bool noDataFlag = false;

  PageController pageController = PageController(initialPage: 0);

  Future<Map<String, MasterPiece>>? dataMap;

  Future<Map<String, MasterPiece>>? noDataMap;

  @override
  State<EtteynabArStudio> createState() => EtteynabArStudioProducts();
}

class EtteynabArStudioProducts extends State<EtteynabArStudio> {
  String currentDescription = "";
  Future<bool>? moveSimilarItem;
  int nextCnt = 0;

  void refreshDescription(String desc) {
    Future.delayed(Duration.zero, () {
      setState(() {
        // debugPrint("$desc");
        var descList = desc.split(",");
        currentDescription = "\n"
            "- 상품명 : ${descList.first}"
            "\n"
            "\n"
            "- 높이 : ${descList[1]}cm"
            "\n"
            "\n"
            "- 넓이 : ${descList[2]}cm"
            "\n"
            "\n"
            "- 설명 : ${descList.last}";
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
          "\"${widget.userName}\"님의 상품",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.search),
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
                            Text("\"${widget.userName}\"님 상품이 없습니다."),
                            const Text("판매자 이름을 확인하세요."),
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
                                            "\"${masterPiece.title!}\"님의 상품은 어떤 가요?"),
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
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).cardColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: SingleChildScrollView(
                      // padding: EdgeInsets.all(15.0),
                      scrollDirection: Axis.vertical,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text(
                              "\n< 제품 스펙 >",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              currentDescription,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        SizedBox.fromSize(
                          size: const Size(60, 60), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Colors.green, // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  navigateBottomTap(1);
                                }, // button pressed
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.video_camera_back_outlined,
                                      color: Colors.white,
                                    ),
                                    // icon
                                    Text(
                                      "AR",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
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
                          size: const Size(60, 60), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Colors.green, // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  navigateBottomTap(2);
                                }, // button pressed
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.next_plan_outlined,
                                      color: Colors.white,
                                    ),
                                    // icon
                                    Text(
                                      "Other",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
    setState(() {
      widget.userName = id;
      widget.dataMap = FirebaseApiService.instance.createMasterPieceInfo(id);
      widget.noDataMap = FirebaseApiService.instance.getRandomMasterPieceInfo();
    });
  }

  void navigateBottomTap(int idx) async {
    setState(() {
      switch (idx) {
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
          var idList =
              FirebaseApiService.instance.getNextIdList(widget.userName);
          idList
              ?.then((value) => refresh(value[Random().nextInt(value.length)]));
          break;
      }
    });
  }
}
