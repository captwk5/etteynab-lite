import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'dart:math' as math;

class ARStudioIos extends StatefulWidget {
  const ARStudioIos({
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

class _PlaneDetectionState extends State<ARStudioIos> {
  late ARKitController arkitController;
  bool planeToggle = true;
  String? flowerFlag;
  ARKitNode? nodeFlower;
  ARKitNode? nodePlane;
  String noticeTxt1 = "화면을 터치하여 상품이 나타나면 위치를 조절해보세요.";
  var txtColor = Colors.white;

  math.Vector3? currentCoord;
  math.Vector3? currentAngle;

  String? anchorId = "";
  List<String> planeNameList = [];

  // List<ARKitAnchor> planeAnchorList = [];
  List<String> planeAnchorList = [];

  bool detectedFlag = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
    debugPrint("rowan:dispose!!");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: AppBar(title: const Text('Plane Detection Sample')),
        appBar: AppBar(
          title: const Text('ARStudio'),
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
            ARKitSceneView(
              showFeaturePoints: false,
              enableTapRecognizer: true,
              planeDetection: ARPlaneDetection.horizontal,
              onARKitViewCreated: onARKitViewCreated,
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
                                  (90 + currentAngle!.y * 180 / 3.14) *
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
                                  (90 + currentAngle!.y * 180 / 3.14) *
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
                                  (90 + currentAngle!.y * 180 / 3.14) *
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
                                  (90 + currentAngle!.y * 180 / 3.14) *
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
      );

  void refresh() {
    // if (flowerFlag != null) {
    //   arkitController.remove(flowerFlag!);
    // }
    // detectedFlag = false;
    // anchorId = "";

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARStudioIos(
          imageUrl:
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onARTap = (hits) => onNodeHitHandler(hits);
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  bool test = false;
  void _handleUpdateAnchor(ARKitAnchor anchor) {
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
    // if (anchor.identifier != anchorId || anchor is! ARKitPlaneAnchor) {
    //   return;
    // }
    if (anchor is! ARKitPlaneAnchor) {
      return;
    }

    // _addPlane(arkitController, anchor);

    if (flowerFlag != null) {
      arkitController.getCameraEulerAngles().then((value) => rotate(value));
      // arkitController.cameraPosition().then((value) => camera(value));
    }
  }

  void rotate(math.Vector3 value) {
    nodeFlower?.eulerAngles = math.Vector3(value.y, 0, 0);
    currentAngle = value;
    if (currentCoord != null) nodeFlower?.position = currentCoord!;
  }

  void onNodeHitHandler(List<ARKitTestResult> hits) {
    try {
      if (hits.isNotEmpty) {
        if (!detectedFlag) {
          detectedFlag = true;
          Fluttertoast.showToast(
              msg: "Detected!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              // backgroundColor: Colors.red,
              // textColor: Colors.white,
              fontSize: 10.0);

          math.Vector3 detectedPose = math.Vector3(
              hits[0].worldTransform.getColumn(3).x,
              hits[0].worldTransform.getColumn(3).y,
              hits[0].worldTransform.getColumn(3).z);

          currentCoord = detectedPose;

          nodeFlower = ARKitNode(
            geometry: ARKitPlane(
              width: widget.width! * 0.01,
              height: widget.height! * 0.01,
              materials: [
                ARKitMaterial(
                    // transparency: 1.0,
                    diffuse: ARKitMaterialProperty.image(widget.imageUrl))
              ],
            ),
            position: detectedPose,
            // rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
          );

          if (flowerFlag != null) {
            arkitController.remove(flowerFlag!);
          }
          arkitController.add(nodeFlower!);
          flowerFlag = nodeFlower?.name;
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

// void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
//   if (planeToggle) {
//     if (anchorId != anchor.identifier && !detectedFlag) {
//       ARKitPlane plane = ARKitPlane(
//         width: 1.0,
//         height: 1.0,
//         materials: [
//           ARKitMaterial(
//             transparency: 1.0,
//             diffuse: ARKitMaterialProperty.image(
//                 '/assets/images/ios_plane_background.png'),
//           )
//         ],
//       );
//
//       ARKitNode? nodePlane = ARKitNode(
//         geometry: plane,
//         position:
//             math.Vector3(anchor.center.x, anchor.center.y, anchor.center.z),
//         rotation: math.Vector4(1, 0, 0, -math.pi / 2),
//       );
//
//       for (var element in planeAnchorList) {
//         arkitController.removeAnchor(element);
//       }
//
//       for (var element in planeNameList) {
//         arkitController.remove(element);
//       }
//       planeNameList.clear();
//       planeAnchorList.clear();
//
//       planeNameList.add(nodePlane.name);
//       planeAnchorList.add(anchor.identifier);
//       arkitController.add(nodePlane, parentNodeName: anchor.nodeName);
//       // parentNodeName: planeAnchorList.last.nodeName);
//
//       anchorId = anchor.identifier;
//
//       // var product = ARKitPlane(
//       //   width: widget.width! * 0.01,
//       //   height: widget.height! * 0.01,
//       //   materials: [
//       //     ARKitMaterial(
//       //         // transparency: 1.0,
//       //         diffuse: ARKitMaterialProperty.image(widget.imageUrl))
//       //   ],
//       // );
//       //
//       // nodeFlower = ARKitNode(
//       //   geometry: product,
//       // );
//       // currentCoord = nodeFlower?.position;
//       // if (flowerFlag != null) {
//       //   arkitController.remove(flowerFlag!);
//       // }
//       // arkitController.add(nodeFlower!, parentNodeName: anchor.nodeName);
//       // flowerFlag = nodeFlower?.name;
//       //
//       // detectedFlag = true;
//     }
//   }
// }
}
