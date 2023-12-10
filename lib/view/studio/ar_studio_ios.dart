import 'dart:ui';

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
  late FToast fToast;
  bool planeToggle = true;
  String? flowerFlag;
  ARKitNode? nodeFlower;
  ARKitNode? nodePlane;
  String noticeTxt1 = "화면을 터치하여 상품이 나타나면 위치를 조절해보세요.";
  var txtColor = Colors.white;

  math.Vector3? currentCoord;
  math.Vector3? currentAngle;
  math.Vector3? cameraCoord;

  String? anchorId = "";
  List<String> planeNameList = [];

  // List<ARKitAnchor> planeAnchorList = [];
  List<String> planeAnchorList = [];

  bool detectedFlag = false;
  bool planeDetected = false;

  double dragScale = 0.01;

  double distance = 0.0;
  double directionX = 0.0;
  double directionZ = 0.0;
  double slope = 0.0;
  double slopeV = 0.0;
  double prevDy = 0.0;
  double prevDx = 0.0;

  double positioned = 0.0;
  bool ppFlag = false;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
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
          title: const Text(
            'ARStudio',
            style: TextStyle(color: Colors.white),
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
            GestureDetector(
              child: ARKitSceneView(
                showFeaturePoints: false,
                enableTapRecognizer: true,
                planeDetection: ARPlaneDetection.horizontal,
                onARKitViewCreated: onARKitViewCreated,
              ),
              onVerticalDragUpdate: (drag) => {objDragUpDown(drag)},
              onHorizontalDragUpdate: (drag) => {objDragRightLeft(drag)},
            ),
            Positioned.fill(
              bottom: positioned,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.switch_camera_outlined,
                      size: 100,
                      color: txtColor,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "평면을 향하고 카메라가 평면을 인식하도록\n디바이스를 앞뒤, 좌우로 움직여 주세요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: txtColor,
                      ),
                    )
                  ],
                ),
              ),
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (detectedFlag) {
                              objPushPull("push");
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_circle_up_outlined,
                            size: 25,
                          ),
                          // color: Colors.white,
                          label: const Text(
                            "앞으로",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (detectedFlag) {
                              objPushPull("pull");
                            }
                          },
                          // color: Colors.white,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Row(children: [
                            Text(
                              "가까이",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_circle_down_outlined,
                              size: 25,
                            ),
                          ]),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.refresh,
                        size: 20,
                      ),
                      onPressed: () {
                        refresh();
                      },
                      label: const Text("상품 다시 놓기"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
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
          imageUrl: widget.imageUrl,
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

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (!planeDetected) {
      showCustomToast("터치해서 상품을 올려보세요.", Colors.white, Colors.blue);
      setState(() {
        positioned = 10000;
        txtColor = Colors.transparent;
      });
      planeDetected = true;
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
      arkitController.cameraPosition().then((value) => camera(value));
    }
  }

  void rotate(math.Vector3 value) {
    nodeFlower?.eulerAngles = math.Vector3(value.y, 0, 0);
    currentAngle = value;
    if (currentCoord != null) nodeFlower?.position = currentCoord!;
  }

  void camera(math.Vector3? value) {
    cameraCoord = value;

    if (currentCoord != null) {
      distance = math.sqrt(math.pow(currentCoord!.x - cameraCoord!.x, 2) +
          math.pow(currentCoord!.y - cameraCoord!.y, 2) +
          math.pow(currentCoord!.z - cameraCoord!.z, 2));
      directionX = currentCoord!.x - cameraCoord!.x;
      directionZ = currentCoord!.z - cameraCoord!.z;
      slope = math.atan(directionZ / directionX);
      slopeV = math.atan(-1.0 / (directionZ / directionX));

      if (!ppFlag) {
        // debugPrint("$distance");
        ppFlag = true;
        if (distance > 1) {
          objPushPull2("pull");
        } else if (distance < 1) {
          objPushPull2("push");
        }
      }
    }
  }

  void objDragUpDown(DragUpdateDetails drag) {
    if (detectedFlag) {
      if (prevDy != 0.0) {
        if (drag.globalPosition.dy - prevDy < 0) {
          currentCoord!.y += dragScale;
        } else {
          currentCoord!.y -= dragScale;
        }
      }

      prevDy = drag.globalPosition.dy;
    }
  }

  void objDragRightLeft(DragUpdateDetails drag) {
    if (detectedFlag) {
      if (prevDx != 0.0) {
        if (directionZ < 0) {
          if (drag.globalPosition.dx - prevDx < 0) {
            currentCoord!.x -= dragScale * math.cos(slopeV);
            currentCoord!.z -= dragScale * math.sin(slopeV);
          } else {
            currentCoord!.x += dragScale * math.cos(slopeV);
            currentCoord!.z += dragScale * math.sin(slopeV);
          }
        } else {
          if (drag.globalPosition.dx - prevDx < 0) {
            currentCoord!.x += dragScale * math.cos(slopeV);
            currentCoord!.z += dragScale * math.sin(slopeV);
          } else {
            currentCoord!.x -= dragScale * math.cos(slopeV);
            currentCoord!.z -= dragScale * math.sin(slopeV);
          }
        }
      }
      prevDx = drag.globalPosition.dx;
    }
  }

  void objPushPull(String pp) {
    if (pp == "push") {
      currentCoord!.x -= 0.05 * math.cos(slope);
      currentCoord!.z -= 0.05 * math.sin(slope);
      var calDistance = math.sqrt(
          math.pow(currentCoord!.x - cameraCoord!.x, 2) +
              math.pow(currentCoord!.y - cameraCoord!.y, 2) +
              math.pow(currentCoord!.z - cameraCoord!.z, 2));
      if (calDistance < distance) {
        currentCoord!.x += 0.1 * math.cos(slope);
        currentCoord!.z += 0.1 * math.sin(slope);
      }
    } else {
      currentCoord!.x += 0.05 * math.cos(slope);
      currentCoord!.z += 0.05 * math.sin(slope);
      var calDistance = math.sqrt(
          math.pow(currentCoord!.x - cameraCoord!.x, 2) +
              math.pow(currentCoord!.y - cameraCoord!.y, 2) +
              math.pow(currentCoord!.z - cameraCoord!.z, 2));
      if (calDistance > distance) {
        currentCoord!.x -= 0.1 * math.cos(slope);
        currentCoord!.z -= 0.1 * math.sin(slope);
      }
    }
  }

  void objPushPull2(String pp) {
    var calDistance = 0.0;
    var pm = 1;
    if (pp == "push") {
      for (var i = 0; i < 100; i++) {
        currentCoord!.x -= 0.1 * pm * math.cos(slope);
        currentCoord!.z -= 0.1 * pm * math.sin(slope);

        calDistance = math.sqrt(math.pow(currentCoord!.x - cameraCoord!.x, 2) +
            math.pow(currentCoord!.y - cameraCoord!.y, 2) +
            math.pow(currentCoord!.z - cameraCoord!.z, 2));
        if (i == 0) {
          if (calDistance < distance) {
            pm *= -1;
          }
        }

        if (calDistance > 1) {
          break;
        }
      }
    } else {
      for (var i = 0; i < 100; i++) {
        currentCoord!.x += 0.1 * pm * math.cos(slope);
        currentCoord!.z += 0.1 * pm * math.sin(slope);

        calDistance = math.sqrt(math.pow(currentCoord!.x - cameraCoord!.x, 2) +
            math.pow(currentCoord!.y - cameraCoord!.y, 2) +
            math.pow(currentCoord!.z - cameraCoord!.z, 2));
        if (i == 0) {
          if (calDistance > distance) {
            pm *= -1;
          }
        }

        if (calDistance < 1) {
          break;
        }
      }
    }
  }

  void onNodeHitHandler(List<ARKitTestResult> hits) {
    try {
      if (hits.isNotEmpty && planeDetected && !detectedFlag) {
        detectedFlag = true;
        showCustomToast("화면에 나타난 상품 위치를 조정해 보세요.", Colors.white, Colors.green);

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
      } else {
        showCustomToast("다시 터치해 주세요.", Colors.white, Colors.red);
      }
    } catch (e) {
      debugPrint("rowan Something wrong! ${e.toString()}");
    }
  }

  void showCustomToast(String msg, Color c, Color b) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: b.withOpacity(0.5),
      ),
      child: Text(
        msg,
        style: TextStyle(
          color: c,
          fontSize: 15,
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 2),
    );
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
