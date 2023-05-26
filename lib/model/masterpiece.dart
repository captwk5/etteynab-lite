import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MasterPiece extends StatefulWidget {
  MasterPiece({
    super.key,
    required this.imageUrl,
    this.removedImageUrl,
    this.idx,
    this.title,
    this.price,
    this.description,
    this.url,
  });

  final List<String> imageUrl;
  List<String>? removedImageUrl;
  int? idx;
  String? title;
  String? price;
  String? description;
  String? url;

  @override
  State<MasterPiece> createState() => _MasterPieceState();
}

class _MasterPieceState extends State<MasterPiece> {
  var selectedItemBorderColor = Colors.white;
  var selectedItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        const SizedBox(
          height: 15,
        ),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.network(widget.imageUrl[selectedItemIndex]).image,
                fit: BoxFit.fill),
          ),
          width: 300,
          height: 300,
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, item) {
              if (selectedItemIndex == item) {
                selectedItemBorderColor = Colors.green;
              } else {
                selectedItemBorderColor = Colors.white;
              }
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Image.network(widget.imageUrl[item]).image,
                          fit: BoxFit.fill),
                      border:
                          Border.all(color: selectedItemBorderColor, width: 2)),
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(10),
                ),
                onTap: () {
                  setState(() {
                    selectedItemIndex = item;
                  });
                },
              );
            },
            separatorBuilder: (context, item) => const SizedBox(
              width: 10,
            ),
            itemCount: widget.imageUrl.length,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Text(
                  "${widget.description}",
                  style: const TextStyle(height: 2.5, fontSize: 25),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  String priceToString(String price) {
    return "$price원";
  }
}
