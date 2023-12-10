import 'package:flutter/material.dart';

class ClickView extends StatefulWidget {
  const ClickView(
      {super.key, required this.imageUrl, required this.selectedIdx});

  final List<String> imageUrl;
  final int selectedIdx;

  @override
  State<ClickView> createState() => _ClickViewState();
}

class _ClickViewState extends State<ClickView> {
  late PageController pageController;

  @override
  Widget build(BuildContext context) {
    pageController = PageController(initialPage: widget.selectedIdx);
    double imgWidth = MediaQuery.of(context).size.width;
    double imgHeight = 0;

    Image currentImage = Image.network(widget.imageUrl[widget.selectedIdx]);
    currentImage.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      // completer.complete(info.image);
      // debugPrint("${info.image.width} ${info.image.height}");
      if (info.image.width < info.image.height) {
        imgHeight = (info.image.height / info.image.width) * imgWidth;
      } else if (info.image.width > info.image.height) {
        imgHeight = (info.image.height / info.image.width) * imgWidth;
      } else {}
    }));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(
            color: Theme.of(context).cardColor,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).shadowColor,
      ),
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: pageController,
        itemCount: widget.imageUrl.length,
        itemBuilder: (context, index) {
          Image selectedImg = Image.network(widget.imageUrl[index]);
          selectedImg.image
              .resolve(const ImageConfiguration())
              .addListener(ImageStreamListener((ImageInfo info, bool _) {
            if (info.image.width < info.image.height) {
              imgHeight = (info.image.height / info.image.width) * imgWidth;
            } else if (info.image.width > info.image.height) {
              imgHeight = (info.image.height / info.image.width) * imgWidth;
            } else {}
          }));
          return InteractiveViewer(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: selectedImg.image, fit: BoxFit.fill),
                ),
                width: imgWidth,
                height: imgHeight,
              ),
            ),
          );
        },
      ),
    );
  }
}
