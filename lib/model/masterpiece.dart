import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MasterPiece extends StatefulWidget {
  MasterPiece({
    super.key,
    required this.imageUrl,
    this.removeCallback,
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
  int selectedIdx = 0;

  Function? removeCallback;

  Color selectedItemBorderColor = Colors.white;
  int selectedItemIndex = 0;

  @override
  State<MasterPiece> createState() => _MasterPieceState();
}

typedef SelectedImageIdxCallback = void Function(int index);

class _MasterPieceState extends State<MasterPiece> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      Image.network(widget.imageUrl[widget.selectedItemIndex])
                          .image,
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
            width: 300,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, item) {
                if (widget.selectedItemIndex == item) {
                  widget.selectedItemBorderColor = Colors.green;
                } else {
                  widget.selectedItemBorderColor = Colors.white;
                }
                return GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Image.network(widget.imageUrl[item]).image,
                            fit: BoxFit.fill),
                        border: Border.all(
                            color: widget.selectedItemBorderColor, width: 2)),
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(10),
                  ),
                  onTap: () {
                    setState(() {
                      widget.selectedItemIndex = item;
                      widget.removeCallback?.call();
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
          const Text("작품설명"),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Text(
                    "${widget.description}\n11111\n22222\n33333\n44444\n55555\n66666",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
