import 'package:flutter/material.dart';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

class PlaneDetectionPage extends StatefulWidget {
  const PlaneDetectionPage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  // ignore: library_private_types_in_public_api
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
        appBar: AppBar(
          title: const Text('LaFul ARStudio'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 50,
          backgroundColor: Theme.of(context).cardColor,
        ),
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
    nodeFlower?.eulerAngles = Vector3(value.y, 0, 0);
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
