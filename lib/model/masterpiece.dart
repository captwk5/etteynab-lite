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
            image: DecorationImage(
              image: image.image,
            ),
          ),
          width: 300,
          height: 300,
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            Text("$title : ${priceToString(price)}"),
            OutlinedButton.icon(
              onPressed: () {},
              label: const Text("네이버스토어로 구매하러 가기"),
              icon: const Icon(Icons.shopping_cart),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
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
