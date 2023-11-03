import 'package:flutter/material.dart';

class ClickView extends StatefulWidget {
  const ClickView({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<ClickView> createState() => _ClickViewState();
}

class _ClickViewState extends State<ClickView> {
  @override
  Widget build(BuildContext context) {
    double imgWidth = MediaQuery.of(context).size.width;
    double imgHeight = 0;

    Image currentImage = Image.network(widget.imageUrl);
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
      body: InteractiveViewer(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.network(widget.imageUrl).image, fit: BoxFit.fill),
            ),
            width: imgWidth,
            height: imgHeight,
          ),
        ),
      ),
    );
  }
}
