import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_banyette/view/detail/click_detail.dart';
import 'package:url_launcher/url_launcher.dart';

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
    this.width,
    this.height,
  });

  final List<String> imageUrl;
  List<String>? removedImageUrl;
  int? idx;
  String? title;
  String? price;
  String? description;
  String? url;
  int? width;
  int? height;
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
    double imgHeight = deviceHeight * 0.34; // count 1
    double imgWidth = 0;
    double margin = deviceHeight * 0.026; // count 3
    double subImgWidthHeight = imgHeight * 0.16; // count 1
    // ratio = 0.32 + 0.02 * 3 + 0.16 = 0.54
    // widget.descriptionCallback?.call(widget.description);
    widget.descriptionCallback?.call(
        "${widget.title},${widget.height},${widget.width},${widget.description}");

    Image currentImage =
        Image.network(widget.imageUrl[widget.selectedItemIndex]);
    currentImage.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      // completer.complete(info.image);
      // debugPrint("${info.image.width} ${info.image.height}");
      setState(() {
        if (info.image.width == info.image.height) {
          imgWidth = imgHeight;
        } else {
          imgWidth = imgHeight * (info.image.width / info.image.height);
        }
      });
    }));

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).cardColor),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: margin,
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClickView(
                            imageUrl: widget.imageUrl,
                            selectedIdx: widget.selectedItemIndex,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: currentImage.image, fit: BoxFit.fill),
                      ),
                      width: imgWidth,
                      height: imgHeight,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: margin,
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
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
                                  image: Image.network(widget.imageUrl[item])
                                      .image,
                                  fit: BoxFit.fill),
                              border: Border.all(
                                  color: widget.selectedItemBorderColor,
                                  width: 2)),
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
              const Text("자세히 보려면 이미지를 클릭하세요."),
              SizedBox(
                height: margin,
              ),
              TextButton(
                onPressed: () {
                  launchURLBrowser(widget.url);
                },
                child: const Text(
                  "상품 구매처로 이동",
                  style: TextStyle(fontSize: 15, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> launchURLBrowser(String? storeUrl) async {
    if (storeUrl != null) {
      Uri url = Uri.parse(storeUrl);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }
}
