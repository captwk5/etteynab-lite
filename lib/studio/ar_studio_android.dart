import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'dart:math' as math;

class ARStudioAndroid extends StatefulWidget {
  const ARStudioAndroid({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  final String imageUrl;
  final int? width;
  final int? height;

  @override
  // ignore: library_private_types_in_public_api
  _PlaneDetectionState createState() => _PlaneDetectionState();
}

class _PlaneDetectionState extends State<ARStudioAndroid> {
  late ArCoreController arCoreController;
  bool planeToggle = true;
  ArCoreNode? nodeFlower;
  String noticeTxt1 = "화면을 터치하여 상품이 나타나면 위치를 조절해보세요.";
  var txtColor = Colors.white;

  math.Vector3? currentCoord;
  List<double>? currentAngle;

  bool detectedFlag = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
    debugPrint("rowan:dispose!!");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'ARStudio',
            style: TextStyle(color: Theme.of(context).cardColor),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 50,
          backgroundColor: Theme.of(context).shadowColor,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            ArCoreView(
              enableTapRecognizer: true,
              enableUpdateListener: true,
              enablePlaneRenderer: planeToggle,
              onArCoreViewCreated: _onArCoreViewCreated,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Text(
                        noticeTxt1,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: txtColor, fontSize: 17),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (detectedFlag) {
                          currentCoord!.y += 0.025;
                        }
                      },
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_upward_outlined,
                        size: 35,
                      ),
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        if (detectedFlag) {
                          currentCoord!.y -= 0.025;
                        }
                      },
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_downward_outlined,
                        size: 35,
                      ),
                      color: Colors.white,
                    )
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (detectedFlag) {
                              var slopeAngle =
                                  (90 + -currentAngle![1] * 180 / 3.14) *
                                      math.pi /
                                      180.0;
                              var a = -1 / math.tan(slopeAngle);
                              var x = currentCoord!.x;
                              var y = -currentCoord!.z;
                              var b = y - a * x;
                              // y = a x + b
                              // x = (y - b) / a
                              currentCoord!.x -= 0.05;
                              currentCoord!.z = -(a * currentCoord!.x + b);
                            }
                          },
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_circle_left_outlined,
                            size: 35,
                          ),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {
                            if (detectedFlag) {
                              var slopeAngle =
                                  (90 + -currentAngle![1] * 180 / 3.14) *
                                      math.pi /
                                      180.0;
                              var a = math.tan(slopeAngle);
                              var x = currentCoord!.x;
                              var y = -currentCoord!.z;
                              var b = y - a * x;
                              // y = a x + b
                              // x = (y - b) / a
                              currentCoord!.z -= 0.05;
                              currentCoord!.x = (-currentCoord!.z - b) / a;
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_circle_up_outlined,
                            size: 35,
                          ),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {
                            if (detectedFlag) {
                              var slopeAngle =
                                  (90 + -currentAngle![1] * 180 / 3.14) *
                                      math.pi /
                                      180.0;
                              var a = math.tan(slopeAngle);
                              var x = currentCoord!.x;
                              var y = -currentCoord!.z;
                              var b = y - a * x;
                              // y = a x + b
                              // x = (y - b) / a
                              currentCoord!.z += 0.05;
                              currentCoord!.x = (-currentCoord!.z - b) / a;
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_circle_down_outlined,
                            size: 35,
                          ),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {
                            if (detectedFlag) {
                              var slopeAngle =
                                  (90 + -currentAngle![1] * 180 / 3.14) *
                                      math.pi /
                                      180.0;
                              var a = -1 / math.tan(slopeAngle);
                              var x = currentCoord!.x;
                              var y = -currentCoord!.z;
                              var b = y - a * x;
                              // y = a x + b
                              // x = (y - b) / a
                              currentCoord!.x += 0.05;
                              currentCoord!.z = -(a * currentCoord!.x + b);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_circle_right_outlined,
                            size: 35,
                          ),
                          color: Colors.white,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        refresh();
                      },
                      child: const Text(
                        "ARStudio 재시작",
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void refresh() {
    // if (detectedFlag) arCoreController.removeNode(nodeName: "flower");
    // detectedFlag = false;
    // planeToggle = true;
    // arCoreController.togglePlaneRenderer();

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARStudioAndroid(
          imageUrl:
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = (hits) => onPlaneTap(hits);
    arCoreController.onPlaneDetected = (plane) => onPlaneDetected(plane);
  }

  bool test = false;
  void onPlaneDetected(ArCorePlane p) async {
    if(!test){
      Fluttertoast.showToast(
          msg: "평면.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 10.0);
      test = true;
    }
    if (detectedFlag) {
      await arCoreController.getCameraPose().then((value) => rotate(value));
    }
  }

  void rotate(dynamic value) {
    var rot = value["rotation"];
    var origin = nodeFlower?.rotation?.value;
    nodeFlower?.rotation?.value =
        math.Vector4(origin!.x, -rot[1], origin.z, origin.w);

    arCoreController.handleRotationChanged(nodeFlower!);
    currentAngle = rot;

    if (currentCoord != null) {
      nodeFlower?.position?.value =
          math.Vector3(currentCoord!.x, currentCoord!.y, currentCoord!.z);
      arCoreController.handlePositionChanged(nodeFlower!);
    }
  }

  void onPlaneTap(List<ArCoreHitTestResult> hit) async {
    try {
      if (hit.isNotEmpty) {
        if (!detectedFlag) {
          detectedFlag = true;
          planeToggle = false;
          arCoreController.togglePlaneRenderer();
          Fluttertoast.showToast(
              msg: "Detected!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              // backgroundColor: Colors.red,
              // textColor: Colors.white,
              fontSize: 10.0);

          var detectedPose = hit.first.pose.translation;
          var detectedRot = hit.first.pose.rotation;
          currentCoord = detectedPose;
          Uint8List bytes =
              (await NetworkAssetBundle(Uri.parse(widget.imageUrl))
                      .load(widget.imageUrl))
                  .buffer
                  .asUint8List();

          nodeFlower = ArCoreNode(
              image: ArCoreImage(
                  bytes: bytes,
                  width: (widget.width! * 10.0).toInt(),
                  height: (widget.height! * 10.0).toInt()),
              position: detectedPose + math.Vector3(0.0, 0.0, 0.0),
              rotation: detectedRot + math.Vector4(0.0, 0.0, 0.0, 0.0),
              scale: math.Vector3(0.5, 0.5, 0.5),
              name: "flower");

          arCoreController.addArCoreNode(nodeFlower!);
        }
      } else {
        Fluttertoast.showToast(
            msg: "다시 터치해 주세요.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            // backgroundColor: Colors.red,
            // textColor: Colors.white,
            fontSize: 10.0);
      }
    } catch (e) {
      debugPrint("rowan Something wrong! ${e.toString()}");
    }
  }
}
