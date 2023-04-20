import 'dart:math';

import 'package:flutter/material.dart';

class SimulationHome extends StatefulWidget {
  const SimulationHome({
    super.key,
    required this.image,
  });

  final Image image;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => SimulationHomeState(image: image);
}

class SimulationHomeState extends State<SimulationHome> {
  SimulationHomeState({required this.image});

  final Image image;

  double _top = 0.0;
  double _left = 0.0;

  double imgWidth = 150.0;
  double imgHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_outlined),
              ),
            ],
          ),
          Container(
            height: 300,
            width: 400,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: _top,
                  left: _left,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        if (_top < 180) {
                          _top = max(0, _top + details.delta.dy);
                        } else {
                          _top = 179.0;
                        }
                        if (_left < 270) {
                          _left = max(0, _left + details.delta.dx);
                        } else {
                          _left = 269.0;
                        }

                        // debugPrint("tl : $_top $_left");
                      });
                    },
                    child: Image(
                      image: image.image,
                      width: imgWidth,
                      height: imgHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              onPressed: () {
                setState(() {
                  imgWidth += 5;
                  imgHeight += 5;
                });
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  imgWidth -= 5;
                  imgHeight -= 5;
                });
              },
              icon: const Icon(Icons.remove),
            )
          ])
        ],
      ),
    );
  }
}
