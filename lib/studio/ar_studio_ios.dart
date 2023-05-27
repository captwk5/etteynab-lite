import 'package:flutter/material.dart';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

// class HelloArkit extends StatefulWidget {
//   const HelloArkit({
//     super.key,
//     required this.imageUrl,
//   });

//   final String imageUrl;

//   @override
//   _HelloArkitState createState() => _HelloArkitState();
// }

// class _HelloArkitState extends State<HelloArkit> {
//   late ARKitController arkitController;
//   String anchorId = '';
//   double x = 0, y = 0;
//   double width = 100, height = 100;
//   Matrix4 transform = Matrix4.identity();

//   @override
//   void dispose() {
//     arkitController.onAddNodeForAnchor = null;
//     arkitController.onUpdateNodeForAnchor = null;
//     arkitController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//       appBar: AppBar(
//         title: const Text('Widget Projection'),
//       ),
//       body: Stack(
//         children: [
//           ARKitSceneView(
//             trackingImagesGroupName: 'AR Resources',
//             onARKitViewCreated: onARKitViewCreated,
//             worldAlignment: ARWorldAlignment.camera,
//             configuration: ARKitConfiguration.imageTracking,
//           ),
//         ],
//       ));

//   void onARKitViewCreated(ARKitController arkitController) {
//     this.arkitController = arkitController;
//     // this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
//     // this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;

//     // final plane = ARKitPlane(
//     //   width: 1,
//     //   height: 1,
//     //   widthSegmentCount: 1,
//     //   heightSegmentCount: 1,
//     // );

//     // final node = ARKitNode(
//     //   // geometry: ARKitSphere(radius: 0.1), position: vector.Vector3(0, 0, -0.5));
//     //     geometry: plane, position: vector.Vector3(0, 0, -2));
//     // this.arkitController.add(node);
//     final material = ARKitMaterial(
//       lightingModelName: ARKitLightingModel.lambert,
//       diffuse: ARKitMaterialProperty.image('earth.jpg'),
//     );
//     final sphere = ARKitSphere(
//       materials: [material],
//       radius: 0.1,
//     );

//     final node = ARKitNode(
//       geometry: sphere,
//       position: Vector3(0, 0, -0.5),
//       eulerAngles: Vector3.zero(),
//     );
//     this.arkitController.add(node);
//   }

//   void _handleAddAnchor(ARKitAnchor anchor) {
//     if (anchor is ARKitImageAnchor) {
//       anchorId = anchor.identifier;
//       _updatePosition(anchor);
//       _updateRotation(anchor);
//     }
//   }

//   void _handleUpdateAnchor(ARKitAnchor anchor) {
//     if (anchor.identifier == anchorId && anchor is ARKitImageAnchor) {
//       _updatePosition(anchor);
//       _updateRotation(anchor);
//     }
//   }

//   Future _updateRotation(ARKitAnchor anchor) async {
//     final t = anchor.transform.clone();
//     t.invertRotation();
//     t.rotateZ(math.pi / 2);
//     t.rotateX(math.pi / 2);
//     setState(() {
//       transform = t;
//     });
//   }

//   Future _updatePosition(ARKitImageAnchor anchor) async {
//     final transform = anchor.transform;
//     final width = anchor.referenceImagePhysicalSize.x / 2;
//     final height = anchor.referenceImagePhysicalSize.y / 2;

//     final topRight = Vector4(width, 0, -height, 1)..applyMatrix4(transform);
//     final bottomRight = Vector4(width, 0, height, 1)..applyMatrix4(transform);
//     final bottomLeft = Vector4(-width, 0, -height, 1)..applyMatrix4(transform);
//     final topLeft = Vector4(-width, 0, height, 1)..applyMatrix4(transform);

//     final pointsWorldSpace = [topRight, bottomRight, bottomLeft, topLeft];

//     final pointsViewportSpace = pointsWorldSpace
//         .map((p) => arkitController.projectPoint(Vector3(p.x, p.y, p.z)));
//     final pointsViewportSpaceResults = await Future.wait(pointsViewportSpace);

