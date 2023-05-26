// import 'package:flutter/material.dart';
// import 'package:album_image/album_image.dart';

// class AlbumHome extends StatefulWidget {
//   const AlbumHome({Key? key}) : super(key: key);

//   @override
//   State<AlbumHome> createState() => _AlbumHomeState();
// }

// class _AlbumHomeState extends State<AlbumHome> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Builder(builder: (context) {
//       final thumbnailQuality = MediaQuery.of(context).size.width ~/ 3;
//       return AlbumImagePicker(
//         onSelected: (items) {
//           debugPrint("$items");
//         },
//         selectionBuilder: (_, selected, index) {
//           if (selected) {
//             return const CircleAvatar(
//               // radius: 10,
//               backgroundColor: Colors.red,
//               child: Icon(Icons.check),
//             );
//           }
//           return Container();
//         },
//         crossAxisCount: 3,
//         maxSelection: 1,
//         onSelectedMax: () {
//           debugPrint('Reach max');
//         },
//         albumBackGroundColor: Colors.white,
//         appBarHeight: 45,
//         itemBackgroundColor: Colors.grey[100]!,
//         appBarColor: Colors.white,
//         albumTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
//         albumSubTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
//         type: AlbumType.image,
//         closeWidget: const BackButton(
//           color: Colors.black,
//         ),
//         thumbnailQuality: thumbnailQuality * 3,
//       );
//     });
//   }
// }
