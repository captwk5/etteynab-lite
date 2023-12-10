import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/view/home/etteynab_home.dart';

void main() {
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* firebase initialization */
    FirebaseApiService firebaseApiService = FirebaseApiService();

    firebaseApiService.initialization();

    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      theme: ThemeData(
        cardColor: Colors.green,
        shadowColor: Colors.green,
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          bodyMedium: GoogleFonts.lato(textStyle: textTheme.bodyMedium),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      home: Home(),
    );
  }
}

// ignore: must_be_immutable
class Home extends StatelessWidget {
  Home({super.key});

  TextEditingController artistTxtIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          // image: DecorationImage(
          //     image: AssetImage("assets/images/etteynab_home.jpg"),
          //     fit: BoxFit.cover),
          color: Colors.white),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        // backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Etteynab-lite",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                  ),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: artistTxtIdController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    prefixIconColor: Colors.green,
                    hintText: "판매자를 검색하세요.",
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) async {
                    var searchTxt = value;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EtteynabArStudio(
                          userName: searchTxt,
                          dataMap: FirebaseApiService.instance
                              .createMasterPieceInfo(searchTxt),
                          noDataMap: FirebaseApiService.instance
                              .getRandomMasterPieceInfo(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