//     setState(() {
//       x = pointsViewportSpaceResults[2]!.x;
//       y = pointsViewportSpaceResults[2]!.y;
//       this.width = pointsViewportSpaceResults[0]!
//           .distanceTo(pointsViewportSpaceResults[3]!);
//       this.height = pointsViewportSpaceResults[1]!
//           .distanceTo(pointsViewportSpaceResults[2]!);
//     });
//   }
// }

class PlaneDetectionPage extends StatefulWidget {
  const PlaneDetectionPage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  _PlaneDetectionPageState createState() => _PlaneDetectionPageState();
}

class _PlaneDetectionPageState extends State<PlaneDetectionPage> {
  late ARKitController arkitController;
  ARKitPlane? plane;
  ARKitNode? node;
  ARKitNode? nodeFlower;
  int timer = 0;
  int angle = 0;
  String? anchorId;
  String? flowerFlag;
  Vector3? spot;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: AppBar(title: const Text('Plane Detection Sample')),
        body: ARKitSceneView(
          showFeaturePoints: false,
          enableTapRecognizer: true,
          planeDetection: ARPlaneDetection.horizontal,
          onARKitViewCreated: onARKitViewCreated,
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onARTap = (hits) => onNodeHitHandler(hits);
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is! ARKitPlaneAnchor) {
      return;
    }
    _addPlane(arkitController, anchor);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor.identifier != anchorId || anchor is! ARKitPlaneAnchor) {
      return;
    }
    node?.position = Vector3(anchor.center.x, 0, anchor.center.z);
    plane?.width.value = anchor.extent.x;
    plane?.height.value = anchor.extent.z;

    if (flowerFlag != null) {
      arkitController.getCameraEulerAngles().then((value) => test(value));
    }
  }

  void test(Vector3 value) {
    debugPrint("${nodeFlower?.eulerAngles} / $value");
    debugPrint("${nodeFlower?.eulerAngles.x} / ${value.x}");
    debugPrint("${nodeFlower?.eulerAngles.y} / ${value.y}");
    debugPrint("${nodeFlower?.eulerAngles.z} / ${value.z}");
    debugPrint("-----");
    // nodeFlower?.eulerAngles = value;
    nodeFlower?.eulerAngles = Vector3(value.y, 0, 0);
    // nodeFlower?.eulerAngles.x = 0;
    // nodeFlower?.eulerAngles.y = 0;
    debugPrint("${nodeFlower?.eulerAngles} ${Vector3(0, 0, value.y)}");
    debugPrint("-------------");
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorId = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.z,
      materials: [
        ARKitMaterial(
          transparency: 0.5,
          // diffuse: ARKitMaterialProperty.image('/assets/images/earth.jpg'),
          diffuse: ARKitMaterialProperty.color(
              const Color.fromARGB(255, 33, 243, 58)),
        )
      ],
    );

    // var plane2 = ARKitCylinder(
    //   height: anchor.extent.z,
    //   radius: anchor.extent.x,
    //   materials: [
    //     ARKitMaterial(
    //       transparency: 0.5,
    //       diffuse: ARKitMaterialProperty.image('/assets/images/earth.jpg'),
    //     )
    //   ],
    // );

    node = ARKitNode(
      geometry: plane,
      position: Vector3(anchor.center.x, 0, anchor.center.z),
      rotation: Vector4(1, 0, 0, -math.pi / 2),
    );
    // debugPrint(anchor.nodeName);
    controller.add(node!, parentNodeName: anchor.nodeName);
  }

  void onNodeHitHandler(List<ARKitTestResult> hits) {
    var plane = ARKitPlane(
      width: 0.2,
      height: 0.2,
      materials: [
        ARKitMaterial(
            // transparency: 1.0,
            diffuse: ARKitMaterialProperty.image(widget.imageUrl))
      ],
    );

    if (hits.isNotEmpty) {
      spot = Vector3(
          hits[0].worldTransform.getColumn(3).x,
          hits[0].worldTransform.getColumn(3).y + 0.1,
          hits[0].worldTransform.getColumn(3).z);
      nodeFlower = ARKitNode(
        geometry: plane,
        position: spot,
        // rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
      );

      if (flowerFlag != null) {
        arkitController.remove(flowerFlag!);
      }

      arkitController.add(nodeFlower!);
      flowerFlag = nodeFlower?.name;
      timer = DateTime.now().millisecondsSinceEpoch;
    }
  }
}
