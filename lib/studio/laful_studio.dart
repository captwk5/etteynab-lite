import 'package:flutter/material.dart';
import 'package:the_banyette/model/masterpiece.dart';
import 'package:the_banyette/studio/ar_studio.dart';
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
  String? currentDescription = "";

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

  void refreshDescription(String desc) {
    Future.delayed(Duration.zero, () {
      setState(() {
        currentDescription = desc;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   refreshDescription();
    // });
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
                    fit: FlexFit.tight,
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: widget.pageController,
                      itemCount: widget.pageCnt,
                      itemBuilder: (context, index) {
                        var ret = widget.pageDatas[index];

                        ret.removeCallback = removeCallbackStatus;
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
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          Container(
            color: Colors.amber,
            height: MediaQuery.of(context).size.height * 0.31,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                "$currentDescription\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15",
              ),
            ),
          ),
          const SizedBox(
            height: 15,
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
            if (widget.arFlag && widget.removeIdx != null) {
              int currentPage = widget.pageController.page!.toInt();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ObjectsOnPlanesWidget(
                    imageUrl: widget.pageDatas[currentPage]
                        .removedImageUrl![widget.removeIdx!],
                  ),
                ),
              );
            }
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
