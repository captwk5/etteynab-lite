import 'dart:math';

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
  bool planeToggle = false;
  ArCoreNode? nodeFlower;
  String noticeTxt1 = "화면을 터치하여 상품이 나타나면 위치를 조절해보세요.";
  var txtColor = Colors.white;

  math.Vector3? currentCoord;
  List<double>? currentAngle;
  List<double>? cameraCoord;

  bool detectedFlag = false;
  bool planeDetected = false;

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
            GestureDetector(
              child: ArCoreView(
                enableTapRecognizer: true,
                enableUpdateListener: true,
                enablePlaneRenderer: false,
                onArCoreViewCreated: _onArCoreViewCreated,
              ),
              onVerticalDragUpdate: (drag) => {
                objDragUpDown(drag)
              },
              onHorizontalDragUpdate: (drag) => {
                objDragRightLeft(drag)
              },
            ),
            Positioned.fill(
              bottom: positioned,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.switch_camera_outlined,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "평면을 향하고 카메라가 평면을 인식하도록\n디바이스를 조금 움직여 주세요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
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
                        style: const TextStyle(color: Colors.black, fontSize: 17),
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
                            "조금 더 앞으로",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (detectedFlag) {
                              objPushPull("pull");
                            }
                          },
                          // color: Colors.white,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent),
                          child: const Row(children: [
                            Text(
                              "조금 더 나한테",
                              style: TextStyle(color: Colors.black),
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
          imageUrl: widget.imageUrl,
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

  void onPlaneDetected(ArCorePlane p) async {
    if (!planeDetected) {
      Fluttertoast.showToast(
          msg: "터치해서 상품을 올려보세요.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 10.0);
      planeDetected = true;
      setState(() {
        positioned = 10000;
        txtColor = Colors.transparent;
      });
    }
    if (detectedFlag) {
      await arCoreController.getCameraPose().then((value) => rotate(value));
    }
  }

  void rotate(dynamic value) {
    var rot = value["rotation"]; // translation & rotation
    cameraCoord = value["translation"];
    if (currentCoord != null) {
      distance = math.sqrt(
          math.pow(currentCoord!.x - cameraCoord![0], 2) +
              math.pow(currentCoord!.y - cameraCoord![1], 2) +
              math.pow(currentCoord!.z - cameraCoord![2], 2));
      // debugPrint("rowan ${distance}");
      directionX = currentCoord!.x - cameraCoord![0];
      directionZ = currentCoord!.z - cameraCoord![2];
      slope = math.atan(directionZ / directionX);
      slopeV = math.atan(-1.0 / (directionZ / directionX));

      if(!ppFlag){
        ppFlag = true;
        // // debugPrint("rowan ${distance}");
        // if(distance > 1.5){
        //   objPushPull2("pull");
        // }else if(distance < 1.5){
        //   objPushPull2("push");
        // }
      }
    }

    var origin = nodeFlower?.rotation?.value;
    // var eulerCamera = toEulerAngles(rot![0], rot![1], rot![2], rot![3]);
    // var eulerOrigin = toEulerAngles(origin!.x, origin.y, origin.z, origin.w);
    // var quat = eulerToQuaternion(euler["roll"]!, -euler["pitch"]! * 2, euler["yaw"]!);
    nodeFlower?.rotation?.value =
        // math.Vector4(quat[0], quat[1], quat[2], quat[3]);
        math.Vector4(origin!.x, -rot[1], origin.z, origin.w);

    arCoreController.handleRotationChanged(nodeFlower!);
    currentAngle = rot;
    // debugPrint("rowan ${euler["pitch"]! * 2 * 180 / math.pi}");

    if (currentCoord != null) {
      nodeFlower?.position?.value =
          math.Vector3(currentCoord!.x, currentCoord!.y, currentCoord!.z);
      arCoreController.handlePositionChanged(nodeFlower!);
    }
  }

  // Map<String, double> toEulerAngles(double x, double y, double z, double w) {
  //   double t0 = 2.0 * (w * x + y * z);
  //   double t1 = 1.0 - 2.0 * (x * x + y * y);
  //   double roll = atan2(t0, t1);
  //
  //   double t2 = 2.0 * (w * y - z * x);
  //   t2 = t2 > 1.0 ? 1.0 : t2;
  //   t2 = t2 < -1.0 ? -1.0 : t2;
  //   double pitch = asin(t2);
  //
  //   double t3 = 2.0 * (w * z + x * y);
  //   double t4 = 1.0 - 2.0 * (y * y + z * z);
  //   double yaw = atan2(t3, t4);
  //
  //   return {'roll': roll, 'pitch': pitch, 'yaw': yaw};
  // }
  //
  // List<double> eulerToQuaternion(double roll, double pitch, double yaw) {
  //   double cy = cos(yaw * 0.5);
  //   double sy = sin(yaw * 0.5);
  //   double cp = cos(pitch * 0.5);
  //   double sp = sin(pitch * 0.5);
  //   double cr = cos(roll * 0.5);
  //   double sr = sin(roll * 0.5);
  //
  //   double w = cr * cp * cy + sr * sp * sy;
  //   double x = sr * cp * cy - cr * sp * sy;
  //   double y = cr * sp * cy + sr * cp * sy;
  //   double z = cr * cp * sy - sr * sp * cy;
  //
  //   return [x, y, z, w];
  // }

  void objDragUpDown(DragUpdateDetails drag){
    if(detectedFlag){
      if(prevDy != 0.0){
        if(drag.globalPosition.dy - prevDy < 0){
          currentCoord!.y += 0.005;
        }else{
          currentCoord!.y -= 0.005;
        }
      }

      prevDy = drag.globalPosition.dy;
    }
  }

  void objDragRightLeft(DragUpdateDetails drag){
    if(detectedFlag){
      if(prevDx != 0.0){
        if(directionZ < 0){
          if(drag.globalPosition.dx - prevDx < 0){
            currentCoord!.x -= 0.005 * math.cos(slopeV);
            currentCoord!.z -= 0.005 * math.sin(slopeV);
          }else{
            currentCoord!.x += 0.005 * math.cos(slopeV);
            currentCoord!.z += 0.005 * math.sin(slopeV);
          }
        }else{
          if(drag.globalPosition.dx - prevDx < 0){
            currentCoord!.x += 0.005 * math.cos(slopeV);
            currentCoord!.z += 0.005 * math.sin(slopeV);
          }else{
            currentCoord!.x -= 0.005 * math.cos(slopeV);
            currentCoord!.z -= 0.005 * math.sin(slopeV);
          }
        }
      }
      prevDx = drag.globalPosition.dx;
    }
  }

  void objPushPull(String pp){
    if(pp == "push"){
      currentCoord!.x -= 0.05 * math.cos(slope);
      currentCoord!.z -= 0.05 * math.sin(slope);
      var calDistance = math.sqrt(
          math.pow(currentCoord!.x - cameraCoord![0], 2) +
              math.pow(currentCoord!.y - cameraCoord![1], 2) +
              math.pow(currentCoord!.z - cameraCoord![2], 2));
      if(calDistance < distance){
        currentCoord!.x += 0.1 * math.cos(slope);
        currentCoord!.z += 0.1 * math.sin(slope);
      }
    }else{
      currentCoord!.x += 0.05 * math.cos(slope);
      currentCoord!.z += 0.05 * math.sin(slope);
      var calDistance = math.sqrt(
          math.pow(currentCoord!.x - cameraCoord![0], 2) +
              math.pow(currentCoord!.y - cameraCoord![1], 2) +
              math.pow(currentCoord!.z - cameraCoord![2], 2));
      if(calDistance > distance){
        currentCoord!.x -= 0.1 * math.cos(slope);
        currentCoord!.z -= 0.1 * math.sin(slope);
      }
    }
  }

  void objPushPull2(String pp){
    var calDistance = 0.0;
    var pm = 1;
    if(pp == "push"){
      for (var i = 0; i < 1000; i++){
        // currentCoord!.x -= 0.05 * math.cos(slope);
        // currentCoord!.z -= 0.05 * math.sin(slope);
        //
        // var calDistance = math.sqrt(
        //     math.pow(currentCoord!.x - cameraCoord![0], 2) +
        //         math.pow(currentCoord!.y - cameraCoord![1], 2) +
        //         math.pow(currentCoord!.z - cameraCoord![2], 2));
        // if(calDistance > 1){
        //   break;
        // }
        currentCoord!.x -= 0.1 * pm * math.cos(slope);
        currentCoord!.z -= 0.1 * pm * math.sin(slope);
        calDistance = math.sqrt(
            math.pow(currentCoord!.x - cameraCoord![0], 2) +
                math.pow(currentCoord!.y - cameraCoord![1], 2) +
                math.pow(currentCoord!.z - cameraCoord![2], 2));
        if(calDistance < distance){
          pm *= -1;
        }
        if(calDistance > 1.5) {
          debugPrint("rowan ${calDistance} hihi");
          break;
        }
      }
    }else{
      for (var i = 0; i < 1000; i++){
        // currentCoord!.x += 0.05 * math.cos(slope);
        // currentCoord!.z += 0.05 * math.sin(slope);
        //
        // var calDistance = math.sqrt(
        //     math.pow(currentCoord!.x - cameraCoord![0], 2) +
        //         math.pow(currentCoord!.y - cameraCoord![1], 2) +
        //         math.pow(currentCoord!.z - cameraCoord![2], 2));
        // if(calDistance < 1){
        //   break;
        // }
        currentCoord!.x += 0.1 * pm * math.cos(slope);
        currentCoord!.z += 0.1 * pm * math.sin(slope);
        calDistance = math.sqrt(
            math.pow(currentCoord!.x - cameraCoord![0], 2) +
                math.pow(currentCoord!.y - cameraCoord![1], 2) +
                math.pow(currentCoord!.z - cameraCoord![2], 2));
        if(calDistance > distance){
          pm *= -1;
        }
        if(calDistance < 1.5) {
          debugPrint("rowan ${calDistance} hihi");
          break;
        }
      }
    }
  }

  void onPlaneTap(List<ArCoreHitTestResult> hit) async {
    try {
      if (hit.isNotEmpty && planeDetected) {
        if (!detectedFlag) {
          detectedFlag = true;
          // planeToggle = false;
          // arCoreController.togglePlaneRenderer();
          Fluttertoast.showToast(
              msg: "Detected!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              // backgroundColor: Colors.red,
              // textColor: Colors.white,
              fontSize: 10.0);

          var detectedPose = hit.first.pose.translation;
          // var detectedPose = math.Vector3(0.0, 0.0, -0.5);
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
