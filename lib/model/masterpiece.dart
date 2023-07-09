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
  Function? descriptionCallback;

  Color selectedItemBorderColor = Colors.white;
  int selectedItemIndex = 0;

  @override
  State<MasterPiece> createState() => _MasterPieceState();
}

typedef SelectedImageIdxCallback = void Function(int index);

class _MasterPieceState extends State<MasterPiece> {
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double imgWidthHeight = deviceHeight * 0.32; // count 1
    double margin = deviceHeight * 0.02; // count 3
    double subImgWidthHeight = imgWidthHeight * 0.16; // count 1
    // ratio = 0.32 + 0.02 * 3 + 0.16 = 0.54
    widget.descriptionCallback?.call(widget.description);
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: margin,
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      Image.network(widget.imageUrl[widget.selectedItemIndex])
                          .image,
                  fit: BoxFit.fill),
            ),
            width: imgWidthHeight,
            height: imgWidthHeight,
          ),
          SizedBox(
            height: margin,
          ),
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              height: subImgWidthHeight,
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
                      width: subImgWidthHeight,
                      height: subImgWidthHeight,
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
          ),
          SizedBox(
            height: margin,
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.green, width: 1.0)), // 라인효과
            ),
          ),
        ],
      ),
    );
  }
}
