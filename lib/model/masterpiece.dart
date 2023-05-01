import 'package:flutter/material.dart';

class MasterPiece extends StatelessWidget {
  const MasterPiece({
    super.key,
    required this.image,
    required this.title,
    required this.price,
  });

  final Image image;
  final String title;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: image.image, fit: BoxFit.fill),
          ),
          width: 300,
          height: 300,
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: const [
            // Text("$title : ${priceToString(price)}"),
            Text(
              "LaFul Studio",
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const SizedBox(
          height: 10,
          width: 300,
          child: Divider(color: Colors.green, thickness: 1.0),
        ),
      ]),
    );
  }

  String priceToString(String price) {
    return "$price원";
  }
}
